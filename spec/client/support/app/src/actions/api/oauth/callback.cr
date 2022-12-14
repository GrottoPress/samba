class Api::Oauth::Callback < PublicApi
  include Samba::Api::Oauth::Token::Create

  post "/oauth/callback" do
    run_operation
  end
end
