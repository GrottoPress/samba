require "../../../spec_helper"

describe Samba::LoginPipes do
  describe "#require_logged_in" do
    it "requires access token" do
      response = ApiClient.exec(CurrentUser::Show)

      response.status.should eq(HTTP::Status::FOUND)
      response.headers["X-Logged-In"]?.should eq("false")
      response.headers["Location"]?.should_not be_nil

      response.headers["Location"]
        .should(start_with Samba.settings.authorization_endpoint)
    end

    it "verifies access token" do
      user = UserFactory.create

      body = <<-JSON
        {
          "active": false
        }
        JSON

      WebMock.stub(:POST, Samba.settings.token_introspection_endpoint)
        .with(headers: {"Content-Type" => "application/x-www-form-urlencoded"})
        .to_return(body: body)

      client = ApiClient.new.browser_auth(user, "a1b2c3")
      response = client.exec(CurrentUser::Show)

      response.status.should eq(HTTP::Status::FOUND)
      response.headers["X-Logged-In"]?.should eq("false")
      response.headers["Location"]?.should_not be_nil

      response.headers["Location"]
        .should(start_with Samba.settings.authorization_endpoint)
    end
  end

  describe "#require_logged_out" do
    it "requires user to be logged out" do
      client = ApiClient.new.browser_auth(5678, "g7h8i9")
      response = client.exec(CurrentUser::Create)

      response.headers["X-Logged-In"]?.should eq("true")
    end
  end

  describe "#check_authorization" do
    it "checks authorization" do
      user = UserFactory.create

      client = ApiClient.new.browser_auth(user, "g7h8i9")
      response = client.exec(Users::Show.with(user_id: user.id))

      response.headers["X-Authorized"]?.should eq("false")
    end
  end
end
