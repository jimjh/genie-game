require 'spec_helper'

describe Answer do

  it { should belong_to :user }
  it { should belong_to :problem }

  it { should have_a_valid_factory }
  it { should allow_mass_assignment_of :content }

  %w[problem user content].each do |attr|
    it { should respond_to attr.to_sym }
  end

  %w[problem problem_id user user_id].each do |attr|
    it { should_not allow_mass_assignment_of attr.to_sym }
  end

end
