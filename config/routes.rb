Rails.application.routes.draw do
  root "home#index"

  # Реєстрація, вхід, вихід
  get    "register", to: "users#new"
  post   "register", to: "users#create"
  get    "login",    to: "sessions#new"
  post   "login",    to: "sessions#create"
  delete "logout",   to: "sessions#destroy"

  resource :profile, only: [:show, :update]
  get "history", to: "histories#index"

  # Зворотний зв’язок
  get  "contact", to: "feedback_messages#new"
  post "contact", to: "feedback_messages#create"

  # Каталог послуг і кошик
  resources :services, only: [:index]
  resource  :cart, only: [:show, :destroy]
  resources :cart_items, only: [:create, :destroy]

  # Лікарі, оформлення візиту, оплата, відгуки
  resources :doctors, only: [:index, :show] do
    resources :appointments, only: [:new, :create]
  end
  resources :appointments, only: [:index] do
    patch :cancel, on: :member
    resource :payment, only: [:new, :create]
    resource :review, only: [:new, :create]
  end

  # Підсистема лікаря
  namespace :doctor do
    get "schedule", to: "schedule#index"
    resources :patients, only: [:index, :show]
    resources :appointments, only: [] do
      resource :medical_record, only: [:new, :create, :edit, :update]
    end
  end

  # Підсистема адміністратора
  namespace :admin do
    root "dashboard#index"
    resources :users, only: [:index, :new, :create, :edit, :update]
    resources :doctors, only: [:index, :new, :create, :edit, :update] do
      resources :working_hours, only: [:create, :destroy]
    end
    resources :specialties, only: [:index, :create, :destroy]
    resources :services, only: [:index, :new, :create, :edit, :update]
    resources :appointments, only: [:index] do
      patch :mark_paid, on: :member
    end
    resources :reviews, only: [:index] do
      patch :toggle, on: :member
    end
    resources :feedback_messages, only: [:index] do
      patch :mark_answered, on: :member
    end
    resource :report, only: [:show]
  end
end
