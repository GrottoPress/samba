Dude.configure do |settings|
  settings.redis_url = ENV["CLIENT_CACHE_REDIS_URL"]
  settings.redis_key_prefix = "samba:client"
end
