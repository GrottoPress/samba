class User < BaseModel
  include Shield::User
  include Shield::UserSettingsColumn

  include Shield::HasManyBearerLogins
  include Shield::HasManyLogins
  include Shield::HasManyOauthClients
  include Shield::HasManyOauthGrants

  include Carbon::Emailable

  skip_default_columns
  primary_key id : Int64

  table :users {}

  def emailable : Carbon::Address
    Carbon::Address.new(email)
  end
end
