Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    namespace :v1 do
      resources :tv_shows, only: [:index, :show]
      
      # Analytics endpoints
      get 'analytics/shows_with_episode_stats', to: 'analytics#shows_with_episode_stats'
      get 'analytics/top_rated_by_genre', to: 'analytics#top_rated_by_genre'
      get 'analytics/network_performance', to: 'analytics#network_performance'
      get 'analytics/monthly_trends', to: 'analytics#monthly_trends'
      get 'analytics/country_distribution', to: 'analytics#country_distribution'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
