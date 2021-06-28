Rails.application.routes.draw do
  resource :users, only: [:create]
  get '/users/:id', to: 'users#show'
  get '/plans', to: 'users#plans'
  post '/payment/check', to: 'users#check_payment'
end
