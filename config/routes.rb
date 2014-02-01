Telemetroid::Application.routes.draw do
  
  get '/params' => 'params#show'
  post '/users/new' => 'users#create'
  post '/login' => 'sessions#login'
  post '/logout' => 'sessions#logout'
  post '/change_password' => 'users#change_password'
  post '/edit' => 'users#edit'
  get '/users/:username/show' => 'users#show'
  get '/users/find' => 'users#find'
  
  post '/devices/new' => 'devices#create'
  post '/devices/login' => 'sessions#device_login'
  post '/devices/:name/edit' => 'devices#edit'
  get '/devices/:identifier/feeds/read' => 'devices#index_feeds_where_reader'
  get '/devices/:identifier/feeds/write' => 'devices#index_feeds_where_writer'

  get '/users/:username/devices' => 'devices#index'
  get '/users/:username/feeds/admin' => 'users#index_feeds_where_admin'
  get '/users/:username/feeds/read' => 'users#index_feeds_where_reader'
  get '/users/:username/feeds/write' => 'users#index_feeds_where_writer'
  
  post '/feeds/new' => 'feeds#create'
  get 'feeds/:identifier/admins' => 'feeds#index_admins'
  post '/feeds/:identifier/admins/add' => 'feeds#add_admin'
  post '/feeds/:identifier/admins/remove' => 'feeds#remove_admin'
  get 'feeds/:identifier/users/write' => 'feeds#index_users_writers'
  post '/feeds/:identifier/users/write/add' => 'feeds#add_user_write'
  post '/feeds/:identifier/users/write/remove' => 'feeds#remove_user_write'
  get 'feeds/:identifier/users/read' => 'feeds#index_users_readers'
  post '/feeds/:identifier/users/read/add' => 'feeds#add_user_read'
  post '/feeds/:identifier/users/read/remove' => 'feeds#remove_user_read'
  get 'feeds/:identifier/devices/write' => 'feeds#index_writing_devices'
  post '/feeds/:identifier/devices/write/add' => 'feeds#add_writing_device'
  post '/feeds/:identifier/devices/write/remove' => 'feeds#remove_writing_device'
  get 'feeds/:identifier/devices/read' => 'feeds#index_reading_devices'
  post '/feeds/:identifier/devices/read/add' => 'feeds#add_reading_device'
  post '/feeds/:identifier/devices/read/remove' => 'feeds#remove_reading_device'
  get '/feeds/:identifier/keys/write' => 'feeds#show_write_key'
  get '/feeds/:identifier/keys/read' => 'feeds#show_read_key'

  post '/feeds/:identifier/add' => 'shared_infos#add_one'

  get '/who' => 'sessions#who'
  get '/users' => 'users#index'
  get '/devices' => 'devices#full_index'
  get '/feeds' => 'feeds#full_index'
  get '/infos' => 'shared_infos#full_index'
  get '/params' => 'params#show'
  post '/params' => 'params#show'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
