Hive::Scheduler::Application.routes.draw do

  get "artifacts/create"

  root 'batches#index'

  resources :batches, only: %w{ index show new create } do
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
      get '/download_build/:file_name', action: :download_build
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
    resources :scripts, except: %w{ destroy }
  end

  get '/queues' => 'monitoring#dashboard'
  post '/queues/:hive_queue_id/cancel' => 'monitoring#cancel_jobs'
  get '/workers' => 'monitoring#workers'
  get '/usage' => 'monitoring#usage'
  get '/job_status' => 'monitoring#job_status'
  get '/job_status/project/:project_id' => 'monitoring#job_status_project_graph', as: 'job_status_project'
  
  # Usage stats as json
  get '/usage/batch_counts' => 'monitoring#batch_counts'
  get '/usage/project_counts' => 'monitoring#project_counts'
  get '/usage/device_hours' => 'monitoring#device_hours'
  
  post '/batches/:id/cancel' => 'batches#cancel_jobs'

  get '/status' => 'api/status#show'
  
  # Omniauth callbacks
  post '/auth/:provider/callback' => 'application#auth_callback'
  get '/auth/:provider/callback' => 'application#auth_callback'
  
end
