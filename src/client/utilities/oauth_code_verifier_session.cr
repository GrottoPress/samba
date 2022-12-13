module Samba::OauthCodeVerifierSession
  macro included
    def initialize(@session : Lucky::Session)
    end

    def self.new(context : HTTP::Server::Context)
      new(context.session)
    end

    def delete : self
      @session.delete(:oauth_code_verifier)
      self
    end

    def set(verifier : String) : self
      @session.set(:oauth_code_verifier, verifier)
      self
    end

    def code_verifier : String
      code_verifier?.not_nil!
    end

    def code_verifier?(*, delete = false) : String?
      @session.get?(:oauth_code_verifier).try do |value|
        self.delete if delete
        value
      end
    end
  end
end
