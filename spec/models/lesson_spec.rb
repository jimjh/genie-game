# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Lesson do

  %w(name url path slug action).each do |s|
    it { should respond_to(s.to_sym) }
  end

  it { should belong_to(:user) }

  %w(name url user_id).each do |s|
    it { should validate_presence_of(s.to_sym) }
  end

  it { should validate_uniqueness_of(:name).scoped_to(:user_id) }

  def self.allow_scheme(s)
    it { should allow_value("#{s}://host.xz/path/to/repo.git/").for(:url) }
    it { should allow_value("#{s}://user@host.xz/path/to/repo.git/").for(:url) }
    it { should allow_value("#{s}://user@host.xz:123/path/to/repo.git/").for(:url) }
    it { should allow_value("#{s}://host.xz:123/path/to/repo.git/").for(:url) }
  end
  %w(ssh git http https ftp ftps rsync).each { |scheme| allow_scheme scheme }

  # should allow scp style
  it { should allow_value('host.xz:path/to/repo.git/').for(:url) }
  it { should allow_value('user@host.xz:path/to/repo.git/').for(:url) }

  # should not allow local
  it { should_not allow_value('ftp://localhost/path/to/repo.git/').for(:url) }
  it { should_not allow_value('ftp://127.0.0.1/path/to/repo.git/').for(:url) }
  it { should_not allow_value('ftp://0.0.0.0/path/to/repo.git/').for(:url) }

  # should check for suffix
  it { should_not allow_value('ftp://host.xz/path/to/repo/').for(:url) }

  context 'given a non-existent user' do
    it 'does not allow the lesson to be created' do
      ids = User.pluck :id
      begin id = Random.rand(1000) end while ids.include?(id)
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
        l = FactoryGirl.create(:lesson, user: @user)
        l.path.to_s.should eq @user.nickname.parameterize+'/'+l.name.parameterize
        l.destroy
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
