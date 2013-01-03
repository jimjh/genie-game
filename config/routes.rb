Genie::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }

  match 'new' => 'lessons#new', as: 'new_lesson', via: :get

  constraints :user => /(?!new|users|devise)/ do
    # add trailing slashes to lessons/jimjh/floating-point so that relative
    #   links for images resolve to jimjh/floating-point/images.
    match ':user/:lesson' => redirect('/%{user}/%{lesson}/'),
      constraints: lambda { |r| !r.original_fullpath.ends_with? '/' }
    match ':user/:lesson/verify/:type/:problem' => 'lessons#verify'
    match ':user/:lesson(/*path)' => 'lessons#show', as: 'lesson'
  end

  resources :lessons, except: [:new, :show]

  root :to => 'home#index'

end
