Genie::Application.routes.draw do

  # User management w. Devise ------------------------------------------------
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' } do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  # Lessons Controller -------------------------------------------------------
  resources :lessons, only: [:create, :destroy] do
    post :push, on: :collection,
      constraints: lambda { |r| Rails.configuration.github[:ips].include? r.remote_ip }
  end

  # Settings Controller ------------------------------------------------------
  match ':controller(/:action)' => { controller: 'settings' }

  root :to => 'home#index'

  # Pretty URLs --------------------------------------------------------------

  # add trailing slashes to lessons/jimjh/floating-point so that relative
  #   links for images resolve to jimjh/floating-point/images.
  match ':user/:lesson' => redirect('/%{user}/%{lesson}/'),
    via: :get, constraints: lambda { |r| !r.original_fullpath.ends_with? '/' }
  match ':user/:lesson/verify/:type/:problem' => 'lessons#verify', via: :post
  match ':user/:lesson(/*path)' => 'lessons#show', as: 'lesson', via: :get

end
