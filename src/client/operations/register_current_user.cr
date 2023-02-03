module Samba::RegisterCurrentUser
  macro included
    upsert_lookup_columns :remote_id

    before_save do
      validate_remote_id_required
    end

    include Samba::ValidateUser

    private def validate_remote_id_required
      validate_required remote_id,
        message: Rex.t(:"operation.error.remote_id_required")
    end
  end
end
