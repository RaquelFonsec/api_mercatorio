class Certidao < ApplicationRecord
  belongs_to :credor
  has_one_attached :arquivo
  
  enum tipo: {
    federal: 0,
    estadual: 1,
    municipal: 2,
    trabalhista: 3
  }
  
  enum origem: {
    manual: 0,
    api: 1
  }
  
  enum status: {
    pendente: 0,
    negativa: 1,
    positiva: 2,
    invalida: 3
  }

  validates :tipo, presence: true
  validates :origem, presence: true
  validates :status, presence: true
  validates :recebida_em, presence: true
  validate :arquivo_ou_conteudo_presente

  def arquivo_ou_conteudo_presente
    if arquivo.blank? && conteudo_base64.blank?
      errors.add(:base, "É necessário fornecer um arquivo ou conteúdo base64")
    end
  end

  def validar_tipo_arquivo
    return unless arquivo.attached?

    tipos_permitidos = ['application/pdf', 'image/jpeg', 'image/png']
    unless tipos_permitidos.include?(arquivo.content_type)
      errors.add(:arquivo, "deve ser um arquivo PDF, JPEG ou PNG")
      arquivo.purge
    end
  end

  # Método para atualizar a certidão após a revalidação
  def atualizar_apos_revalidacao(novo_status, novo_conteudo_base64 = nil)
    # Atualiza o status e o conteúdo base64 (se fornecido)
    update(status: novo_status, conteudo_base64: novo_conteudo_base64)
  end
  
  # Método para filtrar certidões a serem revalidadas
  def self.para_revalidar
    where('recebida_em < ?', 24.hours.ago)
  end
end
