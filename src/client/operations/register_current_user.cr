module Samba::RegisterCurrentUser # User::SaveOperation
  macro included
    {% puts "Samba::RegisterCurrentUser is deprecated. \
      Use Samba::RegisterUser instead" %}

    include Samba::RegisterUser
  end
end
