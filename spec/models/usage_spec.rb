require 'spec_helper'

describe Usage do

  it { should have_a_valid_factory }

  it { should belong_to :user }
  it { should belong_to :lesson }

  %i[use_count lesson lesson_id user user_id].each do |f|
    it { should_not allow_mass_assignment_of f }
  end
  it { should have_readonly_attribute :lesson_id }
  it { should have_readonly_attribute :user_id }
  it { should validate_presence_of :lesson }
  it { should validate_presence_of :user }

end
