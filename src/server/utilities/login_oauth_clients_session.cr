module Samba::LoginOauthClientsSession
  macro included
    def initialize(@session : Lucky::Session)
    end

    def self.new(context : HTTP::Server::Context)
      new(context.session)
    end

    def delete(client_id) : self
      raw_client_ids?.try do |ids|
        ids.delete(client_id.to_s)
        set(ids)
      end

      self
    end

    def delete : self
      @session.delete(:login_oauth_client_ids)
      self
    end

    def set(client_ids : Array) : self
      unless client_ids.empty?
        @session.set(:login_oauth_client_ids, client_ids.to_json)
      end

      self
    end

    def set(client_id) : self
      client_ids = [client_id.to_s]
      raw_client_ids?.try { |ids| client_ids = ids + client_ids }

      set(client_ids)
    end

    def client_ids(*, delete = false) : Array(OauthClient::PrimaryKeyType)
      client_ids?(delete: delete) || Array(OauthClient::PrimaryKeyType).new
    end

    def client_ids?(*, delete = false) : Array(OauthClient::PrimaryKeyType)?
      raw_client_ids?(delete: delete).try do |ids|
        OauthClient::PrimaryKeyType.adapter.parse(ids).value
      end
    end

    def raw_client_ids(*, delete = false) : Array(String)
      raw_client_ids?(delete: delete) || Array(String).new
    end

    def raw_client_ids?(*, delete = false) : Array(String)?
      @session.get?(:login_oauth_client_ids).try do |json|
        self.delete if delete
        ids = Array(String).from_json(json)
        ids unless ids.empty?
      end
    end
  end
end
