Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :projects do
    resources :favorites, only: [:create]
    resources :bookings, only: [:new, :create, :show]
  end

  resources :users, only: [] do
      resources :chatrooms, only: [:create]
  end

  resources :chatrooms, only: [:show, :index, :destroy] do
    resources :messages, only: [:create]

  end

  resources :bookings, only: [:update, :destroy]
  resources :favorites, only: [:destroy]
  get '/dashboard', to: 'dashboards#index', as: :dashboard
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/users/:id', to: 'users#show', as: :user_show
  get '/users', to: 'users#index'
  get '/users/:id/edit', to: 'users#edit', as: :edit_user
  patch '/users/:id', to: 'users#update', as: :user

  get '/skills', to: 'skills#edit', as: :edit_skills
  patch '/skills', to: 'skills#update', as: :skills

  post '/project/:project_id/projectfavorites', to: 'favorites#createfavorite', as: :project_favorite
  delete '/projectfavorite/:id', to: 'favorites#destroyfavorite', as: :project_favorite_delete


  get '/users/:id/review/new', to: 'reviews#new', as: :reviews
  post '/users/:id/review', to: 'reviews#create'
  delete '/review/:id', to: 'reviews#destroy', as: :delete_review

  get '/users/:user_id/review/:review_id', to: 'reviews#edit', as: :edit_review
  patch '/review/:review_id', to: 'reviews#update', as: :update_review

  delete '/dashboardbooking/:id', to: 'bookings#destroy_from_dashboard', as: :destroy_booking_from_dashboard


end
