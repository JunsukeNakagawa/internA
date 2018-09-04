Rails.application.routes.draw do
  root   "works#new"
  get 'works/new', to: "works#new"
  post  "works/attend", to: "works#attend"
  post  "works/leave", to: "works#leave"
  get  "works/edit", to: "works#edit"
  post  "works/edit", to: "works#edit"
  get  "works/update", to: "works#update"
  post  "works/update", to: "works#update"
  patch  "works/update", to: "works#update"
  get  "works/timeedit", to: "works#timeedit" , as: 'workingtime_edit'
  post  "works/timeedit", to: "works#timeedit"
  post  "works/timeupdate", to: "works#timeupdate"
  
  patch  "users/:id/attend", to: "users#attend"
  patch  "users/:id/leave", to: "users#leave"
  get  "users/:id/timeedit", to: "users#timeedit" , as: 'basictime_edit'
  post  "users/:id/timeedit", to: "users#timeedit"
  get  "users/:id/attendancetime_edit", to: "users#attendancetime_edit", as: 'attendancetime_edit'
  post  "users/:id/attendancetime_edit", to: "users#attendancetime_edit"
  post  "users/:id/attendancetime_update", to: "users#attendancetime_update"
  patch  "users/:id/attendancetime_update", to: "users#attendancetime_update"
  post  "users/:id/update", to: "users#update"
  patch  "users/:id/update", to: "users#update"
  post  "users/:id/timeupdate", to: "users#timeupdate"
  
  get    '/signup',  to: 'users#new'
  post "signup", to: "users#create"
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