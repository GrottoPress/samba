module Samba::CurrentLogin::Destroy
  macro included
    skip :require_logged_out

    param client_id : OauthClient::PrimaryKeyType? = nil

    # get "/logout" do
    #   run_operation
    # end

    def run_operation
      EndCurrentOauthLogin.update(
        login,
        oauth_client_ids: oauth_client_ids,
        session: session
      ) do |operation, updated_login|
        if operation.saved?
          do_run_operation_succeeded(operation, updated_login)
        else
          response.status_code = 400
          do_run_operation_failed(operation)
        end
      end
    end

    def do_run_operation_succeeded(operation, login)
      flash.success = Rex.t(:"action.current_login.destroy.success")
      redirect(request.headers["Referer"]? || New)
    end

    def do_run_operation_failed(operation)
      flash.failure = Rex.t(:"action.current_login.destroy.failure")
      redirect_back fallback: CurrentUser::Show
    end

    def login
      current_login
    end

    def authorize?(user : User) : Bool
      user.id == login.user_id
    end

    private getter oauth_client_ids : Array(OauthClient::PrimaryKeyType) do
      LoginOauthClientsSession.new(session)
        .client_ids(delete: true)
        .tap do |ids|

        client_id.try { |id| ids << id unless ids.includes?(id) }
      end
    end
  end
end
