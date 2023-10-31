module Samba::OauthAuthorizationEndpoint
  macro included
    def redirect_url(session : Lucky::Session) : String
      endpoint = Samba.settings.oauth_authorization_endpoint.not_nil!
      state = Random::Secure.urlsafe_base64(32)
      verifier = Random::Secure.urlsafe_base64(32)

      set_session(session, state, verifier)
      "#{endpoint}?#{params(state, verifier)}"
    end

    def self.redirect_url(session)
      new.redirect_url(session)
    end

    private def set_session(session, state, verifier)
      OauthStateSession.new(session).set(state)
      OauthCodeVerifierSession.new(session).set(verifier)
    end

    private def params(state, verifier)
      client = Samba.settings.oauth_client.not_nil!

      URI::Params.build do |form|
        form.add("client_id", client[:id])
        form.add("code_challenge", code_challenge(verifier))
        form.add("code_challenge_method", code_challenge_method)
        form.add("redirect_uri", client[:redirect_uri])
        form.add("response_type", "code")
        form.add("scope", token_scopes.join(' '))
        form.add("state", state)
      end
    end

    private def code_challenge(verifier)
      return verifier if "plain" == code_challenge_method

      digest = Digest::SHA256.digest(verifier)
      Base64.urlsafe_encode(digest, false)
    end

    private def code_challenge_method
      Samba.settings.oauth_code_challenge_method
    end

    private def token_scopes
      Samba.settings.login_token_scopes.tap do |scopes|
        scopes << Samba::SCOPE unless scopes.includes?(Samba::SCOPE)
      end
    end
  end
end
