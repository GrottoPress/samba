module Samba::Api::BearerLoginPipes
  macro included
    include Samba::Api::LoginPipes

    def require_logged_in
      if logged_in? || bearer_logged_in?
        continue
      else
        send_invalid_token_response
        do_require_logged_in_failed
      end
    end

    def require_logged_out
      if logged_out? && bearer_logged_out?
        continue
      else
        do_require_logged_out_failed
      end
    end

    def check_authorization
      if logged_out? && bearer_logged_out? ||
        current_user? && authorize?(current_user) ||
        current_bearer? && authorize?(current_bearer) ||
        current_user?.nil? && authorize? ||
        current_bearer?.nil? && authorize?

        continue
      else
        response.status_code = 403
        do_check_authorization_failed
      end
    end

    private def send_invalid_token_response
      unless OauthToken.raw_token?(request)
        response.status_code = 401
        return response.headers["WWW-Authenticate"] = %(Bearer)
      end

      if bearer_login_headers.verify?
        response.status_code = 403
        response.headers["WWW-Authenticate"] =
          %(Bearer error="insufficient_scope", scope="#{bearer_scope}")
      else
        response.status_code = 401
        response.headers["WWW-Authenticate"] = %(Bearer error="invalid_token")
      end
    end
  end
end
