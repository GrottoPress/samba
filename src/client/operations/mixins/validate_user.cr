module Samba::ValidateUser
  macro included
    skip_default_validations

    before_save do
      validate_remote_id_unique
    end

    private def validate_remote_id_unique
      return unless remote_id.changed?

      validate_uniqueness_of remote_id,
        message: Rex.t(:"operation.error.remote_id_exists")
    end
  end
end
