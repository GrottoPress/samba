abstract class PrivateApi < Lucky::Action
  include Shield::ApiAction
  include Shield::Api::LoginHelpers
  include Shield::Api::LoginPipes

  skip :pin_login_to_ip_address

  accepted_formats [:json]

  disable_cookies

  route_prefix "/api"
end
