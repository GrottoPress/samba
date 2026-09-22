module Samba::RegisterOauthTokenUser
  macro included
    needs oauth_token : OauthToken

    before_save do
      set_remote
      set_remote_id
    end

    include Samba::RegisterUser

    private def set_remote
      return unless self.responds_to?(:remote)
      oauth_token.user.try { |user| remote.value = user }
    end

    private def set_remote_id
      oauth_token.user_id.try { |user_id| remote_id.value = user_id }
    end
  end
end
