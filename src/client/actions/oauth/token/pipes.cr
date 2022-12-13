module Samba::Oauth::Token::Pipes
  macro included
    skip :require_logged_in
    skip :require_logged_out
    skip :check_authorization

    def oauth_require_code
      if code
        continue
      else
        response.status_code = 400
        do_oauth_require_code_failed
      end
    end

    def oauth_verify_state
      state_session = OauthStateSession.new(session)
      verified = state_session.verify?(state).tap { |_| state_session.delete }

      if verified
        continue
      else
        response.status_code = 403
        do_oauth_verify_state_failed
      end
    end

    def do_oauth_require_code_failed
      json({
        error: "invalid_request",
        error_description: Rex.t(:"action.pipe.oauth.code_required")
      })
    end

    def do_oauth_verify_state_failed
      json({
        error: "invalid_request",
        error_description: Rex.t(
          :"action.pipe.oauth.state_invalid",
          state: state
        )
      })
    end
  end
end
