module Samba::Api::BearerLoginPipes
  macro included
    include Samba::Api::LoginPipes

    private def send_invalid_token_response
      unless OauthToken.raw_token?(request)
        response.status_code = 401
        return response.headers["WWW-Authenticate"] = %(Bearer)
      end

      if bearer_login_headers.verify?
        response.status_code = 403
        response.headers["WWW-Authenticate"] =
          %(Bearer error="insufficient_scope", scope="#{bearer_scope}")
      else
        response.status_code = 401
        response.headers["WWW-Authenticate"] = %(Bearer error="invalid_token")
      end
    end
  end
end
