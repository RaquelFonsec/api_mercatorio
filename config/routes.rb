require 'sidekiq/web'

Rails.application.routes.draw do
  get 'uploads/upload_manual'
  get 'documentos_certidoes/upload_documento'
  get 'documentos_certidoes/buscar_certidoes_api'
  get 'documentos_certidoes/upload_certidao_manual'
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
      post 'certidoes', to: 'credores#upload_certidao_manual'
      post 'buscar-certidoes', to: 'credores#buscar_certidoes_api'
    end
  end

  # Rotas da API Mock para Certidões
  namespace :api do
    defaults format: :json do
      get 'certidoes', to: 'certidoes_mock#index'
    end

    # Rotas de Credores dentro da API
    resources :credores do
      # Sub-rotas de Documentos Pessoais dentro da API
      resources :documentos_pessoais, only: [:create, :index, :show, :destroy]
    end
  end
end
