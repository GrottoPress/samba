module Samba::BearerLoginVerifier
  macro included
    include Shield::Verifier

    def verify!(scope : Shield::BearerScope | String | Nil = nil)
      verify(scope).not_nil!
    end

    def verify(scope : Shield::BearerScope | String | Nil = nil)
      yield self, verify(scope)
    end

    def verify(scope : Shield::BearerScope | String | Nil = nil) : User?
      user? if verify?(scope)
    end

    def verify?(scope : Shield::BearerScope | String | Nil = nil) : Bool?
      return unless oauth_token?

      oauth_token.active? && (!scope || oauth_token.has_scope?(scope.to_s))
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
        Samba.settings.verify_token.call(
          OauthToken.cache_key(token),
          ->{ OauthToken.verify(token) }
        )
      end
    end

    def raw_token : String
      raw_token?.not_nil!
    end
  end
end
