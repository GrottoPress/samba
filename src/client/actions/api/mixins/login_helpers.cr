module Samba::Api::LoginHelpers
  macro included
    include Samba::LoginHelpers

    getter? current_user : User? do
      login_headers.verify
    end

    getter? oauth_token : OauthToken? do
      login_headers.oauth_token?
    end

    private getter login_headers do
      LoginHeaders.new(context)
    end

    def bearer_logged_in? : Bool
      !bearer_logged_out?
    end

    def bearer_logged_out? : Bool
      current_bearer?.nil?
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
  end
end
