module Samba::Api::BearerLoginHelpers
  macro included
    include Samba::Api::LoginHelpers

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

    getter? current_bearer : User? do
      bearer_login_headers.verify(bearer_scope)
    end

    def oauth_token : OauthToken
      oauth_token?.not_nil!
    end

    getter? oauth_token : OauthToken? do
      bearer_login_headers.oauth_token?
    end

    private getter bearer_login_headers do
      BearerLoginHeaders.new(context)
    end
  end
end
