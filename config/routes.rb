Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/health', to: 'health#index'
  get '/rates', to: 'rates#index'
  post '/rates', to: 'rates#create'
end
