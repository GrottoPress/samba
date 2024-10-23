require "../../../../../spec_helper"

class Spec::Api::Oauth::Token::Pipes < PublicApi
  include Samba::Api::Oauth::Token::Pipes

  before :oauth_require_code
  before :oauth_verify_state

  param code : String? = nil
  param state : String? = nil

  get "/spec/api/oauth/token/pipes" do
    json({status: "success"})
  end
end

describe Samba::Api::Oauth::Token::Pipes do
  describe "#oauth_require_code" do
    it "requires code" do
      response = ApiClient.exec(Spec::Api::Oauth::Token::Pipes, state: "state")

      response.should send_json(
        400,
        error: "invalid_request",
        error_description: "action.pipe.oauth.code_required"
      )
    end
  end

  describe "#oauth_verify_state" do
    it "verifies state" do
      response = ApiClient.exec(Spec::Api::Oauth::Token::Pipes, code: "code")

      response.should send_json(
        403,
        error: "invalid_request",
        error_description: "action.pipe.oauth.state_invalid"
      )
    end
  end
end
