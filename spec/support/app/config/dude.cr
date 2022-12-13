Dude.configure do |settings|
  settings.redis_url = ENV["CACHE_REDIS_URL"]
end
