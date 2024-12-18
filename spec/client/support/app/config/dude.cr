Dude.configure do |settings|
  settings.store = Dude::Redis.new(
    ENV["CLIENT_CACHE_REDIS_URL"],
    "samba:client"
  )
end
