module Samba::CreateOauthToken
  macro included
    param_key :oauth_token

    attribute client_id : String
    attribute client_secret : String
    attribute code : String
    attribute code_verifier : String
    attribute redirect_uri : String

    before_run do
      validate_code_required
      validate_client_id_required
      validate_client_secret_required
      validate_redirect_uri_required
    end

    def run
      create_token
    end

    private def validate_code_required
      validate_required code, message: Rex.t(:"operation.error.code_required")
    end

    private def validate_client_id_required
      validate_required client_id,
        message: Rex.t(:"operation.error.client_id_required")
    end

    private def validate_client_secret_required
      validate_required client_secret,
        message: Rex.t(:"operation.error.client_secret_required")
    end

    private def validate_redirect_uri_required
      validate_required redirect_uri,
        message: Rex.t(:"operation.error.redirect_uri_required")
    end

    private def create_token
      OauthToken.create(
        code.value.not_nil!,
        client_id.value.not_nil!,
        client_secret.value.not_nil!,
        redirect_uri.value.not_nil!,
        code_verifier.value
      )
    end
  end
end
