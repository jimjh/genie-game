require 'spec_helper'

describe Problem do

  it { should belong_to :lesson    }
  it { should have_many(:answers).dependent(:destroy) }

  it { should have_a_valid_factory }

  it { should validate_presence_of :lesson      }
  it { should validate_presence_of :digest       }
  it { should validate_presence_of :position     }
  it { should validate_numericality_of :position }

  %i[lesson solution digest position active].each do |attr|
    it { should respond_to attr }
  end

  %i[solution digest position active].each do |attr|
    it { should allow_mass_assignment_of attr }
  end

  %i[lesson lesson_id].each do |attr|
    it { should_not allow_mass_assignment_of attr }
  end

  it { should have_readonly_attribute :lesson_id }

  context 'given an existing problem and an encoded solution' do

    subject { problem }
    let(:solution) { Faker::Lorem.sentence }
    let(:problem)  do
      FactoryGirl.create :problem, solution: Base64.urlsafe_encode64(solution)
    end

    # it decodes the solution before create
    its(:solution) { should eq solution }

  end

  describe '#for_users' do

    subject { problem.answers.for_users user_ids }
    let(:problem)  { FactoryGirl.create :problem }
    let(:answers)  { (0..10).map { FactoryGirl.create :answer, problem: problem } }
    let(:user_ids) { answers.take(5).map(&:user_id) }

    it 'only includes IDs in the set' do
      subject.map { |a| a.user_id }.should eq user_ids
    end

  end

end
