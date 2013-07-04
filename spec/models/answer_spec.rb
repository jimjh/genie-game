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

  %i[problem problem_id user user_id results score attempts first_correct_attempt].each do |attr|
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

  def new_answer(opts)
    ans    = FactoryGirl.build :answer, opts
    answer = Answer.upsert ans.user.id, ans.problem.id, ans.attributes.slice('content')
    answer.save!
    answer
  end

  let(:user)    { FactoryGirl.create :user }
  let(:problem) { FactoryGirl.create :problem }

  before :each do
    @first = new_answer user: user, problem: problem
  end

  it 'has a first answer' do
    @first.reload.attempts.should eq 1
    user.answers.count.should eq 1
  end

  context 'with a different problem but same user' do

    let(:second) { new_answer user: user }
    subject      { second }
    it { should be_persisted }

    it 'inserts a new answer' do
      second.reload.attempts.should eq 1
      user.answers.count.should eq 2
    end

  end

  context 'with the same problem and user' do

    let(:second) { new_answer user: user, problem: problem }
    subject      { second }
    it { should be_persisted }

    it 'does not insert a new answer' do
      user.answers.count.should eq 1
    end

    it 'updates the existing answer' do
      second
      @first.reload.content.should eq second.content
    end

    it 'increases the attempt count' do
      second
      @first.reload.attempts.should eq 2
    end



    context 'and with a correct answer' do

      let(:content) { Marshal.load problem.solution }
      let(:second)  { new_answer user: user, problem: problem, content: content }
      it { should be_persisted  }
      its(:score) { should eq 1 }
      its(:first_correct_attempt) { should eq 2 }
      its(:attempts) { should eq 2 }

      it 'subsequent incorrect attempts do not change the first_correct_attempt counter' do
        second
        new_answer user: user, problem: problem
        second.reload.attempts.should eq 3
        second.first_correct_attempt.should eq 2
      end

      it 'subsequent correct attempts do not change the first_correct_attempt counter' do
        second
        new_answer user: user, problem: problem, content: content
        second.reload.attempts.should eq 3
        second.first_correct_attempt.should eq 2
      end

    end

  end

end
