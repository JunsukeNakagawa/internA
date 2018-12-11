Rails.application.routes.draw do
  root   "works#new"
  get 'works/new', to: "works#new"
  
  post  "users/:id/attend", to: "users#attend"
  post  "users/:id/leave", to: "users#leave"
  get  "users/:id/timeedit", to: "users#timeedit" , as: 'basictime_edit'
  post  "users/:id/timeedit", to: "users#timeedit"
  get  "users/:id/attendancetime_edit", to: "users#attendancetime_edit", as: 'attendancetime_edit'
  post  "users/:id/attendancetime_edit", to: "users#attendancetime_edit"
  post  "users/:id/attendancetime_update", to: "users#attendancetime_update"
  patch  "users/:id/attendancetime_update", to: "users#attendancetime_update"
  post  "users/:id/update", to: "users#update"
  patch  "users/:id/update", to: "users#update"
  post  "users/:id/timeupdate", to: "users#timeupdate"
  get  "/employees_display", to: "users#employees_display" , as: 'employees_display'
  
  get    '/signup',  to: 'users#new'
  post "signup", to: "users#create"
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  
  patch '/works/:id/apply_overwork' , to: 'works#apply_overwork'
  patch '/works/:id/apply_attendance' , to: 'works#apply_attendance'
  
  get 'password_resets/new'
  get 'password_resets/edit'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :users, only: :index do
    collection { post :import }
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :works
end