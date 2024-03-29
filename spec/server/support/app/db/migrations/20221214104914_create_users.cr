class CreateUsers::V20221214104914 < Avram::Migrator::Migration::V1
  def migrate
    create :users do
      primary_key id : Int64

      add email : String, unique: true
      add password_digest : String
      add settings : JSON::Any
    end
  end

  def rollback
    drop :users
  end
end
