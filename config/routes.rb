Rails.application.routes.draw do
  resources :rates
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/health', to: 'health#index'
end
