# A user may not be in this client's database yet, although they may be
#  registered on the authorization server.
#
# This module is useful for when you only need to check that a user is logged in
# on the authorization server.
module Samba::RemoteLoginPipes
  macro included
    include Shield::ActionPipes

    before :disable_caching
    before :require_logged_in
    before :require_logged_out
    before :check_authorization

    def require_logged_in
      if remote_logged_in?
        continue
      else
        ReturnUrlSession.new(session).set(request)
        response.status_code = 403
        do_require_logged_in_failed
      end
    end

    def require_logged_out
      if remote_logged_out?
        continue
      else
        do_require_logged_out_failed
      end
    end

    def check_authorization
      if remote_logged_out? ||
        logged_in? && authorize?(current_user) ||
        remote_logged_in? && authorize?(oauth_token)

        continue
      else
        response.status_code = 403
        do_check_authorization_failed
      end
    end

    def authorize?(oauth_token : OauthToken) : Bool
      false
    end
  end
end
