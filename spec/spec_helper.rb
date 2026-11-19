# frozen_string_literal: true

require 'rack/test'
require 'webmock/rspec'
require 'openssl'
require 'jwt'
require 'json'

WebMock.disable_net_connect!

# Generate EC key pairs for tests (prime256v1 = ES256)
TEST_APP_KEY    = OpenSSL::PKey::EC.generate('prime256v1')
TEST_MADEK_KEY  = OpenSSL::PKey::EC.generate('prime256v1')

FAKE_OIDC_CONFIG = {
  issuer: 'https://login.microsoftonline.com/test-tenant/v2.0',
  jwks_uri: 'https://login.microsoftonline.com/test-tenant/discovery/v2.0/keys',
  end_session_endpoint: 'https://login.microsoftonline.com/test-tenant/oauth2/v2.0/logout'
}.to_json

FAKE_JWKS = { keys: [] }.to_json

def stub_ms_endpoints
  stub_request(:get, /microsoftonline\.com.*openid-configuration/)
    .to_return(status: 200, body: FAKE_OIDC_CONFIG, headers: { 'Content-Type' => 'application/json' })
  stub_request(:get, /microsoftonline\.com.*keys/)
    .to_return(status: 200, body: FAKE_JWKS, headers: { 'Content-Type' => 'application/json' })
end

def setup_globals
  $config = {
    port: 3434,
    send_login_hint: true,
    email_attribute: 'preferred_username',
    tenant: 'test-tenant',
    external_base_url: 'https://test.example.com',
    name: 'zhdk',
    madek_auth_id: 'zhdk',
    client_id: 'test-client-id',
    client_secret: 'test-secret',
    private_key: TEST_APP_KEY.to_pem,
    public_key: TEST_APP_KEY.public_key.to_pem,
    madek_public_key: TEST_MADEK_KEY.public_key.to_pem,
    institutional_id_attribute: 'oid'
  }.with_indifferent_access
end

def madek_sign_in_token(overrides = {})
  payload = {
    'email-or-login' => 'user@zhdk.ch',
    'sign-in-url' => 'https://medienarchiv.zhdk.ch/sign-in',
    'server_base_url' => 'https://medienarchiv.zhdk.ch',
    exp: Time.now.to_i + 300
  }.merge(overrides)
  JWT.encode(payload, TEST_MADEK_KEY, 'ES256')
end

stub_ms_endpoints
setup_globals

load File.expand_path('../ms-oidc-authenticator', __dir__)

# Reset the Sinatra prototype so each example group gets a fresh instance
# with the current global state.
RSpec.configure do |config|
  config.before(:suite) do
    AuthenticatorApp.instance_variable_set(:@prototype, nil)
  end
end
