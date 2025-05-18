class RevalidarCertidoesJob < ApplicationJob
  queue_as :default
  
  # Método principal que será chamado quando o job for executado
  def perform(*args)
    # Busca todas as certidões que precisam ser revalidadas (mais de 24h)
    certidoes = Certidao.para_revalidar

    certidoes.each do |certidao|
      # Chama o serviço de revalidação para cada certidão
      revalidar_certidao(certidao)
    end
  end
  
  private
  
  def revalidar_certidao(certidao)
    Rails.logger.info("Iniciando revalidação da certidão ##{certidao.id} do credor #{certidao.credor.cpf_cnpj}")
  
    begin
      resultado = chamar_api_externa(certidao)
  
      if resultado[:sucesso]
        certidao.atualizar_apos_revalidacao(
          resultado[:status],
          resultado[:conteudo_base64]
        )
        Rails.logger.info("Certidão ##{certidao.id} revalidada com sucesso. Novo status: #{resultado[:status]} para o credor #{certidao.credor.cpf_cnpj}")
      else
        # Em caso de falha, não deve anexar conteúdo
        certidao.atualizar_apos_revalidacao(:invalida)
        Rails.logger.error("Falha ao revalidar certidão ##{certidao.id}: #{resultado[:erro]}")
      end
    rescue => e
      Rails.logger.error("Erro ao revalidar certidão ##{certidao.id}: #{e.message}")
      certidao.atualizar_apos_revalidacao(:invalida)
    end
  end
  
  def chamar_api_externa(certidao)
    # Usa o serviço de mock que você já implementou
    mock_service = Api::CertidoesMockService.new(certidao.credor.cpf_cnpj)
    resultado_mock = mock_service.buscar_certidoes

    # Pega a primeira certidão disponível no mock (para fins de teste)
    certidao_encontrada = resultado_mock[:certidoes].first

    if certidao_encontrada
      {
        sucesso: true,
        status: certidao_encontrada[:status],
        conteudo_base64: certidao_encontrada[:conteudo_base64]
      }
    else
      {
        sucesso: false,
        erro: "Nenhuma certidão encontrada para o CPF/CNPJ #{certidao.credor.cpf_cnpj}"
      }
    end
  rescue => e
    # Em caso de erro na API
    {
      sucesso: false,
      erro: e.message
    }
  end
end
