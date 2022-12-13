module Samba::OauthStateSession
  macro included
    def initialize(@session : Lucky::Session)
    end

    def self.new(context : HTTP::Server::Context)
      new(context.session)
    end

    def delete : self
      @session.delete(:oauth_state)
      self
    end

    def set(state : String) : self
      @session.set(:oauth_state, state)
      self
    end

    def state : String
      state?.not_nil!
    end

    def state? : String?
      @session.get?(:oauth_state)
    end

    def verify?(params : Lucky::Params) : Bool
      varify?(params.get? :state)
    end

    def verify?(param : String?) : Bool?
      return unless param && state?
      Crypto::Subtle.constant_time_compare(state, param)
    end
  end
end
