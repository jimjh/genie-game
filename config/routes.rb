Genie::Application.routes.draw do

  # User management w. Devise ------------------------------------------------
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_session
  end

  # Lessons Controller -------------------------------------------------------
  resources :lessons, only: [:create, :destroy] do
    member do
      post :toggle
      post :ready,  # Lamp Hook
        constraints: lambda { |r| Rails.configuration.lamp[:ips].include? r.remote_ip }
      post :gone,   # Lamp Hook
        constraints: lambda { |r| Rails.configuration.lamp[:ips].include? r.remote_ip }
    end
    post :push, on: :collection # GitHub Hook
  end

  resources :access_requests do
    post :grant,  on: :member
    post :deny,   on: :member
    get  :export, on: :collection
  end

  resources :answers
  resources :terminals

  # Settings Controller ------------------------------------------------------
  scope path: 'settings', controller: :settings, as: 'settings' do
    match '/'               => :repositories
    match '/authorizations' => :authorizations, as: 'authorizations'
  end

  # Home
  root :to => 'home#index'
  match '/tty' => 'home#tty'

  # Pretty URLs --------------------------------------------------------------
  scope path: ':user/:lesson', controller: :lessons, as: 'user_lesson' do
    # add trailing slashes to lessons/jimjh/floating-point so that relative
    #   links for images resolve to jimjh/floating-point/images.
    match '' => redirect('/%{user}/%{lesson}/'), via: :get,
      constraints: lambda { |r| !r.original_fullpath.ends_with? '/' }
    match '/settings(/*path)' => :settings, as: 'settings', via: :get,
      defaults: { path: 'default' }
    match '/stats' => :stats,  via: :get
    match '(/*path)' => :show, via: :get,
      defaults: { path: LessonsController::INDEX_FILE }
  end

end
