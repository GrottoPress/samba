ENV["LUCKY_ENV"] = "test"

require "spec"

require "./support/boot"
require "./setup/**"

require "../../src/spec/server"

include Lucky::RequestExpectations

Avram::SpecHelper.use_transactional_specs(Avram.settings.database_to_migrate)

Avram::Migrator::Runner.new.ensure_migrated!
Avram::SchemaEnforcer.ensure_correct_column_mappings!
Habitat.raise_if_missing_settings!
