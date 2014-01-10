Telemetroid::Application.routes.draw do
  
  post '/params' => 'params#show'
  get '/params' => 'params#show'
  post '/users/new' => 'users#create'
  post '/login' => 'sessions#login'
  post '/logout' => 'sessions#logout'
  post '/change_password' => 'users#change_password'
  post '/edit' => 'users#edit'
  get '/users/:username/show' => 'users#show'
  get '/users/find' => 'users#find'
  
  post '/devices/new' => 'devices#create'
  post 'devices/login' => 'sessions#device_login'
  post 'devices/:name/edit' => 'devices#edit'
  
  get '/who' => 'sessions#who'
  get '/users' => 'users#index'
  get '/devices' => 'devices#full_index'
  get '/users/:username/devices' => 'devices#index'
  
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
