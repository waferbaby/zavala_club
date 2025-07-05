Rails.application.routes.draw do
  resources :poems, only: [ :create, :show ], path: ""
  root "poems#create"

  match "*any", to: "application#handle_error", via: :all
end
