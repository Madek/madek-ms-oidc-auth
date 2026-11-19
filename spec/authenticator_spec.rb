# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe AuthenticatorApp do
  include Rack::Test::Methods

  def app
    AuthenticatorApp
  end

  describe 'GET /status' do
    it 'returns OK' do
      get '/ext-auth/ms-oidc/zhdk/status'
      expect(last_response.status).to eq 200
      expect(last_response.body).to eq 'OK'
    end
  end

  describe 'GET /sign-in' do
    context 'with a valid sign-in token' do
      it 'redirects to the Microsoft authorization endpoint' do
        get '/ext-auth/ms-oidc/zhdk/sign-in', token: madek_sign_in_token

        expect(last_response.status).to eq 302
        location = last_response.headers['Location']
        expect(location).to include('login.microsoftonline.com')
        expect(location).to include('test-tenant')
        expect(location).to include('test-client-id')
      end

      it 'uses authorization code flow with PKCE when client_secret is configured' do
        get '/ext-auth/ms-oidc/zhdk/sign-in', token: madek_sign_in_token

        location = last_response.headers['Location']
        expect(location).to include('response_type=code')
        expect(location).to include('code_challenge=')
        expect(location).to include('code_challenge_method=S256')
      end

      it 'includes a login_hint when send_login_hint is true' do
        get '/ext-auth/ms-oidc/zhdk/sign-in', token: madek_sign_in_token

        location = last_response.headers['Location']
        expect(location).to include('login_hint=')
        expect(location).to include(CGI.escape('user@zhdk.ch'))
      end
    end

    context 'with an expired sign-in token' do
      it 'returns 403 with an expiry message' do
        expired_token = madek_sign_in_token(exp: Time.now.to_i - 60)

        get '/ext-auth/ms-oidc/zhdk/sign-in', token: expired_token

        expect(last_response.status).to eq 403
        expect(last_response.body).to include('Token Expired')
      end
    end

    context 'with a missing token' do
      it 'returns 500' do
        get '/ext-auth/ms-oidc/zhdk/sign-in'

        expect(last_response.status).to eq 500
      end
    end
  end

  describe 'POST /callback' do
    context 'with an unknown nonce in the id_token' do
      it 'returns 403 with a nonce error' do
        # Build a state token that the app would have issued
        state_payload = {
          sign_in_request_token: madek_sign_in_token,
          code_verifier: 'some-verifier'
        }
        state = JWT.encode(state_payload, TEST_APP_KEY, 'ES256')

        # Build a fake id_token with a nonce the app never registered
        id_token_payload = {
          preferred_username: 'user@zhdk.ch',
          family_name: 'User',
          given_name: 'Test',
          oid: 'oid-123',
          nonce: 'unknown-nonce-not-in-nonces-set',
          exp: Time.now.to_i + 300
        }

        # The app will try to verify the id_token against MS keys.
        # We skip real MS token exchange by stubbing the token endpoint.
        stub_request(:post, /microsoftonline\.com.*token/)
          .to_return(
            status: 200,
            body: JSON.generate(id_token: JWT.encode(id_token_payload, TEST_APP_KEY, 'ES256',
                                                     { kid: TEST_MS_KID })),
            headers: { 'Content-Type' => 'application/json' }
          )

        post '/ext-auth/ms-oidc/zhdk/callback',
             state: state,
             code: 'auth-code',
             session_state: 'sess-123'

        expect(last_response.status).to eq 403
        expect(last_response.body).to include('nonce')
      end
    end
  end
end
