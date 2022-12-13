class UserFactory < Avram::Factory
  def initialize
    set_defaults
  end

  private def set_defaults
    remote_id 123
  end
end
