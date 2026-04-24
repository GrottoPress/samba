class CurrentUser::Show < BrowserAction
  skip :require_logged_out

  authorize_user do |user|
    user.id == self.user.try(&.id)
  end

  authorize { true }

  get "/account" do
    html ShowPage, user: user
  end

  def user
    current_user?
  end
end
