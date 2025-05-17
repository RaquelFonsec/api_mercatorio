module Api
    class CertidoesMockService
      def initialize(cpf_cnpj)
        @cpf_cnpj = cpf_cnpj
      end
  
      def buscar_certidoes
        {
          cpf_cnpj: @cpf_cnpj,
          certidoes: [
            {
              tipo: "federal",
              status: ["negativa", "positiva", "pendente"].sample,
              conteudo_base64: Base64.strict_encode64("Conteúdo da certidão federal para #{@cpf_cnpj}")
            },
            {
              tipo: "estadual",
              status: ["negativa", "pendente"].sample,
              conteudo_base64: Base64.strict_encode64("Conteúdo da certidão estadual para #{@cpf_cnpj}")
            },
            {
              tipo: "trabalhista",
              status: "negativa",
              conteudo_base64: Base64.strict_encode64("Conteúdo da certidão trabalhista para #{@cpf_cnpj}")
            }
          ]
        }
      end
    end
  end
  