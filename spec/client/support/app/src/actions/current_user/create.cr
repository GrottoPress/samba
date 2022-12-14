class CurrentUser::Create < BrowserAction
  skip :require_logged_in

  post "/account" do
    html ShowPage, user: user
  end

  def user
    current_user
  end
end
