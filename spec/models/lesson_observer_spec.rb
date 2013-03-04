require 'spec_helper'
require 'lamp/thrift/client'

describe LessonObserver do

  self.use_transactional_fixtures = false

  let(:lesson)   { FactoryGirl.build :lesson }
  let(:observer) { LessonObserver.any_instance }
  subject        { lesson }

  before(:each) { Rails.application.routes.default_url_options[:host] = 'test.host' }
  after(:each)  { lesson.destroy if lesson.persisted? }

  shared_context 'destroying a lesson', observe_destroy: true do
    before :each do
      lesson.hook = (Random.rand(1000) + 1).to_s
      lesson.save!
      ActiveRecord::Observer.enable_observers
    end
    after(:each) { ActiveRecord::Observer.disable_observers }
  end

  shared_context 'creating a lesson', observe_create: true do
    before(:each) { ActiveRecord::Observer.enable_observers }
    after(:each)  { ActiveRecord::Observer.disable_observers }
  end

  let(:lamp_client)   { stub(create: true, transport: stub(open: 0, close: 0)) }
  let(:github_client) { stub(repos: stub(hooks: stub(create: stub(id: 0), delete: true))) }

  describe '#github' do

    before(:each) do

      observer.stubs(:lamp_client).returns(lamp_client)

      @hooks = mock('hooks')
      @auth  = lesson.user.authorizations.first
      github_client.repos.stubs(:hooks).returns(@hooks)
      observer.stubs(:github).returns([@auth, github_client])

    end

    context 'create', :observe_create do

      it 'creates a web hook' do
        @hooks.expects(:create).once
          .with(@auth.nickname, lesson.name, anything)
          .returns(Hashie::Mash.new id: 0)
        lesson.save!
      end

      it 'deletes the web hook if a rollback was issued' do
        lamp_client.stubs(:create).raises(Lamp::RPCError)
        @hooks.expects(:create).once
          .with(@auth.nickname, lesson.name, anything)
          .returns(Hashie::Mash.new id: 0)
        expect { lesson.save! }.to raise_error(ActiveRecord::RecordNotSaved)
      end

    end

    context 'destroy', :observe_destroy do
      it 'deletes the web hook' do
        @hooks.expects(:delete).once.with(@auth.nickname, lesson.name, lesson.hook)
        lesson.destroy
      end
    end

  end

  describe '#lamp_client' do

    before(:each) do
      auth   = lesson.user.authorizations.first
      observer.stubs(:github).returns([auth, github_client])
      observer.stubs(:lamp_client).returns(lamp_client)
    end

    context 'create', :observe_create do

      it 'invokes lamp create' do
        lamp_client.expects(:create).once
          .with(lesson.url, is_a(String), is_a(String), {})
          .returns(true)
        lesson.save!
      end

      it 'raises an exception if lamp fails' do
        lamp_client.expects(:create).once
          .with(lesson.url, is_a(String), is_a(String), {})
          .raises(Lamp::RPCError)
        expect { lesson.save! }.to raise_error(ActiveRecord::RecordNotSaved)
      end

      it 'invokes lamp rm when a rollback is issued' do
        lamp_client.expects(:create).once
          .with(lesson.url, is_a(String), is_a(String), {})
          .raises(Lamp::RPCError)
        lamp_client.expects(:remove).once
          .with(regexp_matches(/#{lesson.name.parameterize}$/), is_a(String))
          .returns(true)
        expect { lesson.save! }.to raise_error(ActiveRecord::RecordNotSaved)
      end

    end

    context 'destroy', :observe_destroy do
      it 'invokes lamp rm' do
        lamp_client.expects(:remove).once
          .with(regexp_matches(/#{lesson.name.parameterize}\z/), is_a(String))
          .returns(true)
        lesson.destroy
      end
    end

  end

end
