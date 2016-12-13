Rails.application.routes.draw do
  resources :exercise_classes, only: :index
end
