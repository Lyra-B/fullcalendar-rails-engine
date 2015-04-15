FullcalendarEngine::Engine.routes.draw do
  resources :sessions do
    collection do
      get :get_sessions
    end
    member do
      post :move
      post :resize
    end
  end
  root :to => 'sessions#index'
end