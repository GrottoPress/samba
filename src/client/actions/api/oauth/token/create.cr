# This OAuth client's redirect URL
#
# This action's URL is what we set as the redirect URI when we register
# this client with the Authorization server
module Samba::Api::Oauth::Token::Create
  macro included
    include Samba::Api::Oauth::Token::Pipes

    before :oauth_require_code

    # NOTE: The frontend should verify the state before sending
    # request to this route

    # post "/oauth/callback" do
    #   run_operation
    # end

    def run_operation
      CreateOauthToken.run(params) do |operation, oauth_token|
        return error_response(oauth_token) if oauth_token.try(&.error)

        if oauth_token.try(&.sso?) &&
          !oauth_token.try(&.client_authorized? client_id.not_nil!)

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

      RegisterCurrentUser.upsert!(remote_id: oauth_token.remote_id.not_nil!)
      json(oauth_token)
    end

    def do_run_operation_failed(operation)
      json({
        error: "invalid_request",
        error_description: operation.errors.first_value.first
      })
    end

    def code : String?
      nested_param?(:code)
    end

    def client_id : String?
      nested_param?(:client_id)
    end

    private def client_not_authorized_response(oauth_client)
      json({
        error: "invalid_client",
        error_description: Rex.t(
          :"action.pipe.client_not_authorized",
          client_id: client_id,
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

    private def nested_param?(param)
      params.nested?(CreateOauthToken.param_key)[param.to_s]?
    end
  end
end
