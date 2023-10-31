ENV["LUCKY_ENV"] = "test"

require "spec"

require "./support/boot"
require "./setup/**"

require "../../src/spec/server"

Habitat.raise_if_missing_settings!

Avram::Migrator::Runner.new.ensure_migrated!
Avram::SchemaEnforcer.ensure_correct_column_mappings!

include Lucky::RequestExpectations
