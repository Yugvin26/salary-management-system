# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: :all

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    resource :session, only: %i[show create destroy]
    resources :users, only: %i[create update]
    resources :employees, only: %i[index show create update] do
      member do
        post :archive
        post :unarchive
      end
    end
    resources :departments, only: %i[index show create update destroy]
    resources :locations, only: %i[index show create update destroy]
  end

  root "spa#index"
  # Catch-all only for browser navigation; unknown API/asset/file requests keep their 404.
  get "*path", to: "spa#index", format: false, constraints: lambda { |request|
    request.format.html? && !request.path.match?(%r{\A/(api|rails|assets|up)(/|\z)})
  }
end
