require "../../../../spec_helper"

class Spec::Chickens::Create < PublicApi
  skip :require_logged_out

  post "/spec/chickens" do
    json UserSerializer.new
  end

  def authorize?(user : User) : Bool
    true
  end
end

class Spec::Chickens::Index < PublicApi
  skip :require_logged_out

  get "/spec/chickens" do
    json UserSerializer.new
  end

  def authorize? : Bool
    true
  end
end

describe Samba::Api::BearerLoginPipes do
  describe "#require_logged_in" do
    it "allows valid token for existing user" do
      user = UserFactory.create

      client = ApiClient.new.api_auth(user, "client.current_user.show")
      response = client.exec(Api::CurrentUser::Show)

      response.should send_json(200)
      response.headers["WWW-Authenticate"]?.should be_nil
    end

    it "allows valid token for non-existent user" do
      client = ApiClient.new.api_auth(67890, "client.current_user.show")
      response = client.exec(Api::CurrentUser::Show)

      response.should send_json(200)
      response.headers["WWW-Authenticate"]?.should be_nil
    end

    it "requires access token" do
      response = ApiClient.exec(Api::CurrentUser::Show)

      response.should send_json(401, message: "action.pipe.not_logged_in")
      response.headers["WWW-Authenticate"]?.should eq("Bearer")
    end

    it "requires active access token" do
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

      response = client.exec(Api::CurrentUser::Show)

      response.should send_json(401, message: "action.pipe.not_logged_in")

      response.headers["WWW-Authenticate"]?
        .should(eq %(Bearer error="invalid_token"))
    end

    it "checks access token scope" do
      user = UserFactory.create

      body = <<-JSON
        {
          "active": true,
          "client_id": "#{Samba.settings.oauth_client.try(&.[:id])}",
          "iss": "https://samba.server",
          "scope": "non.existent.scope",
          "sub": "#{user.remote_id}",
          "token_type": "Bearer"
        }
        JSON

      WebMock.stub(:POST, Samba.settings.oauth_token_introspection_endpoint)
        .with(headers: {"Content-Type" => "application/x-www-form-urlencoded"})
        .to_return(body: body)

      client = ApiClient.new.api_auth(user)
      response = client.exec(Api::CurrentUser::Show)

      response.should send_json(403, message: "action.pipe.not_logged_in")

      response.headers["WWW-Authenticate"]?
        .should(eq %(Bearer error="insufficient_scope", \
          scope="client.current_user.show"))
    end
  end

  describe "#require_logged_out" do
    it "requires user to be logged out" do
      client = ApiClient.new
      client.api_auth(5678, "client.current_user.create")

      response = client.exec(Api::CurrentUser::Create)

      response.should send_json(200, message: "action.pipe.not_logged_out")
    end
  end

  describe "#check_authorization" do
    it "checks authorization for existing user" do
      user = UserFactory.create

      client = ApiClient.new.api_auth(user, "client.spec.chickens.index")
      response = client.exec(Spec::Chickens::Index)

      response.should send_json(
        403,
        message: "action.pipe.authorization_failed"
      )
    end

    it "checks authorization for non-existing user" do
      client = ApiClient.new.api_auth(555, "client.spec.chickens.create")
      response = client.exec(Spec::Chickens::Create)

      response.should send_json(
        403,
        message: "action.pipe.authorization_failed"
      )
    end
  end
end
