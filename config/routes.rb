Rails.application.routes.draw do
  resources :profiles
  post '/signin', to: 'profiles#signin'
  post '/signup', to: 'profiles#signup'
  post '/confirm', to: 'profiles#confirm'
  post '/brief', to: 'profiles#brief'
  post '/catalog', to: 'profiles#catalog'
  post '/social/feed', to: 'profiles#feed'
  post '/catalog', to: 'profiles#catalog'
  post '/feed', to: 'profiles#feed'
  get '/tabs', to: 'profiles#tabs'
end
