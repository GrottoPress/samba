module Samba::LoginPipes
  macro included
    include Shield::ActionPipes

    before :disable_caching
    before :require_logged_in
    before :require_logged_out
    before :check_authorization

    def require_logged_in
      if logged_in?
        continue
      else
        response.status_code = 403
        do_require_logged_in_failed
      end
    end

    def require_logged_out
      if logged_out?
        continue
      else
        do_require_logged_out_failed
      end
    end

    def check_authorization
      if logged_out? || authorize?(current_user)
        continue
      else
        response.status_code = 403
        do_check_authorization_failed
      end
    end

    def disable_caching
      response.headers["Cache-Control"] = "no-store"
      response.headers["Expires"] = "Sun, 16 Aug 1987 07:00:00 GMT"
      response.headers["Pragma"] = "no-cache"

      continue
    end

    def do_require_logged_in_failed
      redirect to: OauthAuthorizationEndpoint.redirect_url(session)
    end

    def do_require_logged_out_failed
      flash.info = Rex.t(:"action.pipe.not_logged_out")
      redirect_back fallback: CurrentUser::Show
    end

    def do_check_authorization_failed
      flash.failure = Rex.t(:"action.pipe.authorization_failed")
      redirect_back fallback: CurrentUser::Show
    end

    def authorize?(user : User) : Bool
      false
    end
  end
end
