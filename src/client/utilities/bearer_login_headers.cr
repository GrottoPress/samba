module Samba::BearerLoginHeaders
  macro included
    include Samba::BearerLoginVerifier

    def initialize(@headers : HTTP::Headers)
    end

    def self.new(context : HTTP::Server::Context)
      new(context.request)
    end

    def self.new(request : HTTP::Request)
      new(request.headers)
    end

    def raw_token? : String?
      OauthToken.raw_token?(@headers)
    end
  end
end
