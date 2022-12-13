module Samba::LoginHelpers
  macro included
    include Shield::ActionHelpers

    def logged_in? : Bool
      !logged_out?
    end

    def logged_out? : Bool
      current_user?.nil?
    end

    def current_user : User
      current_user?.not_nil!
    end

    getter? current_user : User? do
      login_session.verify
    end

    def oauth_token : OauthToken
      oauth_token?.not_nil!
    end

    getter? oauth_token : OauthToken? do
      login_session.oauth_token?
    end

    private getter login_session do
      LoginSession.new(context)
    end
  end
end
