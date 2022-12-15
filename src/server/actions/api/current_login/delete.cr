module Samba::Api::CurrentLogin::Delete
  macro included
    include Samba::Api::CurrentLogin::Destroy

    # delete "/login" do
    #   run_operation
    # end

    def run_operation
      DeleteCurrentOauthLogin.delete(
        login,
        params,
        session: nil
      ) do |operation, deleted_login|
        if operation.deleted?
          do_run_operation_succeeded(operation, deleted_login.not_nil!)
        else
          response.status_code = 400
          do_run_operation_failed(operation)
        end
      end
    end
  end
end
