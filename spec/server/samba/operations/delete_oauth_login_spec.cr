require "../../spec_helper"

describe Samba::DeleteOauthLogin do
  it "deletes login tokens" do
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

    BearerLoginFactory.create &.user_id(developer.id)
      .oauth_client_id(oauth_client.id)
      .scopes(["sso"])

    DeleteCurrentOauthLogin.delete(
      login,
      params(oauth_client_ids: [oauth_client.id]),
      session: nil
    ) do |operation, _|
      operation.deleted?.should be_true
    end

    # ameba:disable Performance/AnyInsteadOfEmpty
    LoginQuery.new.any?.should be_false

    BearerLoginQuery.new
      .user_id(resource_owner.id)
      .oauth_client_id(oauth_client.id)
      .id(login_token.id)
      .any? # ameba:disable Performance/AnyInsteadOfEmpty
      .should(be_false)

    BearerLoginQuery.new
      .user_id(resource_owner.id)
      .oauth_client_id(oauth_client.id)
      .id(regular_token.id)
      .any? # ameba:disable Performance/AnyInsteadOfEmpty
      .should(be_true)

    BearerLoginQuery.new
      .user_id(developer.id)
      .oauth_client_id(oauth_client.id)
      .is_active
      .any? # ameba:disable Performance/AnyInsteadOfEmpty
      .should(be_true)
  end
end
