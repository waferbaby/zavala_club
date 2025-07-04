Rails.application.routes.draw do
  get ":id", to: "poetry#show", as: "poem"
  root "poetry#index"
  match "*any", via: [ :get, :post ], to: "poetry#error"
end
