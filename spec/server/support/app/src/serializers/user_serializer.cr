struct UserSerializer < SuccessSerializer
  def initialize(
    @user : User? = nil,
    @users : Array(User)? = nil,
    @message : String? = nil,
    @pages : Lucky::Paginator? = nil,
  )
  end

  def self.item(user : User)
    {id: user.id}
  end

  private def data_json : NamedTuple
    data = super
    data = add_user(data)
    data = add_users(data)
    data
  end

  private def add_user(data)
    @user.try { |user| data = data.merge({user: self.class.item(user)}) }
    data
  end

  private def add_users(data)
    @users.try do |users|
      data = data.merge({users: self.class.list(users)})
    end

    data
  end
end
