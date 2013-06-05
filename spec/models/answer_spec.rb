require 'spec_helper'

describe Answer do

  it { should belong_to :user }
  it { should belong_to :problem }

  it { should have_a_valid_factory }
  it { should allow_mass_assignment_of :content }
  it { should have_readonly_attribute :problem_id }
  it { should have_readonly_attribute :user_id }

  %w[problem user content results score].each do |attr|
    it { should respond_to attr.to_sym }
  end

  %w[problem problem_id user user_id results score].each do |attr|
    it { should_not allow_mass_assignment_of attr.to_sym }
  end

  it { should validate_presence_of :content }

  context 'given an answer' do

    subject { answer }
    let(:lesson)  { FactoryGirl.create :lesson }
    let(:problem) { FactoryGirl.create :problem, lesson: lesson }
    let(:answer)  { FactoryGirl.build :answer, problem: problem }

    it { should validate_presence_of :user }
    it { should validate_presence_of :problem }

    context 'and a published lesson' do
      let(:lesson)  { FactoryGirl.create :lesson, :published }
      it { should be_valid }
      its(:save) { should be true }
    end

    context 'and a deactivated lesson' do
      let(:lesson)  { FactoryGirl.create :lesson, :deactivated }
      it { should_not be_valid }
      its(:save) { should be false }
    end

  end

end

describe Answer, '.upsert' do

  before(:each) { @first = FactoryGirl.create :answer }
  after(:each)  { @first.destroy }

  it 'has a first answer' do
    @first.should_not be_nil
    Answer.count.should be 1
  end

  context 'with a different problem but same user' do

    before(:each) do
      second  = FactoryGirl.build :answer, user: @first.user
      @second = Answer.upsert second.user.id, second.problem.id,
        second.attributes.slice('content')
      @second.save!
    end

    after(:each)  { @second.destroy if @second.persisted? }

    it 'upserts successfully' do
      @second.should be_persisted
    end

    it 'inserts a new answer' do
      Answer.count.should be 2
    end

  end

  context 'with the same problem and user' do

    before(:each) do
      second  = FactoryGirl.build :answer, user: @first.user,
        problem: @first.problem
      @second = Answer.upsert second.user.id, second.problem.id,
        second.attributes.slice('content')
      @second.save!
    end

    after(:each)  { @second.destroy if @second.persisted? }

    it 'upserts successfully' do
      @second.should be_persisted
    end

    it 'does not insert a new answer' do
      Answer.count.should be 1
    end

    it 'updates the existing answer' do
      @first.reload.content.should eq(@second.content)
    end

  end

end
