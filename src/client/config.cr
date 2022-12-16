module Samba
  Habitat.create do
    setting login_token_scopes : Array(String) = Array(String).new
    setting oauth_authorization_endpoint : String
    setting oauth_client : {id: String, secret: String, redirect_uri: String}?
    setting oauth_client_ids : Array(String) = Array(String).new
    setting oauth_code_challenge_method : String = "S256"
    setting oauth_token_endpoint : String
    setting oauth_token_introspection_endpoint : String
    setting server_api_token : String? = nil
    setting verify_oauth_token : Proc(String, -> ::OauthToken, ::OauthToken)
  end
end
