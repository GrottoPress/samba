require "../client"

class UserQuery < User::BaseQuery
end

class RegisterCurrentUser < User::SaveOperation
  include Samba::RegisterCurrentUser
end

class CreateOauthToken < Avram::Operation
  include Samba::CreateOauthToken
end

struct BearerLoginHeaders
  include Samba::BearerLoginHeaders
end

struct BearerScope
  include Shield::BearerScope
end

struct LoginHeaders
  include Samba::LoginHeaders
end

struct LoginSession
  include Samba::LoginSession
end

struct OauthAuthorizationEndpoint
  include Samba::OauthAuthorizationEndpoint
end

struct OauthCodeVerifierSession
  include Samba::OauthCodeVerifierSession
end

struct OauthStateSession
  include Samba::OauthStateSession
end

struct OauthToken
  include Samba::OauthToken
end

struct PageUrlSession
  include Shield::PageUrlSession
end

struct ReturnUrlSession
  include Shield::ReturnUrlSession
end

struct Sha256Hash
  include Shield::Sha256Hash
end
