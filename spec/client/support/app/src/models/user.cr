class User < BaseModel
  skip_default_columns

  table do
    primary_key id : Int64

    column remote_id : Int64
  end
end
