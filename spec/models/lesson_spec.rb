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
  it { should have_many(:problems).order('digest').dependent(:destroy) }

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
  it { should validate_existence_of :user }

  context 'created with default values' do

    before(:each) { @lesson = FactoryGirl.create(:lesson, name: nil) }
    after(:each)  { @lesson.destroy }
    subject { @lesson }

    its(:status) { should eq 'publishing' }
    its(:name)   { should eq File.basename @lesson.url, '.git' }

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
        @lesson.published(compiled_path: cp, solution_path: sp)
        @lesson.reload
      end

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
      before :each do
        @lesson.pushed
        @lesson.reload
      end
      its(:status) { should eq 'publishing' }
    end

    context 'with some existing problems' do

      # create 6 old problems
      def init_old_problems
        @old_problems = []
        6.times do
          @old_problems << FactoryGirl.create(:problem, lesson: @lesson, position: @old_problems.length)
        end
      end

      # build 5 new problems
      def init_new_problems
        @new_problems = []
        5.times do
          @new_problems << FactoryGirl.build(:problem_digest)
        end
      end

      before :each do
        init_old_problems
        init_new_problems
        # reuse the second and sixth problem
        @new_problems[3] = { digest: @old_problems[1].digest }
        @new_problems   << { digest: @old_problems[5].digest }
      end

      after(:each) { @lesson.problems.map(&:destroy) }

      let(:old_problems) { @old_problems.map(&:reload); @old_problems }
      let(:new_problems) { @new_problems }

      describe '#problems', '#update_or_initialize' do

        before :each do
          @lesson.problems.update_or_initialize new_problems
          @lesson.save!
        end

        it 'updates position of existing problems' do
          old_problems[1].position.should be 3
          old_problems[5].position.should be 5
        end

        it 'creates new problems' do
          new_problems.each_with_index do |p, i|
            Problem.should be_exists(digest: p[:digest])
          end
        end

        it 'deactivates missing problems' do
          old_problems.each_with_index do |p, i|
            case i
            when 1, 5 then p.should be_active
            else p.should_not be_active
            end
          end
        end

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
