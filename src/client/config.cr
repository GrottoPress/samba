module Samba
  Habitat.create do
    setting authorization_endpoint : String
    setting client : {id: String, secret: String, redirect_uri: String}?
    setting client_ids : Array(String) = Array(String).new
    setting code_challenge_method : String = "S256"
    setting server_api_token : String? = nil
    setting token_endpoint : String
    setting token_introspection_endpoint : String
    setting verify_token : Proc(String, -> ::OauthToken, ::OauthToken)
  end
end
