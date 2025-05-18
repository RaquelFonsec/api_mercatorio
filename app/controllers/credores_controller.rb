class CredoresController < ApplicationController
  protect_from_forgery with: :null_session, only: [:upload_documento]
  before_action :set_credor, only: [:show, :upload_documento]
  skip_before_action :verify_authenticity_token, only: [:upload_documento]



  
  # POST /credores
  def create
    credor_params = params.require(:credor).permit(
      :nome, 
      :cpf_cnpj, 
      :email, 
      :telefone, 
      precatorio: [:numero_precatorio, :valor_nominal, :foro, :data_publicacao]
    )

    @credor = Credor.find_by(cpf_cnpj: credor_params[:cpf_cnpj])

    if @credor
      @credor.update(credor_params.except(:precatorio))
    else
      @credor = Credor.new(credor_params.except(:precatorio))
    end

    if credor_params[:precatorio].present?
      @precatorio = Precatorio.new(credor_params[:precatorio])
      @credor.precatorio = @precatorio
    end

    if @credor.save
      render json: @credor, status: :created
    else
      render json: { error: @credor.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # POST /credores/:id/documentos
  def upload_documento
    if params[:arquivo].present?
      documento = @credor.documentos_pessoais.new(
        tipo: params[:tipo],
        enviado_em: Time.current
      )
      documento.arquivo.attach(params[:arquivo])
  
      if documento.save
        render json: {
          id: documento.id,
          credor_id: documento.credor_id,
          tipo: documento.tipo,
          arquivo_url: Rails.application.routes.url_helpers.rails_blob_path(documento.arquivo, only_path: true),
          enviado_em: documento.enviado_em,
          created_at: documento.created_at,
          updated_at: documento.updated_at
        }, status: :created
      else
        render json: { error: documento.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Arquivo não encontrado." }, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error "Erro no upload: #{e.message}\n#{e.backtrace.join("\n")}"
    render json: { error: e.message }, status: :unprocessable_entity
  end
  


  # GET /credores/:id
  def show
    documentos = @credor.documentos_pessoais.map do |doc|
      {
        id: doc.id,
        tipo: doc.tipo,
        enviado_em: doc.enviado_em,
        arquivo_url: doc.arquivo.attached? ? 
          Rails.application.routes.url_helpers.rails_blob_url(doc.arquivo, host: request.base_url) : 
          doc.arquivo_url
      }
    end

    certidoes = @credor.certidoes.map do |cert|
      {
        id: cert.id,
        tipo: cert.tipo,
        origem: cert.origem,
        status: cert.status,
        recebida_em: cert.recebida_em,
        arquivo_url: cert.arquivo.attached? ? 
          Rails.application.routes.url_helpers.rails_blob_url(cert.arquivo, disposition: "inline", host: request.base_url) : 
          cert.arquivo_url
      }
    end

    resposta = {
      credor: {
        id: @credor.id,
        nome: @credor.nome,
        cpf_cnpj: @credor.cpf_cnpj,
        email: @credor.email,
        telefone: @credor.telefone,
        created_at: @credor.created_at,
        updated_at: @credor.updated_at
      },
      precatorio: @credor.precatorio.present? ? {
        id: @credor.precatorio.id,
        numero_precatorio: @credor.precatorio.numero_precatorio,
        valor_nominal: @credor.precatorio.valor_nominal,
        foro: @credor.precatorio.foro,
        data_publicacao: @credor.precatorio.data_publicacao
      } : nil,
      documentos: documentos,
      certidoes: certidoes
    }

    render json: resposta
  end

  private

  # Strong parameters para criar credor
  def credor_params
    params.require(:credor).permit(
      :nome, 
      :cpf_cnpj, 
      :email, 
      :telefone, 
      precatorio: [:numero_precatorio, :valor_nominal, :foro, :data_publicacao]
    )
  end

  # Strong parameters para upload de documentos
  def documento_params
    params.permit(:tipo, :arquivo)
  end

  # Strong parameters para upload de certidões
  def certidao_manual_params
    params.permit(:tipo, :arquivo, :conteudo_base64, :status)
  end

  # Set credor por ID
  def set_credor
    @credor = Credor.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Credor não encontrado" }, status: :not_found
  end
end
