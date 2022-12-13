require "../../../../spec_helper"

describe Samba::Api::BearerLoginPipes do
  describe "#require_logged_in" do
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

      WebMock.stub(:POST, Samba.settings.token_introspection_endpoint)
        .with(headers: {"Content-Type" => "application/x-www-form-urlencoded"})
        .to_return(body: body)

      client = ApiClient.new.api_auth(user, "a1b2c3")

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
          "client_id": "#{Samba.settings.client.try(&.[:id])}",
          "iss": "https://id.grottopress.com",
          "scope": "non.existent.scope",
          "sub": "#{user.remote_id}",
          "token_type": "Bearer"
        }
        JSON

      WebMock.stub(:POST, Samba.settings.token_introspection_endpoint)
        .with(headers: {"Content-Type" => "application/x-www-form-urlencoded"})
        .to_return(body: body)

      client = ApiClient.new.api_auth(user, "a1b2c3")
      response = client.exec(Api::CurrentUser::Show)

      response.should send_json(403, message: "action.pipe.not_logged_in")

      response.headers["WWW-Authenticate"]?
        .should(eq %(Bearer error="insufficient_scope", \
          scope="samba.current_user.show"))
    end
  end

  describe "#require_logged_out" do
    it "requires user to be logged out" do
      client = ApiClient.new
      client.api_auth(5678, "g7h8i9", "samba.current_user.create")

      response = client.exec(Api::CurrentUser::Create)

      response.should send_json(200, message: "action.pipe.not_logged_out")
    end
  end

  describe "#check_authorization" do
    it "checks authorization" do
      user = UserFactory.create

      client = ApiClient.new.api_auth(user, "g7h8i9", "samba.users.show")
      response = client.exec(Api::Users::Show.with(user_id: user.id))

      response.should send_json(
        403,
        message: "action.pipe.authorization_failed"
      )
    end
  end
end
