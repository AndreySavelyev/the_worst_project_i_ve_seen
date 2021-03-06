Rails.application.routes.draw do
  namespace :tags do
  get 'tag/tag_service'
  end

  get 'tabs/get_tabs'

  namespace :shops do
  get 'offer/new_offer'
  end

  namespace :shops do
  get 'shop/new_shop'
  end

  namespace :legal do
  get 'policy/index'
  end

  get 'password_recovery/request'
  get 'mood/set_mood'
  get 'avatar/upload'
  get 'push_notifications/save_token'

  get 'chat/tissue/get' => 'chat#get_tissues', format: 'json'
  post 'chat/tissue/send' => 'chat#send_tissue', format: 'json'

  post '/signin', to: 'profiles#signin', format: 'json'
  post '/signup', to: 'profiles#signup', format: 'json'
  get '/signoff', to: 'profiles#signOff', format: 'json'
  get '/session', to: 'profiles#check_session', format: 'json'
  #post '/confirm', to: 'profiles#confirm', format: 'json'
  get '/confirm', to: 'profiles#confirm'
  post '/brief', to: 'profiles#brief', format: 'json'
  post '/catalog', to: 'profiles#catalog', format: 'json'
  post '/social/feed', to: 'feeds#feed', format: 'json'
  post '/social/like', to: 'profiles#like', format: 'json'

  post '/social/feed/viewed', to: 'profiles#social_feed_viewed', format: 'json'
  post '/social/friends/invite', to: 'profiles#social_friends_invite', format: 'json'
  post '/social/friends/request', to: 'profiles#social_friends_request', format: 'json'
  post '/social/friends/accept', to: 'profiles#social_friends_accept', format: 'json'
  post '/social/friends/decline', to: 'profiles#social_friends_decline', format: 'json'
  get '/social/friends/list', to: 'profiles#social_friends_list', format: 'json'
  get '/social/friends/count', to: 'profiles#social_friends_count', format: 'json'
  post '/social/friends/search', to: 'profiles#social_friends_search', format: 'json'
  post '/callback' => 'callback#callback', defaults: { format: 'text' }

  get '/social/money/rates', to: 'profiles#get_currency_rates_json', format: 'json'
  post '/social/money/rates', to: 'profiles#add_currency_rate', format: 'json'

  post '/social/money/send', to: 'profiles#social_money_send', format: 'json'
  post '/social/money/charge', to: 'profiles#social_money_charge', format: 'json'
  post '/social/money/receive', to: 'profiles#receive_pay', format: 'json'
  post '/social/money/pay', to: 'profiles#accept_charge', format: 'json'
  post '/social/money/pay/decline', to: 'wallet#decline_pay_request', format: 'json'

  get '/social/money/get', to: 'profiles#social_money_get', format: 'json'
  get '/profile/new', to: 'profiles#get_new_requests', format: 'json'
  get '/profile/get', to: 'profiles#get_profile', format: 'json'
  post '/profile/save', to: 'profiles#save_profile', format: 'json'
  post '/profile/stats', to: 'profiles#stats_profile', format: 'json'
  get '/tabs', to: 'tabs#get_tabs', format: 'json'
    
  post '/cashin' => 'wallet#cashin', format: 'json'
  post '/cashin/complete' => 'callback#complete_cashin', format: 'json'

  post '/cashout/new' => 'wallet#cashout', format: 'json'
  post '/cashout/complete' => 'wallet#complete_cashout', format: 'json'
  post '/cashout/list' => 'wallet#list', format: 'json'

  post '/profile/token' => 'push_notifications#token', format: 'json'
  post '/profile/upload' => 'avatar#upload', format: 'json'
  post '/social/mood/set' =>'mood#set_mood', format: 'json'

  post 'profile/recover' => 'password_recovery#recover', format: 'json'
  post 'profile/recover/token' => 'password_recovery#token', format: 'json'
  post 'profile/recover/password' => 'password_recovery#password', format: 'json'

  get 'legal/terms' => 'legal/terms#index'
  get 'legal/policy' => 'legal/policy#index'
  get 'legal/tariffs' => 'legal/tariffs#index'

  post 'shops/new' => 'shops/shop#new_shop', format: 'json'
  post 'shops/upload' => 'avatar#upload_shop', format: 'json'
  post 'shops/offers/new' => 'shops/offer#new_offer', format: 'json'
  post 'shops/offers/change' => 'shops/offer#change', format: 'json'
  post 'shops/offers/upload' => 'avatar#upload_offer', format: 'json'
  get 'shops/offers/list' => 'shops/offer#list', format: 'json'

  post 'services/new' => 'services/service#new_service', format: 'json'
  post 'services/upload' => 'avatar#upload_service', format: 'json'
  post 'services/change' => 'services/service#change', format: 'json'
  get 'services/list' => 'services/service#list', format: 'json'
  post 'services/pay' => 'services/service#pay', format: 'json'

  post 'tags/services' => 'tags/tag#get_services', format: 'json'
  post 'tags/services/tag' => 'tags/tag#tag_services', format: 'json'

  post '/merchant/order/pay', to: 'profiles#merchant_order_pay', format: 'json'
  post '/merchant/lead/register', to: 'profiles#merchant_lead_register', format: 'json'

end
