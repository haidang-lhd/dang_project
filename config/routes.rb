Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => '/cable'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # Devise routes for API authentication - moved to api/v1 namespace
  devise_for :users, path: 'api/v1/users', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  }, controllers: {
    sessions: 'api/v1/users/sessions',
    registrations: 'api/v1/users/registrations',
    passwords: 'api/v1/users/passwords',
    confirmations: 'api/v1/users/confirmations'
  }

  namespace :api do
    namespace :v1 do
      resources :assets, only: %i[index]
      resources :categories, only: %i[index]
      resources :investment_transactions, only: %i[index show create update destroy]

      # New endpoints for price sync and profit analytics
      post 'asset_prices/sync', to: 'asset_prices#sync'
      get 'profit_analytics/calculate_profit', to: 'profit_analytics#calculate_profit'
      get 'profit_analytics/calculate_profit_detail', to: 'profit_analytics#calculate_profit_detail'
    end
  end
end
