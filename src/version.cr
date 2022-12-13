module Samba
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end
