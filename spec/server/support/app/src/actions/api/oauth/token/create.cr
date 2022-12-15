class Api::Oauth::Token::Create < PublicApi
  include Samba::Api::Oauth::Token::Create

  post "/oauth/token" do
    run_operation
  end
end
