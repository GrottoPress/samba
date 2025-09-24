module Samba::Api::BearerLoginHelpers
  macro included
    include Samba::Api::LoginHelpers

    # NOTE:
    #   A user may be logged in by the server, but may have no record in the
    #   client's database
    def bearer_logged_in? : Bool
      bearer_login_headers.verify?(bearer_scope) == true
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

    getter? oauth_token : OauthToken? do
      bearer_login_headers.oauth_token?
    end

    private getter bearer_login_headers do
      BearerLoginHeaders.new(context)
    end
  end
end
