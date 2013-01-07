Genie::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' } do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :lessons, except: [:new, :show, :index, :edit, :update] do
    post :push, on: :collection,
      constraints: lambda { |r| Rails.configuration.github[:ips].include? r.remote_ip }
  end

  match 'settings' => 'settings#index'

  # add trailing slashes to lessons/jimjh/floating-point so that relative
  #   links for images resolve to jimjh/floating-point/images.
  match ':user/:lesson' => redirect('/%{user}/%{lesson}/'),
    via: :get, constraints: lambda { |r| !r.original_fullpath.ends_with? '/' }
  match ':user/:lesson/verify/:type/:problem' => 'lessons#verify', via: :post
  match ':user/:lesson(/*path)' => 'lessons#show', as: 'lesson', via: :get

  root :to => 'home#index'

end
