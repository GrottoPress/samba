# This OAuth client's redirect URL
#
# This action's URL is what we set as the redirect URI when we register
# this client with the Authorization server
module Samba::Oauth::Token::Create
  macro included
    include Samba::Oauth::Token::Pipes

    before :oauth_require_code
    before :oauth_verify_state

    param code : String?
    param state : String?

    # get "/oauth/callback" do
    #   run_operation
    # end

    def run_operation
      CreateOauthToken.run(
        code: code.not_nil!,
        client_id: client[:id],
        client_secret: client[:secret],
        redirect_uri: client[:redirect_uri],
        code_verifier: code_verifier.to_s,
        session: session
      ) do |operation, oauth_token|
        return error_response(oauth_token) if oauth_token.try(&.error)

        if oauth_token.try(&.sso?) &&
          !oauth_token.try(&.client_authorized? client[:id])

          return client_not_authorized_response(oauth_token)
        end

        if oauth_token
          do_run_operation_succeeded(operation, oauth_token)
        else
          response.status_code = 400
          do_run_operation_failed(operation)
        end
      end
    end

    def do_run_operation_succeeded(operation, oauth_token)
      return invalid_scope_response unless oauth_token.sso?
      redirect_back fallback: CurrentUser::Show
    end

    def do_run_operation_failed(operation)
      json({
        error: "invalid_request",
        error_description: operation.errors.first_value.first
      })
    end

    getter code_verifier : String? do
      OauthCodeVerifierSession.new(session).code_verifier?(delete: true)
    end

    private def client_not_authorized_response(oauth_client)
      json({
        error: "invalid_client",
        error_description: Rex.t(
          :"action.pipe.client_not_authorized",
          client_id: client[:id],
          azp: oauth_client.try(&.azp)
        ),
      }, 403)
    end

    private def invalid_scope_response
      json({
        error: "invalid_scope",
        error_description: Rex.t(:"action.pipe.sso_only")
      }, 400)
    end

    private def error_response(oauth_token)
      json({
        error: oauth_token.try(&.error),
        error_description: oauth_token.try(&.error_description)
      }, 400)
    end

    private def client
      Samba.settings.client.not_nil!
    end
  end
end
