# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Lesson do

  # specs to write
  # create
  #   - tells faye
  # published
  #   - tells faye
  # pushed
  #   - tells faye
  # failed
  #   - tells faye
  # destroy
  #   - tells faye
  # update
  #   - tells faye

  %w(name url path slug compiled_path solution_path status action)
  .each do |s|
    it { should respond_to(s.to_sym) }
  end

  it { should belong_to(:user) }

  %w(name url user_id).each do |s|
    it { should validate_presence_of(s.to_sym) }
  end

  %w(name url).each do |s|
    it { should allow_mass_assignment_of s.to_sym }
  end

  %w(path slug compiled_path solution_path status action)
  .each do |s|
    it { should_not allow_mass_assignment_of s.to_sym }
  end

  it { should validate_uniqueness_of(:name).scoped_to(:user_id) }
  it { should allow_git_urls.for(:url) }

  # should not allow local
  it { should_not allow_value('ftp://localhost/path/to/repo.git/').for(:url) }
  it { should_not allow_value('ftp://127.0.0.1/path/to/repo.git/').for(:url) }
  it { should_not allow_value('ftp://0.0.0.0/path/to/repo.git/').for(:url) }

  # should check for suffix
  it { should_not allow_value('ftp://host.xz/path/to/repo/').for(:url) }

  it { should ensure_inclusion_of(:status).in_array(Lesson::STATUSES) }

  it { should have_a_valid_factory }

  context 'created with default values' do

    before(:each) { @lesson = FactoryGirl.create(:lesson, name: nil) }
    after(:each)  { @lesson.destroy }
    subject { @lesson }

    its(:status) { should eq 'publishing' }
    its(:name)   { should eq File.basename @lesson.url, '.git' }

  end

  context 'given a non-existent user' do
    it 'does not allow the lesson to be created' do
      ids = User.pluck :id
      id = Random.rand(1000) while ids.include?(id)
      FactoryGirl.build(:lesson, user_id: id).should_not be_valid
    end
  end

  context 'given an existing user' do
    before(:each) { @user = FactoryGirl.create :user }
    after(:each)  { @user.destroy }
    it 'allows the lesson to be created' do
      FactoryGirl.build(:lesson, user_id: @user.id).should be_valid
    end
  end

  context 'given an existing lesson' do

    before(:each) { @lesson = FactoryGirl.create :lesson }
    after(:each)  { @lesson.destroy }
    subject       { @lesson }

    describe '#path' do
      it 'returns a clean path' do
        @lesson.path.to_s.should \
          match %r[^#{@lesson.user.nickname.parameterize}.*\/.*#{@lesson.name.parameterize}$]
      end
    end

    describe '#to_param' do
      it 'uses parameterized lesson name' do
        l = FactoryGirl.create(:lesson, name: 'here is some t/xt')
        l.to_param.should eq 'here-is-some-t-xt'
        l.destroy
      end
    end

    describe '#published' do

      let(:cp) { SecureRandom.uuid }
      let(:sp) { SecureRandom.uuid }

      before :each do
        Lesson.find_by_id(@lesson.id).published(cp, sp)
        @lesson.reload
      end

      subject { @lesson}
      its(:compiled_path) { should eq cp }
      its(:solution_path) { should eq sp }
      its(:status) { should eq 'published' }

    end

    describe '#failed' do
      before :each do
        @lesson.failed
        @lesson.reload
      end
      its(:status) { should eq 'failed' }
    end

    describe '#pushed' do

      let(:push) { Lesson.pushed @lesson.user.id, @lesson.name }

      it 'returns a lesson' do
        push.should be_kind_of Lesson
      end

      it 'sets the status to `publishing`' do
        @lesson.reload
        @lesson.status.should eq 'publishing'
      end

    end

  end

end

describe Lesson, '.published' do

  it 'includes published lessons' do
    lesson = FactoryGirl.create :lesson, status: 'published'
    Lesson.published.should include(lesson)
  end

  it 'excludes non-published lessons' do
    lesson = FactoryGirl.create :lesson
    Lesson.published.should_not include(lesson)
  end

end
