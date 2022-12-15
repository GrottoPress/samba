class Api::CurrentUser::Show < PublicApi
  include Shield::Api::CurrentUser::Show

  get "/account" do
    json UserSerializer.new(user: user)
  end
end
