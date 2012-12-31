Genie::Application.routes.draw do

  match 'new' => 'lessons#new'

  # add trailing slashes to lessons/jimjh/floating-point so that relative links
  # for images resolve to jimjh/floating-point/images.
  match ':user/:project' => redirect('/%{user}/%{project}/'),
    constraints: lambda { |r| !r.original_fullpath.ends_with? '/' }

  match ':user/:project/verify/:type/:problem' => 'lessons#verify'
  match ':user/:project(/*path)' => 'lessons#show'

  root :to => 'home#index'

end
