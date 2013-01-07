require 'spec_helper'

describe LessonObserver do

  self.use_transactional_fixtures = false

  let(:lesson)      { FactoryGirl.build :lesson }
  let(:observer)    { LessonObserver.any_instance }
  subject           { lesson }

  before(:each) { Rails.application.routes.default_url_options[:host] = 'test.host' }
  after(:each)  { lesson.destroy if lesson.persisted? }

  shared_context 'destroying a lesson', observe_destroy: true do
    before :each do
      lesson.hook = (Random.rand(1000) + 1).to_s
      lesson.save!
      ActiveRecord::Observer.enable_observers
    end
    after :each do
      ActiveRecord::Observer.disable_observers
    end
  end

  shared_context 'creating a lesson', observe_create: true do
    before :each do
      ActiveRecord::Observer.enable_observers
    end
    after :each do
      ActiveRecord::Observer.disable_observers
    end
  end

  describe '#github' do

    before(:each) do
      @hooks = mock('hooks')
      client = stub(repos: stub(hooks: @hooks))
      @auth  = lesson.user.authorizations.first
      observer.stubs(:github).returns([@auth, client])
      observer.stubs(:system).returns(true)
    end

    context 'create', :observe_create do

      it 'creates a web hook' do
        @hooks.expects(:create).once
          .with(@auth.nickname, lesson.name, anything)
          .returns(Hashie::Mash.new id: 0)
        lesson.save!
      end

      it 'deletes the web hook if a rollback was issued' do
        observer.stubs(:system).returns(false)
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

  describe '#system' do

    before(:each) do
      client = stub(repos: stub(hooks: stub(create: stub(id: 0), delete: true)))
      auth   = lesson.user.authorizations.first
      observer.stubs(:github).returns([auth, client])
    end

    context 'create', :observe_create do

      it 'invokes lamp create' do
        observer.expects(:system).once
          .with('lamp', 'create', lesson.url, anything)
          .returns(true)
        lesson.save!
      end

      it 'raises an exception if lamp fails' do
        observer.expects(:system).once
          .with('lamp', 'create', lesson.url, anything)
          .returns(false)
        expect { lesson.save! }.to raise_error(ActiveRecord::RecordNotSaved)
      end

      it 'invokes lamp rm when a rollback is issued' do
        observer.expects(:system).once
          .with('lamp', 'create', lesson.url, anything)
          .returns(false)
        observer.expects(:system).once
          .with('lamp', 'rm', regexp_matches(/#{lesson.name.parameterize}\z/))
          .returns(true)
        expect { lesson.save! }.to raise_error(ActiveRecord::RecordNotSaved)
      end

    end

    context 'destroy', :observe_destroy do
      it 'invokes lamp rm' do
        observer.expects(:system).once
          .with('lamp', 'rm', lesson.path.to_s)
          .returns(true)
        lesson.destroy
      end
    end

  end

  it 'adds a build task'

end
