ENV["LUCKY_TASK"] = "true"

require "lucky_task"

require "./src/app"
# require "./tasks/**"
require "./db/migrations/**"
require "lucky/tasks/**"
require "avram/lucky/tasks"

LuckyTask::Runner.run
