require 'spec_helper'

describe GithubConcern do

  class GithubConcernedDummyClass; end

  before :each do
    @dummy = GithubConcernedDummyClass.new
    @dummy.extend GithubConcern
  end

  subject { @dummy }
  let(:user) { Faker::Internet.user_name }
  let(:repo) { Faker::Internet.user_name }

  it 'generates valid tokens' do
    token = @dummy.create_hook_access_token user, repo
    @dummy.verify_hook_access_token(token, user, repo).should be true
  end

  it 'rejects invalid tokens' do
    token = @dummy.create_hook_access_token user, repo
    @dummy.verify_hook_access_token(token, user + 'x', repo).should be false
  end

end
