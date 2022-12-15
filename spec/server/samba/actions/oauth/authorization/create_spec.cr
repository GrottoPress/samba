require "../../../../spec_helper"

describe Samba::Oauth::Authorization::Create do
  it "creates OAuth authorization" do
    password = "password4APASSWORD<"
    redirect_uri = "http://samba.client/oauth/callback"

    resource_owner = UserFactory.create &.email("resource@owner.com")
      .password(password)

    developer = UserFactory.create
    oauth_client = OauthClientFactory.create &.user_id(developer.id)
      .redirect_uris([redirect_uri])

    client = ApiClient.new
    client.browser_auth(resource_owner, password)

    response = client.exec(
      Oauth::Authorization::Create,
      oauth_grant: {
        granted: true,
        code_challenge: "a1b2c3",
        code_challenge_method: "plain",
        scopes: ["sso"],
        oauth_client_id: oauth_client.id,
        redirect_uri: redirect_uri,
        response_type: "code",
        state: "abcdef"
      }
    )

    response.status.should eq(HTTP::Status::FOUND)
    response.headers["X-OAuth-Grant-ID"]?.should_not be_nil

    session = ApiClient.session_from_cookies(response.cookies)

    LoginOauthClientsSession.new(session)
      .client_ids
      .should(contain oauth_client.id)
  end
end
