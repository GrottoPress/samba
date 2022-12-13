module Samba::RegisterCurrentUser
  macro included
    upsert_lookup_columns :remote_id

    include Samba::ValidateUser
  end
end
