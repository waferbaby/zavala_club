Rails.application.routes.draw do
  root "poems#create"
  resources :poems, only: [ :create, :show ], path: ""

  match "*any", to: "application#handle_error", via: :all
end
