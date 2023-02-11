require "../../../../spec_helper"

class Spec::CurrentUser::Show < PrivateApi
  skip :require_logged_out

  get "/spec/account" do
    json UserSerializer.new
  end

  def authorize?(user : User) : Bool
    true
  end
end

class Spec::CurrentUser::Create < PrivateApi
  skip :require_logged_in

  post "/spec/account" do
    json UserSerializer.new
  end

  def authorize?(user : User) : Bool
    true
  end
end

class Spec::Users::Index < PrivateApi
  skip :require_logged_out

  get "/spec/users" do
    json UserSerializer.new
  end
end

describe Samba::Api::LoginPipes do
  describe "#require_logged_in" do
    it "requires access token" do
      response = ApiClient.exec(Spec::CurrentUser::Show)

      response.should send_json(401, message: "action.pipe.not_logged_in")
      response.headers["WWW-Authenticate"]?.should eq("Bearer")
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

      client = ApiClient.new.api_auth(user)

      response = client.exec(Spec::CurrentUser::Show)

      response.should send_json(401, message: "action.pipe.not_logged_in")

      response.headers["WWW-Authenticate"]?
        .should(eq %(Bearer error="invalid_token"))
    end
  end

  describe "#require_logged_out" do
    it "requires user to be logged out" do
      client = ApiClient.new

      client.api_auth(5678)

      response = client.exec(Spec::CurrentUser::Create)

      response.should send_json(200, message: "action.pipe.not_logged_out")
    end
  end

  describe "#check_authorization" do
    it "checks authorization" do
      client = ApiClient.new
      client.api_auth(5678)

      response = client.exec(Spec::Users::Index)

      response.should send_json(
        403,
        message: "action.pipe.authorization_failed"
      )
    end
  end
end
