class UserFactory < Avram::Factory
  def initialize
    set_defaults
  end

  def password(password : String)
    password_digest BcryptHash.new(password).hash
  end

  private def set_defaults
    email "user@samba.server"
    password "password"

    settings UserSettings.from_json({
      bearer_login_notify: true,
      login_notify: true,
      oauth_access_token_notify: true,
      password_notify: true
    }.to_json)
  end
end
