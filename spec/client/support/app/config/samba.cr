Samba.configure do |settings|
  settings.authorization_endpoint = "https://my.app/oauth/authorize"

  settings.client = {
    id: "client-abc123",
    redirect_uri: Oauth::Callback.url_without_query_params,
    secret: "a1b2c3"
  }

  settings.client_ids = ["client-def456"]

  settings.token_endpoint = "https://my.app/oauth/token"
  settings.token_introspection_endpoint = "https://my.app/oauth/token"

  settings.verify_token = ->(key : String, verify : -> OauthToken) do
    Dude.get(OauthToken, key, 30.seconds) { verify.call }
  end
end
