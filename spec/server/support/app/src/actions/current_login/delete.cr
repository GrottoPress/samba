class CurrentLogin::Delete < BrowserAction
  include Samba::CurrentLogin::Delete

  get "/logout/delete" do
    run_operation
  end

  def do_run_operation_succeeded(operation, login)
    response.headers["X-Current-Login"] = "0"
    previous_def
  end
end
