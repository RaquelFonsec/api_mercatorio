require 'sidekiq/web'

Rails.application.routes.draw do
  # Sidekiq Panel (com autenticação para produção)
  if Rails.env.production?
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  else
    mount Sidekiq::Web => '/sidekiq'
  end

  # Rotas de Credores
  resources :credores, only: [:create, :show] do
    member do
      post 'documentos', to: 'credores#upload_documento'
      post 'certidoes', to: 'certidoes_uploads#upload_certidao_manual'
      post 'buscar-certidoes', to: 'api/certidoes_mock#buscar_certidoes_api' # <-- Alterado aqui
    end
  end
  

  # Rotas da API Mock para Certidões
  namespace :api do
    defaults format: :json do
       get 'certidoes', to: 'certidoes_mock#buscar_certidoes_api'
    end

    # Rotas de Credores dentro da API
    resources :credores do
      resources :documentos_pessoais, only: [:create, :index, :show, :destroy]
    end
  end
end
