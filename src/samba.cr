require "shield"

require "./version"
require "./mixins/**"

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
