module Samba::CreateOauthToken
  macro included
    include Shield::SetSession

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

    after_run create_user

    def run
      create_token
    end

    private def validate_code_required
      validate_required code,
        message: Rex.t(:"operation.error.oauth.code_required")
    end

    private def validate_client_id_required
      validate_required client_id,
        message: Rex.t(:"operation.error.oauth.client_id_required")
    end

    private def validate_client_secret_required
      validate_required client_secret,
        message: Rex.t(:"operation.error.oauth.client_secret_required")
    end

    private def validate_redirect_uri_required
      validate_required redirect_uri,
        message: Rex.t(:"operation.error.oauth.redirect_uri_required")
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

    private def set_session(oauth_token : OauthToken)
      client_id.value.try do |value|
        session.try do |_session|
          return unless oauth_token.client_authorized?(value)
          LoginSession.new(_session).set(oauth_token)
        end
      end
    end

    private def create_user(oauth_token : OauthToken)
      client_id.value.try do |value|
        return unless oauth_token.sso? && oauth_token.client_authorized?(value)
        RegisterCurrentUser.upsert!(remote_id: oauth_token.remote_id.not_nil!)
      end
    end
  end
end
