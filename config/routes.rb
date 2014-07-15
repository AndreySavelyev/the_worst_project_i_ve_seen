Rails.application.routes.draw do
  resources :profiles
  post '/signin', to: 'profiles#signin'
  post '/signup', to: 'profiles#signup'

end
