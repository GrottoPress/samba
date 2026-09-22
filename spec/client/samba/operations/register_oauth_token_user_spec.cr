require "../../spec_helper"

describe Samba::RegisterOauthTokenUser do
  it "registers user" do
    remote_id = 67890

    oauth_token = OauthToken.from_json({
      active: true,
      scope: "sso",
      sub: "#{remote_id}",
      token_type: "Bearer"
    }.to_json)

    RegisterOauthTokenUser.create(oauth_token) do |_, user|
      user.should be_a(User)

      user.try do |_user|
        _user.remote_id.should eq(remote_id)
      end
    end
  end
end
