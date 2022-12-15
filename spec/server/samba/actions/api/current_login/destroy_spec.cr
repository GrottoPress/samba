require "../../../../spec_helper"

describe Samba::Api::CurrentLogin::Destroy do
  it "logs user out" do
    password = "password4APASSWORD<"

    resource_owner = UserFactory.create &.email("resource@owner.com")
      .password(password)

    developer = UserFactory.create
    oauth_client = OauthClientFactory.create &.user_id(developer.id)

    login_token = BearerLoginFactory.create &.user_id(resource_owner.id)
      .oauth_client_id(oauth_client.id)
      .scopes(["sso"])

    login_token.status.active?.should be_true

    client = ApiClient.new
    client.api_auth(resource_owner, password)

    response = client.exec(Api::CurrentLogin::Destroy, login: {
      oauth_client_ids: [oauth_client.id]
    })

    response.should send_json(200, {
      message: "action.current_login.destroy.success"
    })

    login_token.reload.status.inactive?.should be_true
  end
end
