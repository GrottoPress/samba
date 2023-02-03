require "../../spec_helper"

describe Samba::RegisterCurrentUser do
  it "requires remote ID" do
    RegisterCurrentUser.create do |operation, user|
      user.should be_nil

      operation.remote_id
        .should(have_error "operation.error.remote_id_required")
    end
  end
end
