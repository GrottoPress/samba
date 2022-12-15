class Oauth::Authorization::Create < BrowserAction
  include Samba::Oauth::Authorization::Create

  post "/oauth/authorization" do
    run_operation
  end

  def do_run_operation_succeeded(operation, oauth_grant)
    response.headers["X-OAuth-Grant-ID"] = oauth_grant.id.to_s
    previous_def
  end
end
