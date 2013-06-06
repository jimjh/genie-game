require 'spec_helper'

describe HookConcern do

  class HookConcernedDummyClass; end

  before :each do
    @dummy = HookConcernedDummyClass.new
    @dummy.extend HookConcern
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
