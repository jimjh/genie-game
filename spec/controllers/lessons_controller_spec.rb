# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe LessonsController do

  describe 'GET #show' do

    before(:each) { @fake = FactoryGirl.create :compiled_lesson }
    after(:each)  { @fake.root.rmtree }

    it 'assigns index.inc' do
      get :show, user: @fake.user, lesson: @fake.lesson
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

    it 'protects against traversal attacks in path' do
      %w[.. ../..].each do |c|
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

    it 'defaults to index.inc' do
      get :show, user: @fake.user, lesson: @fake.lesson
      assigns[:contents].should eq @fake.index_file
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
    it 're-compiles the lesson'
    it 'sets status to publishing'
    it 'handles errors'
  end

  describe 'POST #ready' do
    context 'success' do
      it 'sets status to published'
    end
    context 'failure' do
      it 'sets status to failed'
    end
  end

  describe 'POST #gone' do
    it 'does something'
  end

  describe 'POST #verify' do
    it 'requires user, lesson, and problem'
    it 'raises ActionDispatch::RoutingError if the path is not a file'
    pending 'judge service'
  end

end

