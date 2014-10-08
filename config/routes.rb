Rails.application.routes.draw do
  resources :profiles
  post '/signin', to: 'profiles#signin', format: 'json'
  post '/signup', to: 'profiles#signup', format: 'json'
  get '/signoff', to: 'profiles#signOff', format: 'json'
  get '/session', to: 'profiles#check_session', format: 'json'
  #post '/confirm', to: 'profiles#confirm', format: 'json'
  get '/confirm', to: 'profiles#confirm', format: 'json'
  post '/brief', to: 'profiles#brief', format: 'json'
  post '/catalog', to: 'profiles#catalog', format: 'json'
  post '/social/feed', to: 'profiles#feed', format: 'json'
  post '/social/like', to: 'profiles#like', format: 'json'


  post '/social/feed/viewed', to: 'profiles#social_feed_viewed', format: 'json'
  post '/social/friends/invite', to: 'profiles#social_friends_invite', format: 'json'
  post '/social/friends/request', to: 'profiles#social_friends_request', format: 'json'
  post '/social/friends/accept', to: 'profiles#social_friends_accept', format: 'json'
  post '/social/friends/decline', to: 'profiles#social_friends_decline', format: 'json'
  get '/social/friends/list', to: 'profiles#social_friends_list', format: 'json'
  get '/social/friends/count', to: 'profiles#social_friends_count', format: 'json'
  post '/social/friends/search', to: 'profiles#social_friends_search', format: 'json'
  post '/processing/callback', to: 'profiles#processing_callback', format: 'xml'
  #post '/social/friends/cancel', to: 'profiles#friendship_request_cancel', format: 'json'
  #post '/social/', to: 'profiles#', format: 'json'
  #post '/social/', to: 'profiles#', format: 'json'


  get '/social/money/rates', to: 'profiles#get_currency_rates_json', format: 'json'
  post '/social/money/rates', to: 'profiles#add_currency_rate', format: 'json'

  post '/social/money/send', to: 'profiles#social_money_send', format: 'json'
  post '/social/money/charge', to: 'profiles#social_money_charge', format: 'json'
  post '/social/money/receive', to: 'profiles#recieve_pay', format: 'json'
  post '/social/money/pay', to: 'profiles#accept_charge', format: 'json'
  get '/social/money/get', to: 'profiles#social_money_get', format: 'json'
  get '/profile/new', to: 'profiles#get_new_requests', format: 'json'
  get '/profile/get', to: 'profiles#get_profile', format: 'json'
  post '/profile/save', to: 'profiles#save_profile', format: 'json'
  post '/profile/stats', to: 'profiles#stats_profile', format: 'json'
  get '/tabs', to: 'profiles#tabs', format: 'json'
end
