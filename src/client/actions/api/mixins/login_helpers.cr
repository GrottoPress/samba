module Samba::Api::LoginHelpers
  macro included
    include Samba::LoginHelpers

    # NOTE:
    #   A user may be logged in by the server, but may have no record in the
    #   client's database
    def logged_in? : Bool
      login_headers.verify? == true
    end

    getter? current_user : User? do
      login_headers.verify
    end

    getter? oauth_token : OauthToken? do
      login_headers.oauth_token?
    end

    def bearer_logged_in? : Bool
      false
    end

    def bearer_logged_out? : Bool
      !bearer_logged_in?
    end

    def current_user_or_bearer : User
      current_user_or_bearer?.not_nil!
    end

    def current_user_or_bearer? : User?
      current_user? || current_bearer?
    end

    def current_bearer : User
      current_bearer?.not_nil!
    end

    def current_bearer? : User?
      nil
    end

    private getter login_headers do
      LoginHeaders.new(context)
    end
  end
end
