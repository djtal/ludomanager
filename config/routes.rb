ActionController::Routing::Routes.draw do |map|

  map.resources :smart_lists


  # The priority is based upon order of creation: first created -> highest priority.
  
  map.parties_resume "/parties/resume/*date", :controller => "parties", :action => "resume"
  map.resources :parties, :collection => {:play => :post, :add_party_form => :get}
  
  map.resources :accounts, :authors
  map.resources :authorships, :collection => {:new_partial_form => :get}
  
  #map.resources :parties, :collection => {:resume => :get}
  map.resources :account_games,
                :collection => {:all => :get, :search => :post, :import => :post, :importer => :get, :missing  => :get}
  map.resources :tags, :collection => {:lookup => :get} 
  
  map.resources :games,
                :has_many => [:account_games, :authorships] ,
                :collection => {:search => :get} 

  map.signup '/signup', :controller => 'accounts', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.resource :session
  map.resource :dashboard
  
  map.root  :controller => "games"

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
