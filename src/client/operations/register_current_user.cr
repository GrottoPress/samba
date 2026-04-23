module Samba::RegisterCurrentUser
  macro included
    {% puts "Samba::RegisterCurrentUser is deprecated. \
      Use Samba::RegisterUser instead" %}

    include Samba::RegisterUser
  end
end
