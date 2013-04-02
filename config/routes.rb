Genie::Application.routes.draw do

  # User management w. Devise ------------------------------------------------
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_session
  end

  # Lessons Controller -------------------------------------------------------
  resources :lessons, only: [:create, :destroy] do
    post :push, on: :collection # GitHub Hook
    post :ready, on: :member, # Lamp Hook
      constraints: lambda { |r| Rails.configuration.lamp[:ips].include? r.remote_ip }
    post :gone,  on: :member, # Lamp Hook
      constraints: lambda { |r| Rails.configuration.lamp[:ips].include? r.remote_ip }
  end

  # Settings Controller ------------------------------------------------------
  scope path: 'settings', controller: :settings, as: 'settings' do
    match '/'             => redirect('/settings/profile')
    match '/profile'      => :profile,      :as => 'profile'
    match '/repositories' => :repositories, :as => 'repositories'
  end

  # Home
  root :to => 'home#index'

  # Pretty URLs --------------------------------------------------------------

  match '/closed_beta' => 'home#closed_beta'
  match '/welcome' => 'home#welcome'

  # add trailing slashes to lessons/jimjh/floating-point so that relative
  #   links for images resolve to jimjh/floating-point/images.
  match ':user/:lesson' => redirect('/%{user}/%{lesson}/'),
    via: :get, constraints: lambda { |r| !r.original_fullpath.ends_with? '/' }
  match ':user/:lesson/verify/:type/:problem' => 'lessons#verify', via: :post
  match ':user/:lesson(/*path)' => 'lessons#show', as: 'user_lesson', via: :get

end
