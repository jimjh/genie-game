Genie::Application.routes.draw do

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  resources :lessons

  # add trailing slashes to lessons/jimjh/floating-point so that relative links
  # for images resolve to jimjh/floating-point/images.
  match 'lessons/:user/:project' => redirect('/lessons/%{user}/%{project}/'),
    constraints: lambda { |r| !r.original_fullpath.ends_with? '/' }
  match 'lessons/*path' =>  'lessons#show', via: 'get'

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

end
