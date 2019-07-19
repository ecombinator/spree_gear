Spree::Core::Engine.routes.draw do
  resources :contacts, only: [:create], path: "contact", path_names: { new: "" }

  get "/orders/referred", to: "orders#referred", as: :referred_orders
  resources :masquerades, only: [:index, :new] do
    member do
      get :approve
    end
  end
  resource :masquerade, only: [:destroy]
  resources :mailing_recipients, only: [:edit, :update] do
    member do
      get :opt_out
      get :opt_in
    end
  end

  get "/admin/reports/reps" => "admin/reports#reps", as: "reps_admin_reports"
  get "/admin/reports/vips" => "admin/reports#vips", as: "vips_admin_reports"
  get "/admin/reports/totals" => "admin/reports#totals", as: "totals_admin_reports"
  get "/admin/reports/line_item_detail" => "admin/reports#line_item_detail", as: "line_item_detail_admin_reports"
  get "/admin/reports/order_detail" => "admin/reports#order_detail", as: "order_detail_admin_reports"

  resource :search, only: [:new]

  devise_scope :spree_user do
    resources :wholesalers, only: [:new, :create] do
      get :welcome, on: :collection
    end
  end

  get "/r/:referral_token", to: "home_categories#index", as: :referral
  root to: "home_categories#index"
end

Rails.application.routes.draw do
  mount Ckeditor::Engine => "/ckeditor"
  get "/admin/inventory", to: "spree/admin/inventory#index", as: :inventory
  match "/admin/inventory/adjust", via: [:patch], to: "spree/admin/inventory#adjust", as: :adjust_inventory

  mount Spree::Core::Engine, at: "/"

  Spree::Core::Engine.add_routes do
    get "/purgatory", to: "static#purgatory", as: :purgatory

    namespace :admin do
      get "/orders/ship" => "orders#ship_batch", as: :ship_orders
      get "/labels/print" => "labels#print_batch", as: :print_labels
      get "/labels" => "labels#index", as: :labels
      get "/labels/:shipment_number/print" => "labels#print", as: :print_label
      get "/labels/:shipment_number" => "labels#show", as: :label

      get "/inventory", to: "inventory#index", as: :inventory_index
      match "inventory/adjust", via: [:patch], to: "inventory#adjust", as: :adjust_inventory

      get "/users", to: "users#index", as: :users
      post "/users/:id/approve", to: "users#approve", as: :approve_user

      resources :home_categories, except: [:new]
      resources :mailing_sections
      resources :mailings do
        member do
          get :prepare
        end
      end
      post "/home_categories_list" => "home_categories#update_list", as: :update_home_list
      get "/home_categories_search" => "home_categories#search_products", as: :search_category_products
      delete "/category_product" => "category_products#initiate", as: :category_products_delete
      resources :sliders do
        member do
          post :activate
          delete :deactivate
        end
      end
      resources :slides, only: [:destroy]
      get 'invoices', to: 'invoice#index', as: :invoices
      get 'email_invoices', to: 'invoice#email_invoices', as: :email_invoices
    end
    resources :home_categories, only: [:index]
  end
end
