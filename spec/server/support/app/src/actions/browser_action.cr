abstract class BrowserAction < Lucky::Action
  include Shield::BrowserAction
  include Shield::LoginHelpers
  include Shield::LoginPipes

  skip :pin_login_to_ip_address
  skip :protect_from_forgery

  accepted_formats [:html]

  def do_require_logged_in_failed
    response.headers["X-Logged-In"] = "false"
    previous_def
  end

  def do_require_logged_out_failed
    response.headers["X-Logged-In"] = "true"
    previous_def
  end

  def do_check_authorization_failed
    response.headers["X-Authorized"] = "false"
    previous_def
  end
end
