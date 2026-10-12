require "../spec_helper"

describe Samba::HttpClient do
  it "allows overriding mock claims" do
    user = UserFactory.create

    client = ApiClient.new.api_auth(user, claims: {active: false})
    response = client.exec(Api::CurrentUser::Show)

    response.should send_json(401)
  end
end
