# The Token endpoint
#
module Samba::Api::Oauth::Token::Create
  macro included
    include Shield::Api::Oauth::Token::Create

    # post "/oauth/token" do
    #   run_operation
    # end

    def do_run_operation_succeeded(operation, bearer_login)
      data = previous_def

      if bearer_login.scopes.includes?(Samba::SCOPE)
        data = data.merge({
          aud: [bearer_login.oauth_client_id.try(&.to_s)],
          azp: bearer_login.oauth_client_id.try(&.to_s),
          iss: Lucky::RouteHelper.settings.base_uri,
          refresh_token: nil, # Unsets refresh token
          sub: bearer_login.user_id.to_s,
        })
      end

      json(data)
    end

    # Deny access token requests for "{{ Samba::SCOPE }}" scope if grant
    # type is not "authorization_code"
    def oauth_validate_scope
      # Auth Code Grant token requests should not send `scope` at all
      if scopes.includes?(Samba::SCOPE) ||
        (oauth_grant? &&
          oauth_grant.scopes.includes?(Samba::SCOPE) &&
          !oauth_grant.type.authorization_code?)

        response.status_code = 400
        do_oauth_validate_scope_failed
      else
        previous_def
      end
    end
  end
end
