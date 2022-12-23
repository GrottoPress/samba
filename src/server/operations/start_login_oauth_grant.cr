module Samba::StartLoginOauthGrant
  macro included
    include Shield::StartOauthGrant
    include Shield::SetSession

    private def set_session(oauth_grant : OauthGrant)
      session.try do |_session|
        LoginOauthClientsSession.new(_session).set(oauth_grant)
      end
    end
  end
end
