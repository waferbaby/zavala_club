Rails.application.routes.draw do
  root "poems#create"
  get "/:digest", to: "poems#show"

  match "*any", to: "application#handle_error", via: :all
end
