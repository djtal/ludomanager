ActionController::Routing::Routes.draw do |map|  map.resource :home
  map.resources :accounts
  map.resources :editors,
                :collection => {:search => :get}
                
  map.resources :played_games

  # The priority is based upon order of creation: first created -> highest priority.
  
  map.resources :parties, 
                :collection => {:all => :get, :add_party_form => :get, :group => :get, 
                                :breakdown => :get, :most_played => :get},
                :has_many => :players
  
  map.show_parties "parties/show/:date", :controller => "parties", :action => "show"
  map.parties_resume "/parties/*date", :controller => "parties", :action => "index"
  map.resources :authors, :editions
  map.resources :authorships, :collection => {:new_partial_form => :get}
  
  map.resources :account_games,
                :collection => {:all => :get, :search => :post, :missing  => :get, :group => :get}
  map.resources :tags, :collection => {:lookup => :get} 

  map.resources :game_extensions
  
  map.resources :games,
                :has_many => [:authorships, :editions, :tags] ,
                :collection => {:search => :get}, 
                :member => {:replace => :get, :merge => :post} do |game|
    
    game.resources :game_extensions,
                  :collection => {:destroy_multiple => :delete}
                  
  end
                


  map.signup '/signup', :controller => 'accounts', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.resource :session
  map.resource :dashboard
  
  map.root  :controller => "games"

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
