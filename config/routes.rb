Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'registrations' => 'registrations#create', :as => 'register'
        post 'registrationsFB' => 'omniauth_callbacks#omniauth_success'
        post 'registrationsKK' => 'omniauth_callbacks#omniauth_success'

        post 'sessions' => 'sessions#create'
        delete 'sessions' => 'sessions#destroy'
      end

      get 'notices' => 'notices#index'

      post 'tours' => 'tours#create'
      get 'tours/:id' => 'tours#show'

      get 'trips/:id' => 'trips#show'
    end
  end
end
