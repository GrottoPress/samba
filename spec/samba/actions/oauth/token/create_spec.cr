require "../../../../spec_helper"

describe Samba::Oauth::Token::Create do
  it "creates OAuth token" do
    client = Samba.settings.client.not_nil!
    code = "code"
    code_verifier = "code-verifier"
    state = "state"
    sub = "1234"

    session = Lucky::Session.new
    session.set(:oauth_code_verifier, code_verifier)
    session.set(:oauth_state, state)

    api_client = ApiClient.new
    api_client.set_cookie_from_session(session)

    body = <<-JSON
      {
        "access_token": "access-token",
        "azp": "#{client[:id]}",
        "scope": "samba.current_user.show sso",
        "sub": "#{sub}",
        "token_type": "Bearer"
      }
      JSON

    WebMock.stub(:POST, Samba.settings.token_endpoint)
      .with(
        headers: {"Content-Type" => "application/x-www-form-urlencoded"},
        body: URI::Params.encode({
          code: code,
          client_id: client[:id],
          client_secret: client[:secret],
          code_verifier: code_verifier,
          grant_type: "authorization_code",
          redirect_uri: client[:redirect_uri],
        })
      )
      .to_return(body: body)

    response = api_client.exec(Oauth::Callback, code: code, state: state)

    response.status.should eq(HTTP::Status::FOUND)
    response.headers["Location"]?.should(eq CurrentUser::Show.path)

    # ameba:disable Performance/AnyInsteadOfEmpty
    UserQuery.new.remote_id(sub).any?.should be_true
  end
end
