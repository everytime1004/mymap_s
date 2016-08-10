Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'registrations' => 'registrations#create', :as => 'register'
        post 'registrationsFB' => 'omniauth_callbacks#omniauth_success'
        post 'registrationsKK' => 'omniauth_callbacks#omniauth_success'

        post 'sign_in' => 'sessions#create'
        delete 'sign_out' => 'sessions#destroy'
      end
    end
  end
end
