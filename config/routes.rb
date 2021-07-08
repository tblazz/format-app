Rails.application.routes.draw do
  resources :dbfiles do
    member do
      get 'treatment'
      post 'process_file'
      get 'download'
    end
  end

  # get 'main/new_file'
  # post "main/upload"
  # get 'main/edit', as:"edit"
  # get 'main/download', as:"download"

  root "dbfiles#new"

end
