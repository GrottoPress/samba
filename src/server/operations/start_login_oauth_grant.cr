module Samba::StartLoginOauthGrant
  macro included
    include Shield::StartOauthGrant
    include Shield::SetSession

    private def set_session(oauth_grant : OauthGrant)
      session.try do |_session|
        return unless oauth_grant.scopes.includes?(Samba::SCOPE)
        LoginOauthClientsSession.new(_session).set(oauth_grant.oauth_client_id)
      end
    end
  end
end
