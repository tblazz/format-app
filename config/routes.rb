Rails.application.routes.draw do
  get 'main/upload', as:"upload"
  post "main/upload"
  get 'main/edit', as:"edit"
  get 'main/download', as:"download"

  root "main#upload"
end
