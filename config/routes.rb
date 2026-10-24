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
      resources :salaries, only: %i[index create]
    end
    get "salaries/:salary_id/versions", to: "salary_versions#index"
    resources :departments, only: %i[index show create update destroy]
    resources :locations, only: %i[index show create update destroy]
    resource :profile, only: [ :show ]
    resource :company_setting, only: %i[show update]
    namespace :site_admin do
      resource :session, only: [ :create ], controller: "sessions"
      resources :companies, only: %i[index create update destroy]
    end
    get "reports/dashboard", to: "reports#dashboard"
    get "reports/departments", to: "reports#departments"
    get "reports/job_titles", to: "reports#job_titles"
    get "reports/countries", to: "reports#countries"
    get "reports/export", to: "reports#export"
    get "reports/export_grouped", to: "reports#export_grouped"
  end

  root "spa#index"
  # Catch-all only for browser navigation; unknown API/asset/file requests keep their 404.
  get "*path", to: "spa#index", format: false, constraints: lambda { |request|
    request.format.html? && !request.path.match?(%r{\A/(api|rails|assets|up)(/|\z)})
  }
end
