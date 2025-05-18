require 'rails_helper'

RSpec.describe Api::CertidoesMockService do
  let(:cpf_cnpj) { '12345678900' }
  subject { described_class.new(cpf_cnpj) }

  describe '#buscar_certidoes' do
    let(:resultado) { subject.buscar_certidoes }

    it 'retorna um hash com o cpf_cnpj informado' do
      expect(resultado[:cpf_cnpj]).to eq(cpf_cnpj)
    end

    it 'retorna um array de certidões' do
      expect(resultado[:certidoes]).to be_an(Array)
      expect(resultado[:certidoes].size).to eq(3)
    end

    it 'cada certidão possui tipo, status e conteudo_base64' do
      resultado[:certidoes].each do |certidao|
        expect(certidao).to have_key(:tipo)
        expect(certidao).to have_key(:status)
        expect(certidao).to have_key(:conteudo_base64)
      end
    end

    it 'status das certidões estão entre os valores esperados' do
      status_federal = ['negativa', 'positiva', 'pendente']
      status_estadual = ['negativa', 'pendente']
      status_trabalhista = ['negativa']

      cert_federal = resultado[:certidoes].find { |c| c[:tipo] == 'federal' }
      cert_estadual = resultado[:certidoes].find { |c| c[:tipo] == 'estadual' }
      cert_trabalhista = resultado[:certidoes].find { |c| c[:tipo] == 'trabalhista' }

      expect(status_federal).to include(cert_federal[:status])
      expect(status_estadual).to include(cert_estadual[:status])
      expect(status_trabalhista).to include(cert_trabalhista[:status])
    end

    it 'o conteudo_base64 é uma string codificada em base64' do
        service = described_class.new("12345678900")
        resultado = service.buscar_certidoes
      
        resultado[:certidoes].each do |cert|
          decoded = Base64.decode64(cert[:conteudo_base64]).force_encoding("UTF-8")
          expect(decoded).to include("Conteúdo da certidão")
        end
      end      
  end
end
