class Api::CurrentLogin::Delete < PrivateApi
  include Samba::Api::CurrentLogin::Delete

  delete "/login/delete" do
    run_operation
  end
end
