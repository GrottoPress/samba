class Api::CurrentUser::Create < PublicApi
  skip :require_logged_in

  post "/account" do
    json UserSerializer.new
  end
end
