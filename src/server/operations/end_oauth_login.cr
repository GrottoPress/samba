module Samba::EndOauthLogin
  macro included
    include Shield::EndLogin

    attribute oauth_client_ids : Array(OauthClient::PrimaryKeyType)

    after_save revoke_login_tokens

    private def revoke_login_tokens(login : Shield::Login)
      oauth_client_ids.value.try do |value|
        return if value.empty?

        BearerLoginQuery.new
          .user_id(login.user_id)
          .oauth_client_id.in(value)
          .where("'#{Samba::SCOPE}' = ANY(scopes)")
          .is_active
          .update(inactive_at: Time.utc)
      end
    end
  end
end
