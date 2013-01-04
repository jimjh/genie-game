# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe LessonsController do

  describe 'GET #show' do

    before :each do
      @fake_user   = SecureRandom.uuid
      @fake_lesson = Faker::Company.name
      @fake_user_path   = LessonsController::COMPILED_PATH + @fake_user
      @fake_lesson_path = @fake_user_path + @fake_lesson.parameterize
      @fake_lesson_path.mkpath
    end

    after :each do
      @fake_user_path.rmtree
    end

    it 'assigns index.inc' do
      rand = random_file @fake_lesson_path + LessonsController::INDEX_FILE
      get :show, user: @fake_user, lesson: @fake_lesson
      assigns[:contents].should eql rand
    end

    it 'requires user' do
      get :show, user: '', lesson: @fake_lesson
      response.should be_bad_request
      expect { get :show, lesson: @fake_lesson }.to raise_error(ActionController::RoutingError)
    end

    it 'requires lesson' do
      get :show, user: @fake_user, lesson: ''
      response.should be_bad_request
      expect { get :show, user: @fake_user}.to raise_error(ActionController::RoutingError)
    end

    it 'sanitizes user and lesson' do
      get :show, user: '<>..', lesson: ' %'
      response.should be_bad_request
    end

    it 'protects against traversal attacks in user' do
      %w(. ../ ../../).each do |c|
        get :show, user: c, lesson: @fake_lesson
        response.should be_bad_request
      end
    end

    it 'protects against traversal attacks in lesson' do
      %w(. ../ ../../).each do |c|
        get :show, user: @fake_user, lesson: c
        response.should be_bad_request
      end
    end

    it 'protects against traversal attacks in path' do
      %w(. ../ ../../).each do |c|
        get :show, user: @fake_user, lesson: @fake_lesson, path: c
        response.should be_bad_request
      end
    end

    it 'sends static assets as attachments' do
      (@fake_lesson_path + 'img').mkpath
      rand = random_file @fake_lesson_path + 'img' + 'x'
      get :show, user: @fake_user, lesson: @fake_lesson, path: 'img/x'
      response.headers['Content-Disposition'].should_not be_nil
      response.headers['Content-Disposition'].should match(/attachment/)
      response.content_type.should match(/octet-stream/)
      response.body.should eq rand
    end

    it 'sends static assets, including .inc files, as attachments' do
      (@fake_lesson_path + 'img').mkpath
      rand = random_file @fake_lesson_path + 'img' + 'x.inc'
      get :show, user: @fake_user, lesson: @fake_lesson, path: 'img/x.inc'
      response.headers['Content-Disposition'].should_not be_nil
      response.headers['Content-Disposition'].should match(/attachment/)
      response.content_type.should match(/octet-stream/)
      response.body.should eq rand
    end

    it 'defaults to index.inc' do
      rand = random_file @fake_lesson_path + LessonsController::INDEX_FILE
      get :show, user: @fake_user, lesson: @fake_lesson
      assigns[:contents].should eq rand
    end

    it 'raises ActionDispatch::RoutingError if the path does not exist' do
      expect do
        get :show, user: @fake_user, lesson: @fake_lesson, path: 'xyz'
      end.to raise_error(ActionController::RoutingError)
    end

  end

  describe 'POST #verify' do
    it 'requires user, lesson, and problem'
    it 'raises ActionDispatch::RoutingError if the path is not a file'
    pending 'judge service'
  end

  describe 'POST #create' do
    it 'cannot be made to execute arbitrary commands'
    it 'clones and compiles a lesson at the given URL'
    pending 'rabbitmq'
    pending 'error handling'
  end

end

