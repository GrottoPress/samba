require "../../../../../spec_helper"

describe Samba::Api::Oauth::Token::Create do
  it "creates OAuth token" do
    access_token = "access-token"
    client_id = "client-id"
    client_secret = "client-secret"
    code = "code"
    code_verifier = "code-verifier"
    redirect_uri = "https://redirect.uri"
    sub = "1234"

    body = <<-JSON
      {
        "access_token": "#{access_token}",
        "azp": "#{client_id}",
        "scope": "client.current_user.show sso",
        "sub": "#{sub}",
        "token_type": "Bearer"
      }
      JSON

    WebMock.stub(:POST, Samba.settings.oauth_token_endpoint)
      .with(
        headers: {"Content-Type" => "application/x-www-form-urlencoded"},
        body: URI::Params.encode({
          code: code,
          client_id: client_id,
          client_secret: client_secret,
          code_verifier: code_verifier,
          grant_type: "authorization_code",
          redirect_uri: redirect_uri,
        })
      )
      .to_return(body: body)

    response = ApiClient.exec(Api::Oauth::Callback, oauth_token: {
      client_id: client_id,
      client_secret: client_secret,
      code: code,
      code_verifier: code_verifier,
      redirect_uri: redirect_uri
    })

    response.should send_json(200, access_token: access_token)

    # ameba:disable Performance/AnyInsteadOfEmpty
    UserQuery.new.remote_id(sub).any?.should be_true
  end
end
