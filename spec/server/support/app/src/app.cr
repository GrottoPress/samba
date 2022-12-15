require "lucky_env"
require "lucky"
require "avram/lucky"
require "carbon"
# require "dude"

require "../../../../../src/server"

require "./app_database"
require "./models/base_model"
require "./models/**"

require "shield/presets"
require "../../../../../src/presets/server"

# require "./queries/**"
# require "./operations/**"
require "./serializers/base_serializer"
require "./serializers/success_serializer"
require "./serializers/**"
require "./emails/base_email"
require "./emails/**"
require "./actions/**"
require "./pages/**"

require "../config/env"
require "../config/**"
require "../db/migrations/**"
require "./app_server"
