AppDatabase.configure do |settings|
  settings.credentials = Avram::Credentials.parse(ENV["CLIENT_DATABASE_URL"])
end

Avram.configure do |settings|
  settings.database_to_migrate = AppDatabase
  settings.lazy_load_enabled = LuckyEnv.production?
end
