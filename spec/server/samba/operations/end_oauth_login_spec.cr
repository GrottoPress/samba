require "../../spec_helper"

describe Samba::EndOauthLogin do
  it "deactivates login tokens" do
    resource_owner = UserFactory.create &.email("resource@owner.com")
    developer = UserFactory.create
    oauth_client = OauthClientFactory.create &.user_id(developer.id)
    login = LoginFactory.create &.user_id(resource_owner.id)

    login_token = BearerLoginFactory.create &.user_id(resource_owner.id)
      .oauth_client_id(oauth_client.id)
      .scopes(["sso"])

    regular_token = BearerLoginFactory.create &.user_id(resource_owner.id)
      .oauth_client_id(oauth_client.id)
      .scopes(["server.current_user.show"])

    dev_token = BearerLoginFactory.create &.user_id(developer.id)
      .oauth_client_id(oauth_client.id)
      .scopes(["sso"])

    login.status.active?.should be_true
    login_token.status.active?.should be_true
    regular_token.status.active?.should be_true
    dev_token.status.active?.should be_true

    EndCurrentOauthLogin.update(
      login,
      params(oauth_client_ids: [oauth_client.id]),
      session: nil
    ) do |operation, _|
      operation.saved?.should be_true
    end

    login.reload.status.inactive?.should be_true
    login_token.reload.status.inactive?.should be_true
    regular_token.reload.status.active?.should be_true
    dev_token.reload.status.active?.should be_true
  end
end
