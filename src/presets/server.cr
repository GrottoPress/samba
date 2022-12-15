require "../server"

class EndCurrentOauthLogin < Login::SaveOperation
  include Samba::EndOauthLogin
end

class DeleteCurrentOauthLogin < Login::DeleteOperation
  include Samba::DeleteOauthLogin
end

class StartLoginOauthGrant < OauthGrant::SaveOperation
  include Samba::StartLoginOauthGrant
end

struct LoginOauthClientsSession
  include Samba::LoginOauthClientsSession
end
