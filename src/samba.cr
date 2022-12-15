require "shield"

require "./version"

module Samba
  enum Role
    Client
    Server
  end

  Habitat.create { }

  SCOPE = "sso"

  def self.role
    ROLE
  end
end
