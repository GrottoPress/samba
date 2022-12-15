class Api::CurrentLogin::Destroy < PrivateApi
  include Samba::Api::CurrentLogin::Destroy

  delete "/login" do
    run_operation
  end
end
