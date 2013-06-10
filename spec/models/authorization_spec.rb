require 'spec_helper'

describe Authorization do

  %i[link name nickname provider secret token uid].each do |attr|
    it { should respond_to attr }
  end

  %i[provider uid token nickname user].each do |attr|
    it { should validate_presence_of attr }
  end

  it { should belong_to(:user) }
  it { should have_a_valid_factory }

  it { should have_readonly_attribute :user_id }

end
