abstract class PrivateApi < Lucky::Action
  include Samba::Api::LoginHelpers
  include Samba::Api::LoginPipes

  accepted_formats [:json]

  route_prefix "/api"
end
