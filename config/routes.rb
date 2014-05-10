Rails.application.routes.draw do
  resource :home
  resources :accounts

  resources :editors do
    collection do
      get 'search'
    end
  end

  resources :played_games

  resources :parties do

    collection do
      get :all
      get :add_party_form
      get :group
      get :breakdown
      get :most_played
    end

    resources :players
  end

  get "parties/show/:date" => "parties#show", as: "show_parties"
  get "/parties/*date" => "parties#index", as: :parties_resume

  resources :authors, :editions
  resources :authorships do
    collection do
      get :new_partial_form
    end
  end

  resources :account_games do
    collection do
      get :all
      post :search
      get :missing
      get :group
    end
  end

  resources :tags do
    collection do
      get :lookup
    end
  end

  resources :game_extensions

  resources :games do
    resources :authorships, :editions, :tags

    collection do
      get :search
    end

    member do
      get :replace
      post :merge
    end

    resources :game_extensions do
      collection do
        delete :destroy_multiple
      end
    end
  end



  get '/signup' => 'accounts#new', as: :signup
  get '/login'  => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout

  resource :session
  resource :dashboard

end
