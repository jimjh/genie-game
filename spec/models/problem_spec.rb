require 'spec_helper'

describe Problem do

  it { should belong_to :lesson    }
  it { should have_a_valid_factory }

  it { should validate_existence_of :lesson      }
  it { should validate_presence_of :digest       }
  it { should validate_presence_of :position     }
  it { should validate_numericality_of :position }

  %w[lesson solution digest position active].each do |attr|
    it { should respond_to attr.to_sym }
  end

  %w[solution digest position active].each do |attr|
    it { should allow_mass_assignment_of attr.to_sym }
  end

  %w[lesson lesson_id].each do |attr|
    it { should_not allow_mass_assignment_of attr.to_sym }
  end

  context 'given an existing problem' do

    before(:each) do
      @solution = Faker::Lorem.sentence
      @problem  = FactoryGirl.create :problem, solution: Base64.urlsafe_encode64(@solution)
    end
    after(:each) { @problem.destroy }

    it 'decodes the solution before create' do
      @problem.solution.should eq @solution
    end

  end

end
