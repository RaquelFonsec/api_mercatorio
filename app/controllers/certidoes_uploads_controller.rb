class CertidoesUploadsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:upload_certidao_manual]

  # POST /credores/:id/upload_certidao_manual
  def upload_certidao_manual
    credor = Credor.find_by(id: params[:id])

    if credor.nil?
      render json: { error: 'Credor não encontrado' }, status: :not_found
      return
    end

    tipo_param = params[:tipo].to_sym if params[:tipo].present?

    unless Certidao.tipos.include?(tipo_param)
      render json: { error: 'Tipo inválido' }, status: :unprocessable_entity
      return
    end

    certidao = credor.certidoes.new(
      tipo: tipo_param,
      origem: :manual,
      status: params[:status] || 'pendente',
      recebida_em: Time.current
    )

    if params[:arquivo].present?
      certidao.arquivo.attach(params[:arquivo])
    elsif params[:conteudo_base64].present?
      begin
        decoded_data = Base64.decode64(params[:conteudo_base64])
        
        # Validação simples: verifica se é PDF pelo header %PDF
        unless decoded_data[0..3] == "%PDF"
          render json: { error: "Conteúdo Base64 não é um PDF válido" }, status: :unprocessable_entity
          return
        end

        temp_file = StringIO.new(decoded_data)
        temp_file.class.class_eval { attr_accessor :original_filename, :content_type }
        temp_file.original_filename = "arquivo_#{Time.now.to_i}.pdf"
        temp_file.content_type = "application/pdf"
        certidao.arquivo.attach(io: temp_file, filename: temp_file.original_filename, content_type: temp_file.content_type)
      rescue StandardError => e
        render json: { error: "Erro ao processar o conteúdo Base64: #{e.message}" }, status: :unprocessable_entity
        return
      end
    else
      render json: { error: "É necessário fornecer um arquivo ou conteúdo base64" }, status: :unprocessable_entity
      return
    end

    if certidao.save
      render json: {
        id: certidao.id,
        tipo: certidao.tipo,
        origem: certidao.origem,
        status: certidao.status,
        recebida_em: certidao.recebida_em,
        arquivo_url: certidao.arquivo.attached? ? 
          Rails.application.routes.url_helpers.rails_blob_url(certidao.arquivo, host: request.base_url) : nil
      }, status: :created
    else
      render json: { error: certidao.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end
end
