Rails.application.routes.draw do

  devise_for :users

  root 'users#demo'

  get 'users/demo', to: "users#demo"

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      get 'users/auth', to: "users#auth"
      get 'users', to: "users#index"
    end
  end

end
