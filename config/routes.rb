Genie::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }

  match 'new' => 'lessons#new'
  match 'create' => 'lessons#create', via: 'post'

  # add trailing slashes to lessons/jimjh/floating-point so that relative links
  # for images resolve to jimjh/floating-point/images.
  match ':user/:project' => redirect('/%{user}/%{project}/'),
    constraints: lambda { |r| !r.original_fullpath.ends_with? '/' }

  match ':user/:project/verify/:type/:problem' => 'lessons#verify'
  match ':user/:project(/*path)' => 'lessons#show'

  root :to => 'home#index'

end
