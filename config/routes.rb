Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :path_names => { :sign_in => 'login', :sign_out => 'logout' } do
    get 'login' =>'devise/sessions#new', :as => :new_user_session
    post 'login' => 'devise/sessions#create', :as => :user_session
    get 'signup'  => 'registrations#new', :as => :new_user_registration
    get 'signout' => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  devise_scope :user do
    delete "/users/sign_out" => "devise/sessions#destroy"
    match 'download_vpn', to: 'profile#download_vpn', via: :get, format: :html
  end

  match 'profile', to: 'profile#show', via: :get, format: :html
  match 'profile/verify', to: 'profile#verify', via: :get, format: :text
  match 'profile/authenticate', to: 'profile#authenticate', via: :get, format: :text
  match 'profile/authenticate_pam', to: 'profile#authenticate_pam', via: :get, format: :text
  match 'profile/admin', to: 'profile#admin', via: :get
  get 'profile/list' => 'profile#list', as: 'profile_list'
#  match 'profile/admin/user/:id', to: 'profile#admin_user', via: :get, as: 'profile_admin_user'

  get 'profile/:id' => 'profile#user', as: 'user'
  post 'profile/:id' => 'profile#update', as: 'user_update'
  get 'profile/:id/edit' => 'profile#user_edit', as: 'user_edit'
  post 'profile/:id/public_key' => 'profile#public_key_update', as: 'user_public_key_update'
  get 'profile/:name/key' => 'profile#public_key', as: 'user_public_key', format: :text
  get 'profile/:name/id' => 'profile#user_id', as: 'user_public_id', format: :text
  post 'profile/:id/host' => 'host#add_host', as: 'add_host'
  delete 'profile/:user_id/host/:id' => 'host#delete_host', as: 'user_host'
  

  #Group Functions
  post 'profile/:id/group' => 'group#add_group', as: 'add_group'
  delete 'profile/:user_id/group/:id' => 'group#delete_group', as: 'user_group'
  get 'group' => 'group#list', as: 'group_list'
  get 'group/:id' => 'group#show', as: 'group'
  # math nss-http
  get 'nss/group' => 'nss#group', as: 'nss_group', format: :json
  get 'nss/shadow' => 'nss#shadow', as: 'nss_shadow', format: :json
  get 'nss/passwd' => 'nss#passwd', as: 'nss_passwd', format: :json

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
