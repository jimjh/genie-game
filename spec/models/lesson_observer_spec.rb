require 'spec_helper'

describe LessonObserver do

  self.use_transactional_fixtures = false

  before :each do

    Rails.application.routes.default_url_options[:host] = 'test.host'

    @lesson = FactoryGirl.build :lesson
    @auth   = @lesson.user.authorizations.first
    client, repos, @hooks = mock('client'), mock('repos'), mock('hooks')
    client.stubs(:repos).returns(repos)
    repos .stubs(:hooks).returns(@hooks)
    LessonObserver.any_instance.stubs(:github).returns([@auth, client])

  end

  after :each do
    @lesson.destroy if @lesson.persisted?
  end

  it 'creates a web hook when a new lesson is created' do
    ActiveRecord::Observer.with_observers(:lesson_observer) do
      @hooks.expects(:create).once
        .with(@auth.nickname, @lesson.name, anything)
        .returns(Hashie::Mash.new id: 0)
      @lesson.save!
    end
    @lesson.destroy
  end

  it 'deletes the web hook if a rollback was issued' do
    pending 'how to force rollback?' do
      ActiveRecord::Observer.with_observers(:lesson_observer) do
        @hooks.expects(:create).once
          .with(@auth.nickname, @lesson.name, anything)
          .returns(Hashie::Mash.new id: 0)
        expect { @lesson.save! }.to raise_error
      end
    end
  end

  it 'deletes the web hook when the lesson is destroyed' do
    @lesson.hook = (Random.rand(1000) + 1).to_s
    @lesson.save!
    ActiveRecord::Observer.with_observers(:lesson_observer) do
      @hooks.expects(:delete).once.with(@auth.nickname, @lesson.name, @lesson.hook)
      @lesson.destroy
    end
  end

end
