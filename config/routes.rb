Rails.application.routes.draw do
  namespace :admin do
    root to: "dashboard#index"
  end
  resources :repair_pages do
    collection { patch :reorder }
    collection { get :admin }
  end
  resources :about_pages do
    collection { patch :reorder }
    collection { get :admin }
  end
  resources :terms_pages do
    collection { patch :reorder }
    collection { get :admin }
  end
  resources :privacy_pages do
    collection { patch :reorder }
    collection { get :admin }
  end
  resources :home_pages do
    collection { patch :reorder }
    collection { get :admin }
  end
  devise_for :users
  resources :order_products do
    collection { get :admin }
  end
  resources :orders do
    collection { get :admin }
  end
  resources :cart_products do
    collection { get :admin }
  end
  resources :carts do
    collection { get :admin }
  end
  resources :products do
    collection { get :admin }
  end
  resources :users do
    collection { get :admin }
  end
  resources :contacts, only: %i[new create]
  resources :events do
    collection { get :admin }
  end
  get "checkout/profile", to: "checkout#profile", as: :checkout_profile
  post "checkout", to: "checkout#create"
  get "checkout/success", to: "checkout#success", as: :checkout_success

  if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  # root "static_pages#index"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: "home_pages#index"
end
