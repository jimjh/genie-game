# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Lesson do

  %w(name url path slug action skip_observer compiled_path solution_path).each do |s|
    it { should respond_to(s.to_sym) }
  end

  it { should belong_to(:user) }

  %w(name url user_id).each do |s|
    it { should validate_presence_of(s.to_sym) }
  end

  %w(name url).each do |s|
    it { should allow_mass_assignment_of s.to_sym }
  end

  %w(path slug action skip_observer compiled_path solution_path).each do |s|
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

  it { should have_a_valid_factory }

  context 'given a non-existent user' do
    it 'does not allow the lesson to be created' do
      ids = User.pluck :id
      id = Random.rand(1000) while ids.include?(id)
      FactoryGirl.build(:lesson, user_id: id).should_not be_valid
    end
  end

  context 'given an existing user' do

    before :each do
      @user   = FactoryGirl.create :user
    end

    after :each do
      [@user].map(&:destroy)
    end

    it 'allows the lesson to be created' do
      FactoryGirl.build(:lesson, user_id: @user.id).should be_valid
    end

    describe '#path' do
      it 'returns a clean path' do
        l = FactoryGirl.create(:lesson, user: @user, name: 'ha ha')
        l.path.to_s.should eq @user.nickname.parameterize+'/ha-ha'
        l.destroy
      end
    end

    describe '#to_param' do
      it 'uses parameterized lesson name' do
        l = FactoryGirl.create(:lesson, name: 'here is some t/xt')
        l.to_param.should eq 'here-is-some-t-xt'
        l.destroy
      end
    end

    it 'defaults lesson name to basename of URL' do
      l = FactoryGirl.create(:lesson, user: @user, name: nil)
      l.name.should eq File.basename l.url, '.git'
      l.destroy
    end

  end

end
