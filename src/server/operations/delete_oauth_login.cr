module Samba::DeleteOauthLogin
  macro included
    include Shield::DeleteLogin

    attribute oauth_client_ids : Array(OauthClient::PrimaryKeyType)

    after_delete delete_login_tokens

    private def delete_login_tokens(login : Shield::Login)
      oauth_client_ids.value.try do |value|
        return if value.empty?

        BearerLoginQuery.new
          .user_id(login.user_id)
          .oauth_client_id.in(value)
          .scopes.includes(Samba::SCOPE)
          .delete
      end
    end
  end
end
