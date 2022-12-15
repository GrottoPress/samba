require "shield"

require "./version"

module Samba
  enum Role
    Client
    Server
  end

  SCOPE = "sso"

  def self.role
    ROLE
  end
end
