Samba.configure do |settings|
  settings.oauth_authorization_endpoint = "https://samba.server/oauth/authorize"

  settings.oauth_client = {
    id: "client-abc123",
    redirect_uri: Oauth::Callback.url_without_query_params,
    secret: "a1b2c3"
  }

  settings.oauth_client_ids = ["client-def456"]

  settings.oauth_token_endpoint = "https://samba.server/oauth/token"

  settings.oauth_token_introspection_endpoint =
    "https://samba.server/oauth/token/verify"

  settings.verify_oauth_token = ->(key : String, verify : -> OauthToken) do
    Dude.get(OauthToken, key, 30.seconds) { verify.call }
  end
end
