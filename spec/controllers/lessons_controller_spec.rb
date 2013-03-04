# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe LessonsController do

  describe 'GET #show' do

    before(:each) { @fake = FactoryGirl.create :compiled_lesson }
    after(:each)  { @fake.root.rmtree }

    it 'assigns index.inc' do
      rand = random_file @fake.lesson_path + LessonsController::INDEX_FILE
      get :show, user: @fake.user, lesson: @fake.lesson
      assigns[:contents].should eql rand
    end

    it 'requires user' do
      expect { get :show, user: '', lesson: @fake.lesson }.to \
        raise_error(ActiveRecord::RecordNotFound)
      expect { get :show, lesson: @fake.lesson }.to \
        raise_error(ActionController::RoutingError)
    end

    it 'requires lesson' do
      expect { get :show, user: @fake.user, lesson: '' }.to \
        raise_error(ActiveRecord::RecordNotFound)
      expect { get :show, user: @fake.user}.to \
        raise_error(ActionController::RoutingError)
    end

    it 'sanitizes user and lesson' do
      expect { get :show, user: '<>..', lesson: ' %' }.to \
        raise_error(ActiveRecord::RecordNotFound)
    end

    it 'protects against traversal attacks in user' do
      %w(. ../ ../../).each do |c|
        expect { get :show, user: c, lesson: @fake.lesson }.to \
          raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'protects against traversal attacks in lesson' do
      %w(. ../ ../../).each do |c|
        expect { get :show, user: @fake.user, lesson: c }.to \
          raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'protects against traversal attacks in path' do
      %w(. ../ ../../).each do |c|
        expect { get :show, user: @fake.user, lesson: @fake.lesson, path: c }.to \
          raise_error(ActionController::RoutingError)
      end
    end

    it 'sends static assets as attachments' do
      (@fake.lesson_path + 'img').mkpath
      rand = random_file @fake.lesson_path + 'img' + 'x'
      get :show, user: @fake.user, lesson: @fake.lesson, path: 'img/x'
      response.headers['Content-Disposition'].should_not be_nil
      response.headers['Content-Disposition'].should match(/attachment/)
      response.content_type.should match(/octet-stream/)
      response.body.should eq rand
    end

    it 'sends static assets, including .inc files, as attachments' do
      (@fake.lesson_path + 'img').mkpath
      rand = random_file @fake.lesson_path + 'img' + 'x.inc'
      get :show, user: @fake.user, lesson: @fake.lesson, path: 'img/x.inc'
      response.headers['Content-Disposition'].should_not be_nil
      response.headers['Content-Disposition'].should match(/attachment/)
      response.content_type.should match(/octet-stream/)
      response.body.should eq rand
    end

    it 'defaults to index.inc' do
      rand = random_file @fake.lesson_path + LessonsController::INDEX_FILE
      get :show, user: @fake.user, lesson: @fake.lesson
      assigns[:contents].should eq rand
    end

    it 'raises ActionDispatch::RoutingError if the path does not exist' do
      expect do
        get :show, user: @fake.user, lesson: @fake.lesson, path: 'xyz'
      end.to raise_error(ActionController::RoutingError)
    end

  end

  describe 'POST #verify' do
    it 'requires user, lesson, and problem'
    it 'raises ActionDispatch::RoutingError if the path is not a file'
    pending 'judge service'
  end

  describe 'POST #create' do
    it 'clones and compiles a lesson at the given URL'
    pending 'compiler'
    pending 'error handling'
  end

  describe 'POST #push' do
    it 'updates the lesson'
  end

end

