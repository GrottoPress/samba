class CurrentUser::Show < BrowserAction
  include Shield::CurrentUser::Show

  get "/account" do
    html ShowPage, user: user
  end
end
