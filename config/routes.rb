Rails.application.routes.draw do
  resources :profiles
  post '/signin', to: 'profiles#signin'
  post '/signup', to: 'profiles#signup'
  post '/confirm', to: 'profiles#confirm'
  post '/brief', to: 'profiles#brief'
  post '/catalog', to: 'profiles#catalog'
  post '/social/feed', to: 'profiles#feed'
  post '/social/like', to: 'profiles#like'
  post '/social/money/send', to: 'profiles#social_money_send'
  post '/social/money/charge', to: 'profiles#social_money_charge'
  post '/social/money/recieve', to: 'profiles#recieve_pay'
  get '/social/money/get', to: 'profiles#social_money_get'
  get '/tabs', to: 'profiles#tabs'
end
