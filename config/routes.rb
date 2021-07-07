Rails.application.routes.draw do
  get 'main/new_file'
  post "main/upload"
  get 'main/edit', as:"edit"
  get 'main/download', as:"download"

  root "main#new_file"
end
