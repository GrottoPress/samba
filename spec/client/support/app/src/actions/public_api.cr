abstract class PublicApi < Lucky::Action
  include Samba::Api::BearerLoginHelpers
  include Samba::Api::BearerLoginPipes

  accepted_formats [:json]

  route_prefix "/api/v0"

  def bearer_scope : String
    name = BearerScope.new(self.class).name
    "samba.#{name.lchop("api.")}"
  end
end
