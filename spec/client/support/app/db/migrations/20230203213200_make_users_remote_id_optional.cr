class MakeUsersRemoteIdOptional::V20230203213200 <
  Avram::Migrator::Migration::V1

  def migrate
    make_optional :users, :remote_id
  end

  def rollback
    make_required :users, :remote_id
  end
end
