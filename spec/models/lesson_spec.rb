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

  %w(name url path slug compiled_path status action title description)
  .each do |s|
    it { should respond_to(s.to_sym) }
  end

  it { should belong_to(:user) }
  it { should have_many(:problems).order('digest').dependent(:destroy) }
  it { should have_many(:answers).through(:problems) }

  %w(name url user_id).each do |s|
    it { should validate_presence_of(s.to_sym) }
  end

  %w(name url title description).each do |s|
    it { should allow_mass_assignment_of s.to_sym }
  end

  %w(path slug compiled_path status action updated_at created_at)
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
        @lesson.published compiled_path: cp
        @lesson.reload
      end

      its(:compiled_path) { should eq cp }
      its(:status) { should eq 'published' }

    end

    describe '#deactivate' do
      before :each do
        @lesson.deactivate
        @lesson.reload
      end
      its(:status) { should eq 'deactivated' }
      its(:deactivate) { should be false }
    end

    describe '#activate' do
      before :each do
        @lesson.activate
        @lesson.reload
      end
      its(:status) { should eq 'publishing' }
      its(:activate) { should be true }
    end

    describe '#failed' do
      before :each do
        @lesson.failed
        @lesson.reload
      end
      its(:status) { should eq 'failed' }
      its(:failed) { should be true }
    end

    describe '#pushed' do
      before :each do
        @lesson.pushed
        @lesson.reload
      end
      its(:status) { should eq 'publishing' }
      its(:pushed) { should be true }
    end

    describe '#path_to' do

      before :each do
        @lesson = FactoryGirl.create :lesson, :published
        IO.write File.join(@lesson.compiled_path, 'x.png'), 'xkcd'
        IO.write File.join(@lesson.compiled_path, 'x'), 'xkcd'
      end

      after :each do
        FileUtils.remove_entry File.join @lesson.compiled_path, 'x.png'
        FileUtils.remove_entry File.join @lesson.compiled_path, 'x'
      end

      let(:path)    { @lesson.path_to subpath, format }
      let(:subpath) { 'x' }
      let(:format)  { 'png' }
      subject       { path }

      context 'without format' do
        let(:format) { nil }
        it { should eq Pathname.new File.join @lesson.compiled_path, 'x' }
      end

      context 'with format' do
        it { should eq Pathname.new File.join @lesson.compiled_path, 'x.png' }
      end

      context 'given a non-existent file' do
        let(:subpath) { 'y.xkcd' }
        it 'raises ActiveRecord::RecordNotFound' do
          expect { path }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'given an attempted directory traversal' do
        let(:subpath) { '../configu.ru' }
        it 'raises ActiveRecord::RecordNotFound' do
          expect { path }.to raise_error ActiveRecord::RecordNotFound
        end
      end

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

      before(:each) { init_old_problems }
      after(:each)  { @lesson.problems.map(&:destroy) }
      let(:old_problems) { @old_problems.map(&:reload); @old_problems }

      describe '#problem_at' do
        it 'returns the solution for the correct problem' do
          @lesson.problem_at(0).solution.should eq old_problems.first.solution
          @lesson.problem_at(old_problems.length - 1).solution.should eq old_problems.last.solution
        end
        it 'raises an error if the problem does not exist' do
          expect { @lesson.problem_at(old_problems.length) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      describe '#problems', '#update_or_initialize' do

        before :each do
          init_new_problems
          # reuse the second and sixth problem
          @new_problems[3] = { digest: @old_problems[1].digest }
          @new_problems   << { digest: @old_problems[5].digest }
          @lesson.problems.update_or_initialize new_problems
          @lesson.save!
        end
        let(:new_problems) { @new_problems }

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

describe Lesson, '.for_user' do

  context 'given 2 users' do

    before :each do
      @users = []
      @users << FactoryGirl.create(:lesson).user
      @users << FactoryGirl.create(:lesson).user
      FactoryGirl.create(:lesson, user: @users.first)
    end

    after :each do
      @users.map(&:destroy)
    end

    it 'returns all lessons for the correct user' do
      Lesson.for_user(@users.first.slug).pluck(:id).sort.should eq @users.first.lessons.pluck(:id).sort
    end

  end

end
