Lucky::Server.configure do |settings|
  settings.secret_key_base = "abcdefghijklmnopqrstuvwxyz123456"
  settings.host = "0.0.0.0"
  settings.port = 5001
  settings.gzip_enabled = false
end
