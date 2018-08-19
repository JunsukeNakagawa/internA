Rails.application.routes.draw do
  root   'works#new'
  get 'works/new', to: "works#new"
  post  "works/new", to: "works#new"
  post  "works/attend", to: "works#attend"
  post  "works/leave", to: "works#leave"
  get  "works/edit", to: "works#edit"
  post  "works/edit", to: "works#edit"
  get  "works/update", to: "works#update"
  post  "works/update", to: "works#update"
  patch  "works/update", to: "works#update"
  
  get    '/signup',  to: 'users#new'
  post "signup", to: "users#create"
  post  "users/attend", to: "users#attend"
  post  "users/leave", to: "users#leave"
  
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  
  get 'password_resets/new'
  get 'password_resets/edit'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
  resources :works
end