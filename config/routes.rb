Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  root to: 'application#website'

  devise_for :users, defaults: { format: :json }, skip: :all
  devise_scope :user do
    # If you change these urls and helpers, you must change these files too:
    # - config/initializers/devise.rb#JWT Devise
    # - spec/support/authentication_helper.rb
    post '/users/login' => 'sessions#create', as: :user_session
    delete 'panel/users/logout' => 'sessions#destroy', as: :destroy_user_session
    post '/users/signup' => 'registrations#create', as: :user_registration
  end

  get '/panel', to: 'application#panel', as: :panel
  namespace :panel do
    resources :albums do
      resources :photos, only: %i[index create]
    end
    resources :photos, only: %i[show update destroy] do
      get '/photo_user_reviews', to: 'photo_user_reviews#index'
      put '/photo_user_reviews', to: 'photo_user_reviews#update'
    end
    delete '/delete_photos', to: 'photos#destroy_multiple', as: 'delete_photos'
  end
  get '/(*path)', to: 'application#website', as: :website


end
