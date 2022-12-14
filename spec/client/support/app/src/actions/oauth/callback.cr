class Oauth::Callback < BrowserAction
  include Samba::Oauth::Token::Create

  get "/oauth/callback" do
    run_operation
  end
end
