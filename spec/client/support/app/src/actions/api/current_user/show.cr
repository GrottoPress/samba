class Api::CurrentUser::Show < PublicApi
  skip :require_logged_out

  get "/account" do
    json UserSerializer.new(user: user)
  end

  def user
    current_user_or_bearer
  end

  def authorize?(user : User) : Bool
    user.id == self.user.id
  end
end
