require "lucille/spec/lucky"
require "lucille/spec/avram"

require "../client"

abstract class Lucky::BaseHTTPClient
  include Samba::HttpClient
end
