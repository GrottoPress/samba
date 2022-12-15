Shield.configure do |settings|
  settings.oauth_access_token_scopes_allowed = [
    "sso",
    "server.current_user.show"
  ]

  settings.oauth_code_challenge_methods_allowed = ["plain", "S256"]
end
