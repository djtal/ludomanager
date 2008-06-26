ActionController::Routing::Routes.draw do |map|
  map.resources :players


  map.resources :smart_lists


  # The priority is based upon order of creation: first created -> highest priority.
  
  map.parties_resume "/parties/resume/*date", :controller => "parties", :action => "resume"
  map.resources :parties, 
                :collection => {:play => :post, :add_party_form => :get},
                :has_many => :players
  map.resource :session
  map.resources :accounts, :authors, :authorships, :members
  
  #map.resources :parties, :collection => {:resume => :get}
  map.resources :account_games,
                :collection => {:all => :get, :search => :post, :import => :post, :importer => :get, :missing  => :get}
  map.resources :tags, :collection => {:lookup => :get} do |t|
    t.resources :games
  end
  map.resources :games, :collection => {:search => :get} 

  map.signup '/signup', :controller => 'accounts', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.dashboard '/dashboard', :controller => 'dashboard', :action => 'index'
  
  map.root  :controller => "games"

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
