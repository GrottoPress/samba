module Samba::LoginSession
  macro included
    include Samba::LoginVerifier

    def initialize(@session : Lucky::Session)
    end

    def self.new(context : HTTP::Server::Context)
      new(context.session)
    end

    def delete : self
      @session.delete(:login_token)
      self
    end

    def set(oauth_token : OauthToken) : self
      oauth_token.access_token.try do |token|
        set(token) if oauth_token.sso?
      end

      self
    end

    def set(token : String) : self
      @session.set(:login_token, token)
      self
    end

    def raw_token? : String?
      @session.get?(:login_token)
    end
  end
end
