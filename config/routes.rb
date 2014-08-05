Rails.application.routes.draw do
  resources :profiles
  post '/signin', to: 'profiles#signin', format: 'json'
  post '/signup', to: 'profiles#signup', format: 'json'
  #post '/confirm', to: 'profiles#confirm', format: 'json'
  get '/confirm', to: 'profiles#confirm', format: 'json'
  post '/brief', to: 'profiles#brief', format: 'json'
  post '/catalog', to: 'profiles#catalog', format: 'json'
  post '/social/feed', to: 'profiles#feed', format: 'json'
  post '/social/like', to: 'profiles#like', format: 'json'
  post '/social/money/send', to: 'profiles#social_money_send', format: 'json'
  post '/social/money/charge', to: 'profiles#social_money_charge', format: 'json'
  post '/social/money/receive', to: 'profiles#recieve_pay', format: 'json'
  get '/social/money/get', to: 'profiles#social_money_get', format: 'json'
  get '/profile/new', to: 'profiles#get_new_requests', format: 'json'
  get '/profile/get', to: 'profiles#get_profile', format: 'json'
  post '/profile/save', to: 'profiles#save_profile', format: 'json'
  get '/tabs', to: 'profiles#tabs', format: 'json'
end
