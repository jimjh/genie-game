# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Lesson do

  it { should respond_to(:name) }
  it { should respond_to(:url) }
  it { should respond_to(:path) }

  it { should belong_to(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:user_id) }
  it { should validate_uniqueness_of(:name).scoped_to(:user_id) }

  def self.allow_url(s)
    it { should allow_value("#{s}://host.xz/path/to/repo.git/").for(:url) }
    it { should allow_value("#{s}://user@host.xz/path/to/repo.git/").for(:url) }
    it { should allow_value("#{s}://user@host.xz:123/path/to/repo.git/").for(:url) }
    it { should allow_value("#{s}://host.xz:123/path/to/repo.git/").for(:url) }
  end
  %w(ssh git http https ftp ftps rsync).each { |scheme| allow_url scheme }

  it { should allow_value('host.xz:path/to/repo.git/').for(:url) }
  it { should allow_value('user@host.xz:path/to/repo.git/').for(:url) }

  it { should_not allow_value('ftp://localhost/path/to/repo.git/').for(:url) }
  it { should_not allow_value('ftp://127.0.0.1/path/to/repo.git/').for(:url) }
  it { should_not allow_value('ftp://0.0.0.0/path/to/repo.git/').for(:url) }
  it { should_not allow_value('ftp://host.xz/path/to/repo/').for(:url) }

  context 'Creating a user' do

    before :each do
      @user   = FactoryGirl.create :user
    end

    after :each do
      [@user].map(&:destroy)
    end

    it 'should ensure that user exists' do
      FactoryGirl.build(:lesson, user_id: @user.id + 1).should_not be_valid
      FactoryGirl.build(:lesson, user_id: @user.id).should be_valid
    end

    it 'should return a clean path' do
      FactoryGirl.build(:lesson).path.to_s.should eq 'cnorries/xyz'
      FactoryGirl.build(:lesson, name: 'ha ha').path.to_s.should eq 'cnorries/ha-ha'
    end

    it 'should use parameterized lesson name for to_param' do
      l = FactoryGirl.build(:lesson, name: 'here is some t/xt')
      l.to_param.should eq 'here-is-some-t-xt'
    end

  end

end
