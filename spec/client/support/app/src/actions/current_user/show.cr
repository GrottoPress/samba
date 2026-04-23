class CurrentUser::Show < BrowserAction
  skip :require_logged_out

  authorize { true }

  get "/account" do
    html ShowPage, user: user
  end

  def user
    current_user?
  end
end
