require "../../spec_helper"

describe Samba::StartLoginOauthGrant do
  it "sets client ID in session" do
    redirect_uri = "http://samba.client/oauth/callback"

    resource_owner = UserFactory.create &.email("resource@owner.com")

    developer = UserFactory.create
    oauth_client = OauthClientFactory.create &.user_id(developer.id)
      .redirect_uris([redirect_uri])

    session = Lucky::Session.new

    StartLoginOauthGrant.create(
      params(
        granted: true,
        code_challenge: "code_challenge",
        code_challenge_method: "S256",
        redirect_uri: redirect_uri
      ),
      scopes: ["sso"],
      type: OauthGrantType.new(OauthGrantType::AUTHORIZATION_CODE),
      oauth_client: oauth_client,
      user: resource_owner,
      session: session
    ) do |_, oauth_grant|
      oauth_grant.should be_a(OauthGrant)
    end

    LoginOauthClientsSession.new(session)
      .client_ids
      .should(contain oauth_client.id)
  end

  it "does not set client ID in session if not an authentication request" do
    redirect_uri = "http://samba.client/oauth/callback"

    resource_owner = UserFactory.create &.email("resource@owner.com")

    developer = UserFactory.create
    oauth_client = OauthClientFactory.create &.user_id(developer.id)
      .redirect_uris([redirect_uri])

    session = Lucky::Session.new

    StartLoginOauthGrant.create(
      params(
        granted: true,
        code_challenge: "code_challenge",
        code_challenge_method: "S256",
        redirect_uri: redirect_uri
      ),
      scopes: ["server.current_user.show"],
      type: OauthGrantType.new(OauthGrantType::AUTHORIZATION_CODE),
      oauth_client: oauth_client,
      user: resource_owner,
      session: session
    ) do |_, oauth_grant|
      oauth_grant.should be_a(OauthGrant)
    end

    LoginOauthClientsSession.new(session).client_ids.should be_empty
  end
end
