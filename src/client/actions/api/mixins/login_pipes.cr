module Samba::Api::LoginPipes
  macro included
    include Samba::LoginPipes

    def require_logged_in
      if logged_in?
        continue
      else
        send_invalid_token_response
        do_require_logged_in_failed
      end
    end

    def do_require_logged_in_failed
      json FailureSerializer.new(message: Rex.t(:"action.pipe.not_logged_in"))
    end

    def do_require_logged_out_failed
      json FailureSerializer.new(message: Rex.t(:"action.pipe.not_logged_out"))
    end

    def do_check_authorization_failed
      json FailureSerializer.new(
        message: Rex.t(:"action.pipe.authorization_failed")
      )
    end

    private def send_invalid_token_response
      response.status_code = 401

      if OauthToken.raw_token?(request)
        response.headers["WWW-Authenticate"] = %(Bearer error="invalid_token")
      else
        response.headers["WWW-Authenticate"] = %(Bearer)
      end
    end
  end
end
