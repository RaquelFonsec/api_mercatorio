class Api::CertidoesMockController < ApplicationController
  protect_from_forgery with: :null_session

  def buscar_certidoes_api
    cpf_cnpj = params[:cpf_cnpj]
    credor = Credor.find_by(cpf_cnpj: cpf_cnpj)

    if credor.nil?
      render json: { error: "Credor não encontrado" }, status: :not_found
      return
    end

    certidoes_mock_response = {
      "cpf_cnpj" => credor.cpf_cnpj,
      "certidoes" => [
        {
          "tipo" => "federal",
          "status" => "negativa",
          "conteudo_base64" => Base64.strict_encode64("Conteúdo da certidão federal em PDF")
        },
        {
          "tipo" => "trabalhista",
          "status" => "positiva",
          "conteudo_base64" => Base64.strict_encode64("Conteúdo da certidão trabalhista em PDF")
        }
      ]
    }

    novas_certidoes = []
    certidoes_mock_response["certidoes"].each do |cert_data|
      certidao = Certidao.create!(
        credor_id: credor.id,
        tipo: cert_data["tipo"],
        origem: 'api',
        conteudo_base64: cert_data["conteudo_base64"],
        status: cert_data["status"],
        recebida_em: Time.current
      )
      novas_certidoes << certidao
    end

    render json: { 
      message: "Busca de certidões via API mockada concluída.", 
      certidoes_recebidas: novas_certidoes 
    }, status: :ok

  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
