abstract class BaseModel < Avram::Model
  def self.database : Avram::Database.class
    Avram.settings.database_to_migrate
  end
end
