module Samba::Oauth::Authorization::Create
  macro included
    include Shield::Oauth::Authorization::Create

    # post "/oauth/authorization" do
    #   run_operation
    # end

    def run_operation
      StartLoginOauthGrant.create(
        params,
        scopes: scopes,
        type: OauthGrantType.authorization_code,
        oauth_client: oauth_client?,
        user: user,
        session: session
      ) do |operation, oauth_grant|
        if operation.saved?
          do_run_operation_succeeded(operation, oauth_grant.not_nil!)
        else
          response.status_code = 400
          do_run_operation_failed(operation)
        end
      end
    end
  end
end
