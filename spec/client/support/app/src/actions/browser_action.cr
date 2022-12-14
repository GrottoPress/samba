abstract class BrowserAction < Lucky::Action
  include Samba::LoginHelpers
  include Samba::LoginPipes

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
