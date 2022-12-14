class CreateUsers::V20221209185304 < Avram::Migrator::Migration::V1
  def migrate
    create :users do
      primary_key id : Int64

      add remote_id : Int64, unique: true
    end
  end

  def rollback
    drop :users
  end
end
