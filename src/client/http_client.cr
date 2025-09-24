module Samba::HttpClient
  macro included
    def api_auth(user : User, scopes = ["sso"])
      api_auth(user.remote_id, scopes)
    end

    def api_auth(remote_id, scopes = ["sso"])
      mock_request(remote_id, scopes)
      headers("Authorization": "Bearer a1b2c3e4d5")
    end

    def browser_auth(
      user : User,
      scopes = ["sso"],
      session = Lucky::Session.new
    )
      browser_auth(user.remote_id, scopes, session)
    end

    def browser_auth(
      remote_id,
      scopes = ["sso"],
      session = Lucky::Session.new
    )
      mock_request(remote_id, scopes)

      LoginSession.new(session).set("a1b2c3e4d5")
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

    private def mock_request(remote_id, scopes)
      scope = scopes.is_a?(Indexable) ? scopes.join(' ') : scopes

      client_id = Samba.settings.oauth_client.try(&.[:id]) ||
        Samba.settings.oauth_client_ids.first?

      body = <<-JSON
        {
          "active": true,
          "client_id": "#{client_id}",
          "iss": "https://samba.server",
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
