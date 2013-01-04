# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Lesson do

  it { should respond_to(:name) }
  it { should respond_to(:url) }
  it { should respond_to(:path) }
  it { should respond_to(:slug) }

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

    it 'ensures that user exists' do
      FactoryGirl.build(:lesson, user_id: @user.id + 1).should_not be_valid
      FactoryGirl.build(:lesson, user_id: @user.id).should be_valid
    end

    context '#path' do
      it 'returns a clean path' do
        l = FactoryGirl.create(:lesson, user: @user)
        l.path.to_s.should eq @user.nickname.parameterize+'/'+l.name.parameterize
        l.destroy
        l = FactoryGirl.create(:lesson, user: @user, name: 'ha ha')
        l.path.to_s.should eq @user.nickname.parameterize+'/ha-ha'
        l.destroy
      end
    end

    it 'uses parameterized lesson name for to_param' do
      l = FactoryGirl.create(:lesson, name: 'here is some t/xt')
      l.to_param.should eq 'here-is-some-t-xt'
      l.destroy
    end

    it 'defaults lesson name to basename of URL' do
      l = FactoryGirl.create(:lesson, user: @user, name: nil, repo: 'x')
      l.should_not be_nil
      l.should be_valid
      l.name.should eq File.basename l.url, '.git'
      l.destroy
    end

  end

end
