require "webmock"

module Samba::HttpClient
  macro included
    def api_auth(
      user : User,
      token : String,
      scopes = ["sso"],
      client_id = Samba.settings.oauth_client.try(&.[:id])
    )
      api_auth(user.remote_id, token, scopes, client_id)
    end

    def api_auth(
      remote_id,
      token : String,
      scopes = ["sso"],
      client_id = Samba.settings.oauth_client.try(&.[:id])
    )
      create_user(remote_id)
      mock_request(remote_id, scopes, client_id)

      headers("Authorization": "Bearer #{token}")
    end

    def browser_auth(
      user : User,
      token : String,
      scopes = ["sso"],
      client_id = Samba.settings.oauth_client.try(&.[:id]),
      session = Lucky::Session.new
    )
      browser_auth(user.remote_id, token, scopes, client_id, session)
    end

    def browser_auth(
      remote_id,
      token : String,
      scopes = ["sso"],
      client_id = Samba.settings.oauth_client.try(&.[:id]),
      session = Lucky::Session.new
    )
      create_user(remote_id)
      mock_request(remote_id, scopes, client_id)

      LoginSession.new(session).set(token)
      set_cookie_from_session(session)
    end

    def set_cookie_from_session(session : Lucky::Session)
      headers("Cookie": self.class.cookie_from_session?(session).to_s)
    end

    def self.cookie_from_session(session : Lucky::Session)
      cookie_from_session?(session).not_nil!
    end

    def self.cookie_from_session?(session : Lucky::Session)
      cookies = Lucky::CookieJar.empty_jar
      cookies.set(Lucky::Session.settings.key, session.to_json)
      cookies.updated.add_response_headers(HTTP::Headers.new)["Set-Cookie"]?
    end

    def self.session_from_cookies(cookies : HTTP::Cookies)
      cookies = Lucky::CookieJar.from_request_cookies(cookies)
      Lucky::Session.from_cookie_jar(cookies)
    end

    private def create_user(remote_id) : Nil
      return if UserQuery.new.remote_id(remote_id).any?
      UserFactory.create &.remote_id(remote_id)
    end

    private def mock_request(remote_id, scopes, client_id)
      scope = scopes.is_a?(Indexable) ? scopes.join(' ') : scopes

      body = <<-JSON
        {
          "active": true,
          "client_id": "#{client_id}",
          "iss": "https://id.grottopress.com",
          "scope": "#{scope}",
          "sub": "#{remote_id}",
          "token_type": "Bearer"
        }
        JSON

      headers = {"Content-Type" => "application/x-www-form-urlencoded"}

      if api_token = Samba.settings.server_api_token
        headers["Authorization"] = "Bearer #{api_token}"
      end

      WebMock.stub(:POST, Samba.settings.oauth_token_introspection_endpoint)
        .with(headers: headers)
        .to_return(body: body)
    end
  end
end
