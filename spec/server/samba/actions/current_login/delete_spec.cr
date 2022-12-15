require "../../../spec_helper"

describe Samba::CurrentLogin::Delete do
  it "logs user out" do
    password = "password4APASSWORD<"

    resource_owner = UserFactory.create &.email("resource@owner.com")
      .password(password)

    developer = UserFactory.create
    oauth_client = OauthClientFactory.create &.user_id(developer.id)

    BearerLoginFactory.create &.user_id(resource_owner.id)
      .oauth_client_id(oauth_client.id)
      .scopes(["sso"])

    client = ApiClient.new
    client.browser_auth(resource_owner, password)

    response = client.exec(CurrentLogin::Delete.with(
      client_id: oauth_client.id
    ))

    response.status.should eq(HTTP::Status::FOUND)
    response.headers["X-Current-Login"]?.should eq("0")

    BearerLoginQuery.new
      .user_id(resource_owner.id)
      .oauth_client_id(oauth_client.id)
      .any? # ameba:disable Performance/AnyInsteadOfEmpty
      .should(be_false)
  end
end
