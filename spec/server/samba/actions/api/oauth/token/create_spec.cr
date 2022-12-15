require "../../../../../spec_helper.cr"

describe Samba::Api::Oauth::Token::Create do
  it "creates authentication token" do
    code = "a1b2c3"
    client_secret = "def456"
    code_challenge = "abc123"

    developer = UserFactory.create
    resource_owner = UserFactory.create &.email("resource@owner.com")

    oauth_client = OauthClientFactory.create &.user_id(developer.id)
      .secret(client_secret)

    oauth_grant =
      OauthGrantFactory.create &.user_id(resource_owner.id)
        .oauth_client_id(oauth_client.id)
        .code(code)
        .scopes(["sso"])
        .pkce(code_challenge, "plain")

    code_final = OauthGrantCredentials.new(
      code,
      oauth_grant.id
    ).to_s

    response = ApiClient.exec(
      Api::Oauth::Token::Create,
      client_id: oauth_client.id,
      code: code_final,
      redirect_uri: oauth_grant.redirect_uri,
      grant_type: OauthGrantType::AUTHORIZATION_CODE,
      code_verifier: code_challenge,
      client_secret: client_secret
    )

    response.should send_json(200)

    oauth_token = JSON.parse(response.body)

    oauth_token["aud"]?.should eq([oauth_client.id.to_s])
    oauth_token["azp"]?.should eq(oauth_client.id.to_s)
    oauth_token["refresh_token"]?.should be_nil
    oauth_token["sub"]?.should eq(resource_owner.id.to_s)
  end

  context "Client Credentials Grant" do
    it "denies login token requests" do
      client_secret = "def456"

      developer = UserFactory.create

      oauth_client = OauthClientFactory.create &.user_id(developer.id)
        .secret(client_secret)

      response = ApiClient.exec(
        Api::Oauth::Token::Create,
        client_id: oauth_client.id,
        grant_type: OauthGrantType::CLIENT_CREDENTIALS,
        client_secret: client_secret,
        scope: "sso"
      )

      response.should send_json(400, error: "invalid_scope")
    end

    context "Refresh Token Grant" do
      it "denies login token requests" do
        refresh_token = "a1b2c3"
        client_secret = "def456"

        resource_owner = UserFactory.create &.email("resource@owner.com")

        developer = UserFactory.create
        oauth_client = OauthClientFactory.create &.user_id(developer.id)
          .secret(client_secret)

        oauth_grant = OauthGrantFactory.create &.user_id(resource_owner.id)
          .oauth_client_id(oauth_client.id)
          .code(refresh_token)
          .scopes(["sso"])
          .type(OauthGrantType::REFRESH_TOKEN)

        refresh_token_final = OauthGrantCredentials.new(
          refresh_token,
          oauth_grant.id
        ).to_s

        response = ApiClient.exec(
          Api::Oauth::Token::Create,
          client_id: oauth_client.id,
          refresh_token: refresh_token_final,
          grant_type: OauthGrantType::REFRESH_TOKEN,
          client_secret: client_secret
        )

        response.should send_json(400, error: "invalid_scope")
      end
    end
  end
end
