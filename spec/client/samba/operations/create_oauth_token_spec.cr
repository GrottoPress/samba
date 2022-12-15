require "../../spec_helper"

describe Samba::CreateOauthToken do
  it "creates oauth token" do
    WebMock.allow_net_connect = false

    access_token = "access-token"
    client_id = "client-id"
    client_secret = "client-secret"
    code = "code"
    code_verifier = "code-verifier"
    redirect_uri = "http://redirect.uri"
    sub = "5678"

    body = <<-JSON
      {
        "access_token": "#{access_token}",
        "azp": "#{client_id}",
        "scope": "sso client.current_user.show sika.logins.show",
        "sub": "#{sub}",
        "token_type": "Bearer"
      }
      JSON

    WebMock.stub(:POST, Samba.settings.token_endpoint)
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

    session = Lucky::Session.new

    CreateOauthToken.run(
      nested_params(oauth_token: {
        client_id: client_id,
        client_secret: client_secret,
        code: code,
        code_verifier: code_verifier,
        redirect_uri: redirect_uri
      }),
      session: session
    ) do |operation, oauth_token|
      operation.valid?.should be_true

      oauth_token.should be_a(OauthToken)
      LoginSession.new(session).raw_token?.should eq(access_token)

      # ameba:disable Performance/AnyInsteadOfEmpty
      UserQuery.new.remote_id(sub).any?.should be_true
    end
  end

  it "requires authorization code" do
    CreateOauthToken.run(
      nested_params(oauth_token: {
        client_id: "client-id",
        client_secret: "client-secret",
        code_verifier: "code-verifier",
        redirect_uri: "http://redirect.uri"
      }),
      session: nil
    ) do |operation, oauth_token|
      oauth_token.should be_nil

      operation.code.should have_error("operation.error.code_required")
    end
  end

  it "requires client ID" do
    CreateOauthToken.run(
      nested_params(oauth_token: {
        client_secret: "client-secret",
        code: "code",
        code_verifier: "code-verifier",
        redirect_uri: "http://redirect.uri",
        session: nil
      }),
      session: nil
    ) do |operation, oauth_token|
      oauth_token.should be_nil

      operation.client_id
        .should(have_error "operation.error.client_id_required")
    end
  end

  it "requires client secret" do
    CreateOauthToken.run(
      nested_params(oauth_token: {
        client_id: "client-id",
        code: "code",
        code_verifier: "code-verifier",
        redirect_uri: "http://redirect.uri"
      }),
      session: nil
    ) do |operation, oauth_token|
      oauth_token.should be_nil

      operation.client_secret
        .should(have_error "operation.error.client_secret_required")
    end
  end

  it "requires redirect URI" do
    CreateOauthToken.run(
      nested_params(oauth_token: {
        client_id: "client-id",
        client_secret: "client-secret",
        code: "code",
        code_verifier: "code-verifier"
      }),
      session: nil
    ) do |operation, oauth_token|
      oauth_token.should be_nil

      operation.redirect_uri
        .should(have_error "operation.error.redirect_uri_required")
    end
  end
end
