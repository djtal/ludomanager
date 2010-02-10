ActionController::Routing::Routes.draw do |map|  map.resource :home

  map.resources :editors,
                :collection => {:search => :get}

  # The priority is based upon order of creation: first created -> highest priority.
  
  map.resources :parties, 
                :collection => {:all => :get, :add_party_form => :get, :group => :get, 
                                :breakdown => :get, :most_played => :get},
                :has_many => :players
  
  map.show_parties "parties/show/:date", :controller => "parties", :action => "show"
  map.parties_resume "/parties/*date", :controller => "parties", :action => "index"
  map.resources :accounts, :authors, :editions
  map.resources :players, :collection => {:new_partial_form => :get}
  map.resources :authorships, :collection => {:new_partial_form => :get}
  map.resources :members, 
                :collection => {:importer => :get, :import => :post}
  
  map.resources :account_games,
                :collection => {:all => :get, :search => :post, :import => :post, :importer => :get, 
                                :missing  => :get, :group => :get}
                
  map.resources :tags, :collection => {:lookup => :get} 
  
  map.resources :games,
                :has_many => [:authorships, :editions, :tags] ,
                :collection => {:search => :get}, 
                :member => {:replace => :get, :merge => :post} 

  map.signup '/signup', :controller => 'accounts', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.resource :session
  map.resource :dashboard
  
  map.root  :controller => "games"

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
