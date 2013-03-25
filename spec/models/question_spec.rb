require 'spec_helper'

describe Question do

  it { should belong_to :lesson    }
  it { should have_a_valid_factory }

  it { should validate_existence_of :lesson      }
  it { should validate_presence_of :digest       }
  it { should validate_presence_of :position     }
  it { should validate_numericality_of :position }

  %w[lesson answer digest position active].each do |attr|
    it { should respond_to attr.to_sym }
  end

  %w[answer digest position active].each do |attr|
    it { should allow_mass_assignment_of attr.to_sym }
  end

  %w[lesson lesson_id].each do |attr|
    it { should_not allow_mass_assignment_of attr.to_sym }
  end

end
