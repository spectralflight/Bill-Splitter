# Primary Author: Jonathan Allen (jallen01)

BillSplitter::Application.routes.draw do
  devise_for :users
  resources :groups do
    resources :group_users, only: [:show, :create, :destroy], path: 'users', as: 'users'
    resources :items, except: [:index, :show] do
      resources :user_items, only: [:create, :destroy], path: 'users', as: 'users'
    end
  end

  # Aliases
  devise_scope :user do
    get "sign_up" => "devise/registrations#new"
    get "log_in" => "devise/session#new"
    get "log_out" => "devise/sessions#destroy"
  end
  
  # Route root to group index
  root :to => "groups#index"


end
