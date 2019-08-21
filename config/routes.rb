Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :path_names => { :sign_in => 'login', :sign_out => 'logout' }

  scope '/:slug/:app/saml' do
    get '/auth' => 'saml_idp#new'
    get '/metadata' => 'saml_idp#show'
    post '/auth' => 'saml_idp#create'
    match '/logout' => 'saml_idp#logout', via: [:get, :post, :delete]
  end

  devise_scope :user do
    authenticated :user do
      resources :organisations, except: %i(destroy) do
        get 'setup_saml', action: :setup_saml
        get 'config_saml_app/:app_name', action: :config_saml_app, as: 'config_saml_app'
        post 'config_saml_app/:app_name', action: :save_config_saml_app, as: :save_config_saml_app
        post 'config_saml_app/:app_name/add_user', action: :add_user_saml_app, as: :add_user_saml_app
        delete 'config_saml_app/:app_name', action: :remove_user_saml_app, as: :remove_user_saml_app
      end
    end

    post '/users/sign_in' => 'users/auth#log_in', as: 'user_sign_in'
    delete "/users/sign_out" => "devise/sessions#destroy"
    match 'download_vpn', to: 'profile#download_vpn', via: :get, format: :html
    match 'download_vpn_for_ios_and_mac', to: 'profile#download_vpn_for_ios_and_mac', via: :get, format: :html
    match 'download_vpn/:id', to: 'profile#download_vpn_for_user', via: :get, format: :html
  end

  match 'profile', to: 'profile#show', via: :get, format: :html
  match 'profile/verify', to: 'profile#verify', via: :get, format: :text
  match 'profile/authenticate', to: 'profile#authenticate', via: :get, format: :text
  match 'profile/authenticate_cas', to: 'profile#authenticate_cas', via: :post, format: :json
  match 'profile/authenticate_pam', to: 'profile#authenticate_pam', via: :get, format: :text
  match 'profile/authenticate_ms_chap', to: 'profile#authenticate_ms_chap', via: :get, format: :text
  match 'profile/admin', to: 'profile#admin', via: :get
  match 'profile/user_admin', to: 'profile#user_admin', via: :get
  get 'profile/list' => 'profile#list', as: 'profile_list'

  get 'profile/:id' => 'users#index', as: 'user_profile'
  post 'profile/:id' => 'profile#update', as: 'user_update'
  get 'profile/:id/edit' => 'profile#user_edit', as: 'user_edit'
  post 'profile/:id/public_key' => 'profile#public_key_update', as: 'user_public_key_update'
  constraints(name: /[^\/]+/) do
    get 'profile/:name/key' => 'profile#public_key', as: 'user_public_key', format: :text
    get 'profile/:name/id' => 'profile#user_id', as: 'user_public_id', format: :text
  end

  post 'profile/:id/host' => 'host#add_host', as: 'add_host'
  delete 'profile/:user_id/host/:id' => 'host#delete_host', as: 'user_host'

  post 'profile/:id/vpn' => 'profile#add_vpn_group_association', as: 'add_vpn_group_user_association'
  delete 'profile/:user_id/vpn/:id' => 'profile#delete_vpn_group_association', as: 'delete_vpn_group_association'

  get '/regenerate_authentication' => 'profile#regen_auth', as: 'regenerate_authentication', format: :html
  #Group Function

  post 'profile/:id/group' => 'groups#add_group', as: 'add_group'
  delete 'profile/:user_id/group/:id' => 'groups#delete_group', as: 'user_group'
  get 'nss/group' => 'nss#group', as: 'nss_group', format: :json
  get 'nss/shadow' => 'nss#shadow', as: 'nss_shadow', format: :json
  get 'nss/passwd' => 'nss#passwd', as: 'nss_passwd', format: :json
  get 'nss/host' => 'nss#host', as: 'nss_host', format: :json
  post 'nss/host' => 'nss#add_host', as: 'add_nss_host', format: :json
  get 'nss/user/groups' => 'nss#groups_list', as: 'profile_groups_list', format: :json

  #Specific Group routes

  post 'groups/:id/add_user' => 'groups#add_user', as: 'add_user_to_group'
  delete 'groups/:id/user/:user_id' => 'groups#delete_user', as: 'group_user'
  post 'groups/:id/add_vpn' => 'groups#add_vpn', as: 'add_vpn_to_group'
  delete 'groups/:id/vpn/:vpn_id' => 'groups#delete_vpn', as: 'group_vpn'
  post 'groups/:id/add_machine' => 'groups#add_machine', as: 'add_machine_to_group'
  post 'groups/:id/add_admin' => 'groups#add_admin', as: 'add_admin_to_group'
  delete 'groups/:id/remove_admin/:group_admin_id' => 'groups#remove_admin', as: 'group_group_admin'
  delete 'groups/:id/host_machine/:host_machine_id' => 'groups#delete_machine', as: 'group_host_machine'
  delete 'host_machines/:id/groups/:group_id' => 'host_machines#delete_group', as: 'host_machine_group'
  post 'host_machines/:id/add_group' => 'host_machines#add_group', as: 'add_group_to_machine'
  get 'groups/search' => 'groups#search', format: :json

  # api routes
  namespace :api do
    namespace :v1 do
      post 'users' => 'users#create', as: 'add_users_api', format: :json
      patch 'users/:id/deactivate' => 'users#deactivate', format: :json, :constraints => { format: 'json' }
      get 'users/profile' => 'users#show', format: :json, :constraints => { format: 'json' }
      post 'users/profile' => 'users#update', format: :json, :constraints => { format: 'json' }
      post 'endpoints' => 'endpoints#create', format: :json, :constraints => { format: 'json' }
      post 'endpoints/:id/add_group' => 'endpoints#add_group', format: :json, constraints: { format: 'json' }

      resources :groups, only: [:create], format: :json
      resources :vpns, only: [:create], format: :json do
        member do
          post 'assign_group'
        end
      end
    end
  end

  root 'home#index'

  get '/admin' => 'admin#index'

  resources :host_machines do
    collection do
      get 'search', format: :json
    end
  end

  resources :groups
  #resources :groups do
  #  resources :members
  #  resources :group_admins
  #end
  resources :users do
    collection do
      get 'search', format: :json
    end
    member do
      get 'regenerate_token'
    end
  end

  resource :ping, only: [:show]

  resources :vpns do
    collection do
      get 'search', format: :json
    end
  end
  resources :api_resources do
    collection do
      get 'search', format: :json
    end
    member do
      get 'regenerate_access_key'
    end
  end

  get "api_resource/authenticate/:access_key/:access_token" => "api_resources#authenticate", as: "api_resource_authenticate"
  post 'vpns/:id/dns_server' => 'vpns#add_dns_server', as: 'add_dns_to_vpn'
  post 'vpns/:id/search_domain' => 'vpns#add_search_domain', as: 'add_search_domain_to_vpn'
  post 'vpns/:id/supplemental_match_domain' => 'vpns#add_supplemental_match_domain', as: 'add_supplemental_match_domain_to_vpn'
  delete 'vpns/:id/dns_server/:vpn_domain_name_server_id' => 'vpns#remove_dns_server', as: 'remove_dns_from_vpn'
  delete 'vpns/:id/search_domain/:vpn_search_domain_id' => 'vpns#remove_search_domain', as: 'remove_search_domain_from_vpn'
  delete 'vpns/:id/supplemental_match_domain/:vpn_supplemental_match_domain_id' => 'vpns#remove_supplemental_match_domain', as: 'remove_supplemental_match_domain_from_vpn'
  post 'vpns/:id/group' => 'vpns#assign_group', as: 'assign_group_to_vpn'
  get 'vpns/:id/groups/:group_id/groups' => 'vpns#user_associated_groups', format: :json
  get 'vpns/:vpn_id/groups/:group_id/users' => 'vpns#group_associated_users', format: :json
  post 'vpns/:vpn_id/groups/:group_id/users' => 'vpns#create_group_associated_users', format: :json

  # SAML routes

  get 'sso/saml/metadata' => 'saml_idp#show', format: :xml
  get '/saml/auth' => 'saml_idp#new'
  post '/saml/auth' => 'saml_idp#create'
  post '/saml/sp' => 'saml_idp#add_saml_sp'
  get '/saml/sp/:name' => 'saml_idp#get_saml_sp'
end
