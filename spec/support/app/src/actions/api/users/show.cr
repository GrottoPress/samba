class Api::Users::Show < PublicApi
  skip :require_logged_out

  get "/users/:user_id" do
    json UserSerializer.new(user: user)
  end

  getter user : User do
    UserQuery.find(user_id)
  end
end
