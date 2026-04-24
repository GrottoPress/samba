class Api::CurrentUser::Show < PublicApi
  skip :require_logged_out

  authorize_user do |user|
    user.id == self.user.try(&.id)
  end

  authorize { true }

  get "/account" do
    json UserSerializer.new(user: user)
  end

  def user
    current_user?
  end
end
