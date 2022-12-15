abstract class BaseModel < Avram::Model
  include Shield::Model

  def self.database : Avram::Database.class
    Avram.settings.database_to_migrate
  end
end
