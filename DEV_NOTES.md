
The keys are just used for testing! 

~~~SQL
INSERT INTO auth_systems (id, name, enabled, external_sign_in_url, external_public_key, internal_public_key, internal_private_key, email_or_login_match, manage_accounts, managed_domain, send_email)
VALUES 
    ('ms-oidc-zhdk', 
    'ZHdK - M365 / MIP OIDC  ',
    true,
    '/auth/zhdk/sign-in',
'-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEJ4rhhIPTtpnwZZOiaf3GTp0AFFQi
Qwu6VFlF/3oX/PO0wdJf6Pm9cAEcXDC7ZR5RRbwOrLE0v2p9h5rSz9+plw==
-----END PUBLIC KEY-----
',
'-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEsbMAuj7HWPQbZzoSkBUD5lnQHITU
TEGhQYrprSHdvRFeyqiH8+/cjDw69csSAwFylw2SUcpDMiVuGVrd20CJWA==
-----END PUBLIC KEY-----',
'-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIHD5xXtcnUAMXcxvyE+bQP5Vj5d1yIepSdADZAsN2mSXoAoGCCqGSM49
AwEHoUQDQgAEsbMAuj7HWPQbZzoSkBUD5lnQHITUTEGhQYrprSHdvRFeyqiH8+/c
jDw69csSAwFylw2SUcpDMiVuGVrd20CJWA==
-----END EC PRIVATE KEY-----
',
    '(?i)^.+@zhdk.ch$',
     false,
     (SELECT managed_domain FROM auth_systems WHERE id = 'zhdk-agw-new'),
     (SELECT send_email FROM auth_systems WHERE id = 'zhdk-agw-new'))
ON CONFLICT (id) 
DO UPDATE SET 
    name = EXCLUDED.name,
    enabled = EXCLUDED.enabled,
    external_sign_in_url = EXCLUDED.external_sign_in_url,
    external_public_key = EXCLUDED.external_public_key,
    internal_public_key = EXCLUDED.internal_public_key,
    internal_private_key = EXCLUDED.internal_private_key,
    email_or_login_match = EXCLUDED.email_or_login_match,
    manage_accounts = EXCLUDED.manage_accounts,
    managed_domain = EXCLUDED.managed_domain,
    send_email = EXCLUDED.send_email;
~~~


~~~SQL
INSERT INTO auth_systems (id, name, enabled, external_sign_in_url, external_public_key, internal_public_key, internal_private_key, email_or_login_match, manage_accounts, managed_domain, send_email)
VALUES 
    ('ms-oidc-zhdk', 
    'ZHdK - M365 / MIP OIDC  ',
    true,
    'http://localhost:3434/ext-auth/ms-oidc/zhdk/sign-in',
'-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEJ4rhhIPTtpnwZZOiaf3GTp0AFFQi
Qwu6VFlF/3oX/PO0wdJf6Pm9cAEcXDC7ZR5RRbwOrLE0v2p9h5rSz9+plw==
-----END PUBLIC KEY-----
',
'-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEsbMAuj7HWPQbZzoSkBUD5lnQHITU
TEGhQYrprSHdvRFeyqiH8+/cjDw69csSAwFylw2SUcpDMiVuGVrd20CJWA==
-----END PUBLIC KEY-----',
'-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIHD5xXtcnUAMXcxvyE+bQP5Vj5d1yIepSdADZAsN2mSXoAoGCCqGSM49
AwEHoUQDQgAEsbMAuj7HWPQbZzoSkBUD5lnQHITUTEGhQYrprSHdvRFeyqiH8+/c
jDw69csSAwFylw2SUcpDMiVuGVrd20CJWA==
-----END EC PRIVATE KEY-----
',
    '(?i)^.+@zhdk.ch$',
     (SELECT manage_accounts FROM auth_systems WHERE id = 'zhdk-agw-new'),
     (SELECT managed_domain FROM auth_systems WHERE id = 'zhdk-agw-new'),
     (SELECT send_email FROM auth_systems WHERE id = 'zhdk-agw-new'))
ON CONFLICT (id) 
DO UPDATE SET 
    name = EXCLUDED.name,
    enabled = EXCLUDED.enabled,
    external_sign_in_url = EXCLUDED.external_sign_in_url,
    external_public_key = EXCLUDED.external_public_key,
    internal_public_key = EXCLUDED.internal_public_key,
    internal_private_key = EXCLUDED.internal_private_key,
    email_or_login_match = EXCLUDED.email_or_login_match,
    manage_accounts = EXCLUDED.manage_accounts,
    managed_domain = EXCLUDED.managed_domain,
    send_email = EXCLUDED.send_email;
~~~