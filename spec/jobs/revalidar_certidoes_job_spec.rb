require 'rails_helper'

RSpec.describe RevalidarCertidoesJob, type: :job do
  let!(:credor) { create(:credor, cpf_cnpj: '12345678900') }

  let!(:certidao_pendente) do
    create(:certidao,
      credor: credor,
      status: :pendente,
      recebida_em: 2.days.ago,   # Para estar na lista de para_revalidar (> 24h)
      tipo: :federal,
      origem: :manual
    )
  end

  before do
    # Mock do serviço Api::CertidoesMockService para controlar o retorno
    mock_service = instance_double("Api::CertidoesMockService")
    allow(Api::CertidoesMockService).to receive(:new).with(credor.cpf_cnpj).and_return(mock_service)
    
    allow(mock_service).to receive(:buscar_certidoes).and_return(
      {
        certidoes: [
          {
            status: "negativa",
            conteudo_base64: Base64.encode64("PDF content here")
          }
        ]
      }
    )

    # Faz o upload inicial de um arquivo para a certidão pendente
    certidao_pendente.arquivo.attach(
      io: File.open(Rails.root.join('spec/fixtures/files/test_document.pdf')),
      filename: 'test_document.pdf',
      content_type: 'application/pdf'
    )
  end

  it 'executa o job e revalida certidões pendentes' do
    expect {
      described_class.perform_now
    }.to change { certidao_pendente.reload.status }.from('pendente').to('negativa')

    expect(certidao_pendente.arquivo.attached?).to be true # O attachment permanece
  end

  context 'quando API retorna erro' do
    before do
      mock_service = instance_double("Api::CertidoesMockService")
      allow(Api::CertidoesMockService).to receive(:new).with(credor.cpf_cnpj).and_return(mock_service)
      allow(mock_service).to receive(:buscar_certidoes).and_return({ certidoes: [] })
    end

    it 'marca a certidão como inválida e remove o attachment' do
      expect(certidao_pendente.arquivo.attached?).to be true # Attachment antes do job

      expect {
        described_class.perform_now
      }.to change { certidao_pendente.reload.status }.from('pendente').to('invalida')

      expect(certidao_pendente.arquivo.attached?).to be false # Attachment removido
    end
  end
end
