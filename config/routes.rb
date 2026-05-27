Rails.application.routes.draw do
  root 'jobs#index'
  resources :jobs, only: [:index, :show]

  namespace :admin do
    root to: 'jobs#index' 
    
    get 'login', to: 'sessions#new', as: :login
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy', as: :logout
    
    resources :jobs, only: [:index, :edit, :update, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
