require 'spec_helper'
require 'lamp/rpc/client'

describe LessonObserver do

  self.use_transactional_fixtures = false

  let(:lesson)   { FactoryGirl.build :lesson }
  let(:observer) { LessonObserver.any_instance }
  subject        { lesson }

  let(:hook_id)       { Random.rand 10000 }
  let(:lamp_client)   { stub(create: true, transport: stub(open: 0, close: 0), remove: true) }
  let(:github_hooks)  { stub(create: stub(id: hook_id), delete: true) }
  let(:github_client) { stub(repos: stub(hooks: github_hooks))  }


  before(:each)  do
    Rails.application.routes.default_url_options[:host] = 'test.host'
    @auth  = lesson.user.authorizations.first
    observer.stubs(:lamp_client).returns(lamp_client)
    observer.stubs(:github).returns([@auth, github_client])
    ActiveRecord::Observer.enable_observers
  end

  after(:each) do
    ActiveRecord::Observer.disable_observers
    lesson.destroy if lesson.persisted?
  end

  describe 'create' do

    it 'creates a web hook' do
      github_hooks.expects(:create).once
        .with(@auth.nickname, lesson.name, has_key(:config) & has_entry(:name, 'web'))
        .returns(Hashie::Mash.new id: hook_id)
      lesson.save!
    end

    it 'deletes the web hook if a rollback was issued' do
      github_hooks.expects(:delete).once
        .with(@auth.nickname, lesson.name, hook_id)
      Lesson.transaction do
        lesson.save!
        raise ActiveRecord::Rollback, 'to force a rollback'
      end
    end

    it 'tells compiler to create files' do
      lamp_client.expects(:create).once
        .with(lesson.url,
              regexp_matches(%r[#{lesson.name.parameterize}]),
              regexp_matches(%r[\/lessons\/\d+\/ready$]), {})
        .returns(true)
      lesson.save!
    end

    it 'sets status to `failed` if the lamp RPC threw an exception' do
      lamp_client.expects(:create).once.raises(Lamp::RPCError)
      lesson.save!
      lesson.status.should eq 'failed'
    end

  end

  describe '#destroy' do

    before(:each) do
      lesson.hook = Random.rand(1000).to_s
      lesson.save!
    end

    it 'deletes the web hook' do
      github_hooks.expects(:delete).once
        .with(@auth.nickname, lesson.name, lesson.hook)
      lesson.destroy
    end

    it 'tells compiler to delete files' do
      lamp_client.expects(:remove).once
        .with(regexp_matches(%r[#{lesson.name.parameterize}$]),
              regexp_matches(%r[\/lessons\/\d+\/gone$]))
        .returns(true)
      lesson.destroy
    end

  end

  describe '#published' do

    it 'does not use github_client' do
      github_hooks.expects(:create).never
      github_hooks.expects(:delete).never
      lesson.published '', ''
    end

    it 'does not use lamp_client' do
      lamp_client.expects(:create).never
      lamp_client.expects(:remove).never
      lesson.published '', ''
    end

  end

  describe '#failed' do

    it 'does not use github_client' do
      github_hooks.expects(:create).never
      github_hooks.expects(:delete).never
      lesson.failed
    end

    it 'does not use lamp_client' do
      lamp_client.expects(:create).never
      lamp_client.expects(:remove).never
      lesson.failed
    end

  end

  describe '#pushed' do

    it 'tells compiler to create files' do
      lamp_client.expects(:create).once
        .with(lesson.url,
              regexp_matches(%r[#{lesson.name.parameterize}]),
              regexp_matches(%r[\/lessons\/\d+\/ready$]), {})
        .returns(true)
      lesson.pushed
    end

    it 'sets status to `failed` if the lamp RPC threw an exception' do
      lamp_client.expects(:create).once.raises(Lamp::RPCError)
      lesson.pushed
      lesson.status.should eq 'failed'
    end

  end

end
