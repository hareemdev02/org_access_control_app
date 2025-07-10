Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  
  # Custom sign out route for easier access
  devise_scope :user do
    get 'sign_out', to: 'users/sessions#destroy'
  end
  
  # Root route
  root 'dashboard#index'
  
  # Dashboard
  get 'dashboard', to: 'dashboard#index'
  
  # Organizations
  resources :organizations do
    member do
      get :analytics
      get :members
      get :participation_rules
    end
    
    resources :participation_rules, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      collection do
        patch :bulk_update
        post :reset_to_defaults
      end
    end
  end
  
  # Users - use constraints to avoid conflicts with Devise routes
  resources :users, constraints: { id: /\d+/ } do
    member do
      get :roles
      post :assign_role
      delete :remove_role
    end
  end
  
  # User profile
  get 'profile', to: 'users#profile'
  patch 'profile', to: 'users#update_profile'
  
  # Parental consents
  resources :parental_consents do
    member do
      patch :approve
      patch :revoke
      patch :renew
    end
  end
  
  # API routes for AJAX requests
  namespace :api do
    namespace :v1 do
      resources :organizations, only: [:index, :show] do
        member do
          get :analytics
          get :members
        end
      end
      
      resources :users, only: [:index, :show] do
        member do
          get :roles
        end
      end
      
      resources :participation_rules, only: [:index, :show]
      resources :parental_consents, only: [:index, :show, :create, :update]
    end
  end
  
  # Admin routes (if needed)
  namespace :admin do
    resources :organizations
    resources :users
    resources :participation_rules
    resources :parental_consents
  end
end
