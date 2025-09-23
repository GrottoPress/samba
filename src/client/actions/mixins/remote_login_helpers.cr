module Samba::RemoteLoginHelpers
  macro included
    def remote_logged_in? : Bool
      login_session.verify? == true
    end

    def remote_logged_out? : Bool
      !remote_logged_in?
    end

    private getter login_session do
      LoginSession.new(context)
    end
  end
end
