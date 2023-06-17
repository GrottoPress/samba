require "../../spec_helper"

describe Samba::LoginHeaders do
  it "verifies OAuth access token" do
    WebMock.allow_net_connect = false

    client = Samba.settings.oauth_client
    client_id = client.try(&.[:id])
    client_secret = client.try(&.[:secret])

    sub = "5678"
    token = "g7h8i9"

    UserFactory.create &.remote_id(sub)

    body = <<-JSON
      {
        "active": true,
        "client_id": "#{client_id}",
        "iss": "https://samba.server",
        "scope": "sso client.current_user.show",
        "sub": "#{sub}",
        "token_type": "Bearer"
      }
      JSON

    WebMock.stub(:POST, Samba.settings.oauth_token_introspection_endpoint)
      .with(
        headers: {"Content-Type" => "application/x-www-form-urlencoded"},
        body: URI::Params.encode({
          token: token,
          client_id: client_id,
          client_secret: client_secret
        })
      )
      .to_return(body: body)

    headers = HTTP::Headers{"Authorization" => "Bearer #{token}"}

    LoginHeaders.new(headers).verify.should be_a(User)
  end
end
