module Samba::Api::LoginHelpers
  macro included
    include Samba::LoginHelpers

    getter? current_user : User? do
      login_headers.verify
    end

    getter? oauth_token : OauthToken? do
      login_headers.oauth_token?
    end

    private getter login_headers do
      LoginHeaders.new(context)
    end
  end
end
