module Api
  class DocumentosPessoaisController < ApplicationController
    # Desabilita a proteção CSRF para APIs
    skip_before_action :verify_authenticity_token
    
    def create
      # Adiciona logs para depuração
      Rails.logger.info("Todos os parâmetros: #{params.inspect}")
      
      # Busca o credor usando o parâmetro correto para rotas aninhadas
      begin
        credor = Credor.find(params[:credor_id])
        Rails.logger.info("Credor encontrado: #{credor.id}")
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error("Credor não encontrado com ID: #{params[:credor_id]}")
        return render json: { error: "Credor não encontrado" }, status: :not_found
      end
      
      # Cria o documento pessoal
      documento = DocumentoPessoal.new(
        credor: credor,
        tipo: params.dig(:documento_pessoal, :tipo) || params[:tipo] || 'identidade',
        enviado_em: Time.current
      )
      
      # Anexa o arquivo se estiver presente
      arquivo = params.dig(:documento_pessoal, :arquivo) || params[:arquivo]
      if arquivo.present?
        documento.arquivo.attach(arquivo)
      end
      
      # Salva o documento
      if documento.save
        render json: { 
          id: documento.id, 
          tipo: documento.tipo,
          url: documento.arquivo.attached? ? rails_blob_path(documento.arquivo, only_path: true) : nil
        }, status: :created
      else
        render json: { errors: documento.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    def index
      credor = Credor.find(params[:credor_id])
      documentos = credor.documentos_pessoais
      
      render json: documentos.map { |doc| 
        {
          id: doc.id,
          tipo: doc.tipo,
          enviado_em: doc.enviado_em,
          url: doc.arquivo.attached? ? rails_blob_path(doc.arquivo, only_path: true) : nil
        }
      }
    end
    
    def show
      credor = Credor.find(params[:credor_id])
      documento = credor.documentos_pessoais.find(params[:id])
      
      render json: {
        id: documento.id,
        tipo: documento.tipo,
        enviado_em: documento.enviado_em,
        url: documento.arquivo.attached? ? rails_blob_path(documento.arquivo, only_path: true) : nil
      }
    end
    
    def destroy
      credor = Credor.find(params[:credor_id])
      documento = credor.documentos_pessoais.find(params[:id])
      
      if documento.destroy
        render json: { message: "Documento excluído com sucesso" }, status: :ok
      else
        render json: { error: "Não foi possível excluir o documento" }, status: :unprocessable_entity
      end
    end
  end
end
