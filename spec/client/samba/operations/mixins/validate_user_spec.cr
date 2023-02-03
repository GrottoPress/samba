require "../../../spec_helper"

private class SaveUser < User::SaveOperation
  include Samba::ValidateUser
end

describe Samba::ValidateUser do
  it "ensures remote ID is unique" do
    new_remote_id = 456

    user = UserFactory.create &.remote_id(123)
    UserFactory.create &.remote_id(new_remote_id)

    SaveUser.update(user, remote_id: new_remote_id) do |operation, _|
      operation.saved?.should be_false
      operation.remote_id.should have_error("operation.error.remote_id_exists")
    end
  end
end
