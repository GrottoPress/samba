abstract class PublicApi < Lucky::Action
  include Shield::ApiAction
  include Shield::Api::BearerLoginHelpers
  include Shield::Api::BearerLoginPipes

  skip :pin_login_to_ip_address

  accepted_formats [:json]

  disable_cookies

  route_prefix "/api/v0"

  def bearer_scope : String
    name = BearerScope.new(self.class).name
    "server.#{name.lchop("api.")}"
  end
end
