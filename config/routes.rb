Hive::Scheduler::Application.routes.draw do

  get "artifacts/create"

  root 'batches#index'

  resources :batches, only: %w{ index show new create } do
    get :download_build
    get :chart_data
    get 'filter/:state', on: :collection, action: :filter, as: :filter
    get ':state', action: :filter_jobs, as: :filter
  end

  resources :jobs, only: %w{ show } do
    put :retry
    put :cancel
  end

  resources :projects

  namespace :api, defaults: { format: :json } do

    patch "/queues/:queue_names/jobs/reserve" => "jobs#reserve", defaults: { format: :json }, constraints: { queue_names: /[^\/]*/ }
    post "/jobs/:job_id/artifacts" => "artifacts#create", defaults: { format: :json }

    resources :batches, only: %w{ create show index } do
      get :download_build
    end
    resources :jobs do
      patch :prepare
      patch :start
      patch :end
      patch :update_results
      patch :complete
      patch :error
      put :report_artifacts
    end
    resources :projects do
      get :show
    end
  end

  namespace :admin do
    resources :execution_types, except: %w{ destroy }
  end

  get '/queues' => 'queues#dashboard'

  get '/status' => 'api/status#show'
  
  # Omniauth callbacks
  post '/auth/:provider/callback' => 'application#auth_callback'
  get '/auth/:provider/callback' => 'application#auth_callback'
  
end
