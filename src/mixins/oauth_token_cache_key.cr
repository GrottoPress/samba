module Samba::OauthTokenCacheKey
  macro included
    def self.cache_key(token : String)
      digest = Sha256Hash.new(token).hash(salt: false)
      "oauth:tokens:#{digest}"
    end
  end
end
