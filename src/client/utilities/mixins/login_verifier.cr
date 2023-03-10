module Samba::LoginVerifier
  macro included
    include Shield::Verifier

    def verify : User?
      user? if verify?
    end

    def verify? : Bool?
      return unless oauth_token?

      oauth_token.active? &&
      oauth_token.sso? &&
      oauth_token.client_id.try(&.in? client_ids)
    end

    def user : User
      user?.not_nil!
    end

    getter? user : User? do
      oauth_token?.try &.sub.try { |sub| UserQuery.new.remote_id(sub).first? }
    end

    def oauth_token : OauthToken
      oauth_token?.not_nil!
    end

    getter? oauth_token : OauthToken? do
      raw_token?.try do |token|
        Samba.settings.verify_oauth_token.call(
          OauthToken.cache_key(token),
          ->{ OauthToken.verify(token) }
        )
      end
    end

    def raw_token : String
      raw_token?.not_nil!
    end

    private def client_ids
      Samba.settings.oauth_client_ids.tap do |ids|
        Samba.settings.oauth_client.try do |client|
          ids << client[:id] unless ids.includes?(client[:id])
        end
      end
    end
  end
end
