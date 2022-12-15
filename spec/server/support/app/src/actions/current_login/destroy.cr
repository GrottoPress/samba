class CurrentLogin::Destroy < BrowserAction
  include Samba::CurrentLogin::Destroy

  get "/logout" do
    run_operation
  end

  def do_run_operation_succeeded(operation, login)
    response.headers["X-Current-Login"] = "0"
    previous_def
  end
end
