
class Api::CertidoesMockController < ApplicationController

  protect_from_forgery with: :null_session

  # Define que responde a JSON
  respond_to :json

  def index
    cpf_cnpj = params[:cpf_cnpj]

    # Validação básica do parâmetro
    unless cpf_cnpj.present?
      render json: { error: 'Parâmetro cpf_cnpj é obrigatório' }, status: :bad_request
      return
    end

    # Chama o service para buscar os dados mockados
    mock_data = Api::CertidoesMockService.new(cpf_cnpj).buscar_certidoes

    # Simula atraso de resposta para parecer uma API externa real
    sleep(rand(0.5..2.0))

    # Responde com os dados JSON
    respond_with mock_data
  end
end
