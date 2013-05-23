# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe LessonsController do

  describe 'GET #show' do

    before :each do
      @fake = FactoryGirl.create :compiled_lesson
      @user = FactoryGirl.create :user
      sign_in User.first
    end
    after(:each)  { @fake.root.rmtree }

    it 'assigns index.inc' do
      get :show, user: @fake.user, lesson: @fake.lesson, path: LessonsController::INDEX_FILE
      assigns[:contents].should eql @fake.index_file
    end

    it 'requires user' do
      expect { get :show, user: '', lesson: @fake.lesson }.to \
        raise_error(ActiveRecord::RecordNotFound)
      expect { get :show, lesson: @fake.lesson }.to \
        raise_error(ActiveRecord::RecordNotFound)
    end

    it 'requires lesson' do
      expect { get :show, user: @fake.user, lesson: '' }.to \
        raise_error(ActiveRecord::RecordNotFound)
      expect { get :show, user: @fake.user}.to \
        raise_error(ActiveRecord::RecordNotFound)
    end

    it 'requires published lesson' do
      Lesson.find(@fake.lesson).deactivate
      expect { get :show, user: @fake.user, lesson: @fake.lesson }.to \
        raise_error(ActionController::RoutingError)
    end

    it 'protects against traversal attacks in path' do
      %w[.. ../.. ../ / //].each do |c|
        expect { get :show, user: @fake.user, lesson: @fake.lesson, path: c }.to \
          raise_error(ActionController::RoutingError)
      end
    end

    context 'given static assets' do

      let(:file_name) { Faker::Lorem.word }

      before :each do
        (@fake.lesson_path + 'img').mkpath
        @rand_bin = random_file @fake.lesson_path + 'img' + file_name
        @rand_inc = random_file @fake.lesson_path + 'img' + "#{file_name}.inc"
      end

      it 'sends static assets as attachments' do
        get :show, user: @fake.user, lesson: @fake.lesson,
          path: "img/#{file_name}"
        response.headers['Content-Disposition'].should match(/attachment/)
        response.content_type.should match(/octet-stream/)
        response.body.should eq @rand_bin
      end

      it 'sends .inc files not at root as attachments' do
        get :show, user: @fake.user, lesson: @fake.lesson,
          path: "img/#{file_name}.inc"
        response.headers['Content-Disposition'].should match(/attachment/)
        response.content_type.should match(/octet-stream/)
        response.body.should eq @rand_inc
      end

    end

    it 'raises ActionController::RoutingError if the path does not exist' do
      expect do
        get :show, user: @fake.user, lesson: @fake.lesson, path: 'xyz'
      end.to raise_error(ActionController::RoutingError)
    end

  end

  describe 'POST #create' do

    it 'clones and compiles a lesson at the given URL'
    it 'handles errors'

  end

  describe 'POST #push' do

    before(:each) { @lesson = FactoryGirl.create :lesson, :published }
    after(:each)  { @lesson.destroy }

    let(:user) { @lesson.user }
    let(:auth) { @lesson.user.authorizations.first }

    it 're-compiles the lesson'
    it 'ignores deactivated lessons'
    it 'handles errors'

    it 'sets status to publishing' do
      github_http_login
      post :push, repository: { owner: { name: auth.nickname }, name: @lesson.name }
      @lesson.reload
      @lesson.status.should eq 'publishing'
    end

    it 'requires basic http auth' do
      post :push, repository: { owner: { name: auth.nickname }, name: @lesson.name }
      response.status.should eq 401
    end

  end

  describe 'POST #ready' do

    before(:each) { @lesson = FactoryGirl.create :lesson, :publishing }
    after(:each)  { @lesson.user.destroy }

    context 'success' do
      it 'sets status to published' do
        post :ready, id: @lesson.id, format: 'json',
          status: '200', payload: { compiled_path: 'x' }
        response.status.should eq 200
        @lesson.reload.status.should eq 'published'
      end
    end

    context 'failure' do
      it 'sets status to failed' do
        post :ready, id: @lesson.id, format: 'json'
        response.status.should eq 200
        @lesson.reload.status.should eq 'failed'
      end
    end

    it 'handles errors'
    it 'ignores deactivated lessons'

  end

  describe 'POST #gone' do
    it 'does something'
  end

  describe 'POST #verify' do
    it 'requires user, lesson, and problem'
    it 'raises ActionDispatch::RoutingError if the path is not a file'
    pending 'tangle service'
  end

  describe 'POST #toggle' do

    before :each do
      @lesson = FactoryGirl.create :lesson, :published
      sign_in @lesson.user
    end

    after(:each)  { @lesson.user.destroy }

    it 'deactivates the lesson' do
      post :toggle, id: @lesson.id, toggle: 'off', format: 'json'
      response.status.should eq 202
      @lesson.reload.status.should eq 'deactivated'
    end

    it 'publishes the lesson' do
      post :toggle, id: @lesson.id, toggle: 'on', format: 'json'
      response.status.should eq 202
      @lesson.reload.status.should eq 'publishing'
    end

    it 'handles errors'

  end

end
