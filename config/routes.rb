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
  patch  "users/:id/attendancetime_update", to: "users#attendancetime_update", as: 'attendancetime_update'
  post '/users/applied', to: 'users#update_applied_attendance', as: 'update_applied_attendance'
  post  "users/:id/update", to: "users#update"
  patch  "users/:id/update", to: "users#update"
  post  "users/:id/timeupdate", to: "users#timeupdate"
  get  "users/:id/csv_output", to: "users#csv_output" , as: 'csv_output'
  get  "/employees_display", to: "users#employees_display" , as: 'employees_display'
  
    # ユーザ関係
  resources :users do
    collection { post :import }
  end
  
  get '/show_confirm', to: 'users#show_confirm', as: 'show_confirm'
  
  get    '/signup',  to: 'users#new'
  post "signup", to: "users#create"
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  
  patch '/works/:id/apply_overwork' , to: 'works#apply_overwork'
  patch '/works/:id/apply_attendance' , to: 'works#apply_attendance'
  
  # 1ヵ月分勤怠の確認申請関係
  post '/users/onemonth', to: 'users#onemonth_application', as: 'onemonth_application'
  post '/works/update_onemonth', to: 'works#update_onemonth_applied_attendance', as: 'update_onemonth_applied_attendance'
  
  # 残業申請関係
  get '/work', to: 'work#edit', as: 'edit_attendance'
  get '/works/overtime', to: 'works#edit_overtime', as: 'edit_overtime_attendance'
  post '/works/overtime', to: 'works#overtime_application', as: 'overtime_application'
  post '/works/one_overtime', to: 'works#one_overtime_application', as: 'one_overtime_application'
  
  get 'password_resets/new'
  get 'password_resets/edit'
  resources :users, only: :index do
    collection { post :import }
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :works
  resources :base_points
  post '/base_point/create',  to: 'base_points#create', as: 'base_point_create'
  
  # CSV出力用
  get '/user_attendance_output', to: 'users#user_attendance_output', as: 'user_attendance_output' 
end