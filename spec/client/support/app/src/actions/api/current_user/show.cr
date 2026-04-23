class Api::CurrentUser::Show < PublicApi
  skip :require_logged_out

  authorize { true }

  get "/account" do
    json UserSerializer.new(user: user)
  end

  def user
    any_current_user?
  end
end
