require "../../../spec_helper"

describe Samba::LoginPipes do
  describe "#require_logged_in" do
    it "allows valid token for existing user" do
      user = UserFactory.create

      client = ApiClient.new.browser_auth(user)
      response = client.exec(CurrentUser::Show)

      response.status.ok?.should be_true
      response.headers["Location"]?.should be_nil
    end

    it "allows valid token for non-existent user" do
      client = ApiClient.new.browser_auth(67890)
      response = client.exec(CurrentUser::Show)

      response.status.ok?.should be_true
      response.headers["Location"]?.should be_nil
    end

    it "requires access token" do
      response = ApiClient.exec(CurrentUser::Show)

      response.status.should eq(HTTP::Status::FOUND)
      response.headers["X-Logged-In"]?.should eq("false")
      response.headers["Location"]?.should_not be_nil

      client = Samba.settings.oauth_client.not_nil!

      pattern = "#{Samba.settings.oauth_authorization_endpoint}\\?\
        client_id=#{client[:id]}&\
        code_challenge=.+&\
        code_challenge_method=#{Samba.settings.oauth_code_challenge_method}&\
        redirect_uri=#{URI.encode_www_form(client[:redirect_uri])}&\
        response_type=code&scope=sso&state=.+"

      response.headers["Location"].should match(/^#{pattern}$/)
    end

    it "verifies access token" do
      user = UserFactory.create

      body = <<-JSON
        {
          "active": false
        }
        JSON

      WebMock.stub(:POST, Samba.settings.oauth_token_introspection_endpoint)
        .with(headers: {"Content-Type" => "application/x-www-form-urlencoded"})
        .to_return(body: body)

      client = ApiClient.new.browser_auth(user)
      response = client.exec(CurrentUser::Show)

      response.status.should eq(HTTP::Status::FOUND)
      response.headers["X-Logged-In"]?.should eq("false")
      response.headers["Location"]?.should_not be_nil

      client = Samba.settings.oauth_client.not_nil!

      pattern = "#{Samba.settings.oauth_authorization_endpoint}\\?\
        client_id=#{client[:id]}&\
        code_challenge=.+&\
        code_challenge_method=#{Samba.settings.oauth_code_challenge_method}&\
        redirect_uri=#{URI.encode_www_form(client[:redirect_uri])}&\
        response_type=code&scope=sso&state=.+"

      response.headers["Location"].should match(/^#{pattern}$/)
    end
  end

  describe "#require_logged_out" do
    it "requires user to be logged out" do
      client = ApiClient.new.browser_auth(5678)
      response = client.exec(CurrentUser::Create)

      response.headers["X-Logged-In"]?.should eq("true")
    end
  end

  describe "#check_authorization" do
    it "checks authorization" do
      user = UserFactory.create

      client = ApiClient.new.browser_auth(user)
      response = client.exec(Users::Show.with(user_id: user.id))

      response.headers["X-Authorized"]?.should eq("false")
    end
  end
end
