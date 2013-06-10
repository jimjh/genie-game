require 'csv'
require 'spec_helper'

describe Answer do

  it { should belong_to :user }
  it { should belong_to :problem }

  it { should have_a_valid_factory }
  it { should allow_mass_assignment_of :content }
  it { should have_readonly_attribute :problem_id }
  it { should have_readonly_attribute :user_id }

  %i[problem user content results score].each do |attr|
    it { should respond_to attr }
  end

  %i[problem problem_id user user_id results score].each do |attr|
    it { should_not allow_mass_assignment_of attr }
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

describe Answer, '::to_csv' do

  let(:output) { Answer.to_csv }

  shared_examples 'a proper CSV file' do
    it 'contains valid CSV' do
      expect { CSV.parse output }.to_not raise_error(CSV::MalformedCSVError)
    end
    it 'has a header row and the expected columns' do
      first_row = CSV.parse(output).first
      first_row.should eq %w[id lesson_slug problem_position user_slug score]
    end
  end

  context 'with several answers' do
    before(:each) { 10.times { FactoryGirl.create :answer } }
    it_behaves_like 'a proper CSV file'
  end

  context 'with no answers' do
    it_behaves_like 'a proper CSV file'
  end

end

describe Answer, '::upsert' do

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
