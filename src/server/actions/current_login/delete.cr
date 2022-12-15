module Samba::CurrentLogin::Delete
  macro included
    include Samba::CurrentLogin::Destroy

    # get "/logout" do
    #   run_operation
    # end

    def run_operation
      DeleteCurrentOauthLogin.delete(
        login,
        oauth_client_ids: oauth_client_ids,
        session: session
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
