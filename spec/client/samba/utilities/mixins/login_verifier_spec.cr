require "../../../spec_helper"

private struct LoginVerifier
  include Samba::LoginVerifier

  def initialize(@token : String)
  end

  def raw_token? : String?
    @token
  end
end

describe Samba::LoginVerifier do
  it "requires 'sso' scope" do
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
        "scope": "client.current_user.show sika.logins.show",
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

    LoginVerifier.new(token).verify.should be_nil
  end

  it "requires trusted client ID" do
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
        "client_id": "unknown-client",
        "iss": "https://samba.server",
        "scope": "client.current_user.show",
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

    LoginVerifier.new(token).verify.should be_nil
  end
end
