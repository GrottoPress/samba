module Samba::OauthToken
  macro included
    include Lucille::JSON

    getter access_token : String?
    getter? active : Bool?
    getter aud : Array(String)?
    getter azp : String?
    getter client_id : String?
    getter error : String?
    getter error_description : String?
    getter expires_in : Int32?
    getter iss : String?
    getter jti : String?
    getter refresh_token : String?
    getter scope : String?
    getter sub : String?
    getter token_type : String?

    @[JSON::Field(converter: Time::EpochConverter)]
    getter exp : Time?

    @[JSON::Field(converter: Time::EpochConverter)]
    getter iat : Time?

    def scopes : Array(String)?
      scope.try do |_scope|
        _scopes = _scope.split
        _scopes unless _scopes.empty?
      end
    end

    def sso? : Bool?
      has_scope?(Samba::SCOPE)
    end

    def has_scope?(scope : String) : Bool?
      scopes.try(&.includes? scope)
    end

    def client_authorized?(client_id : String) : Bool?
      azp.try(&.== client_id)
    end

    def remote_id
      sub.try do |subject|
        {{ User::COLUMNS.find do |column|
          column[:name] == :remote_id.id
        end[:type] }}.adapter.parse(subject).value
      end
    end

    def self.create(
      code : String,
      client_id : String,
      client_secret : String,
      redirect_uri : String,
      code_verifier : String?
    )
      endpoint = Samba.settings.token_endpoint

      params = URI::Params.build do |form|
        form.add("code", code)
        form.add("client_id", client_id)
        form.add("client_secret", client_secret)
        form.add("code_verifier", code_verifier) if code_verifier
        form.add("grant_type", "authorization_code")
        form.add("redirect_uri", redirect_uri)
      end

      response = HTTP::Client.post(endpoint, form: params, headers: headers)
      from_json(response.body)
    end

    def self.introspect(token)
      verify(token)
    end

    def self.verify(token : String) : self
      client = Samba.settings.client
      endpoint = Samba.settings.token_introspection_endpoint

      form = URI::Params.new
      form.add("token", token)

      unless api_token = Samba.settings.server_api_token
        form.add("client_id", client.not_nil![:id])
        form.add("client_secret", client.not_nil![:secret])
      end

      headers = headers(api_token)
      response = HTTP::Client.post(endpoint, form: form.to_s, headers: headers)

      from_json(response.body)
    end

    def self.raw_token(arg) : String
      raw_token?(arg).not_nil!
    end

    def self.raw_token?(request : HTTP::Server::Context)
      raw_token?(context.request)
    end

    def self.raw_token?(request : HTTP::Request)
      raw_token?(request.headers)
    end

    def self.raw_token?(headers : HTTP::Headers) : String?
      header = headers["Authorization"]?.try(&.split)
      return unless header.try(&.size) == 2 && header.try(&.[0]?) == "Bearer"
      header.try(&.[1]?)
    end

    def self.cache_key(token : String)
      digest = Sha256Hash.new(token).hash(salt: false)
      "oauth:tokens:#{digest}"
    end

    private def self.headers(api_token = nil)
      headers = HTTP::Headers{
        "User-Agent" => "Samba/#{Samba::VERSION} \
          (+https://github.com/GrottoPress/samba)"
      }

      headers["Authorization"] = "Bearer #{api_token}" if api_token
      headers
    end
  end
end
