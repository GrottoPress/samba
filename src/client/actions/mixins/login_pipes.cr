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
        ReturnUrlSession.new(session).set(request)
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
      if logged_out? ||
        current_user? && authorize?(current_user) ||
        current_user?.nil? && authorize?

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

    # This sends out a new authorization code request that kicks off the
    # whole auto login process
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

    macro authorize(&block)
      {% verbatim do %}
        {% arg_count = block.args.size %}
        {% max_arg_count = 0 %}

        {% if arg_count > max_arg_count %}
          {% block.raise "too many block parameters (given #{arg_count}, \
            expected maximum #{max_arg_count})" %}
        {% end %}

        {% body = block.body.id.gsub(/super\(\)/, "super") %}
        {% body = body.gsub(/previous_def\(\)/, "previous_def") %}

        def authorize? : Bool?
          {{ body }}
        end
      {% end %}
    end

    macro authorize_user(&block)
      {% verbatim do %}
        {% arg_count = block.args.size %}

        {% if arg_count > 1 %}
          {% block.raise "too many block parameters (given #{arg_count}, \
            expected maximum 1)" %}
        {% end %}

        {% arg = block.args.first %}
        {% arg = !arg || arg == "_".id ? "__".id : arg %}
        {% body = block.body.id.gsub(/super\(\)/, "super") %}
        {% body = body.gsub(/previous_def\(\)/, "previous_def") %}

        def authorize?({{ arg }} : User) : Bool?
          {{ body }}
        end
      {% end %}
    end

    authorize_user { false }

    authorize { false }
  end
end
