class DocumentoPessoal < ApplicationRecord
  belongs_to :credor
  has_one_attached :arquivo

  # Validações de campos
  validates :tipo, presence: true
  validates :enviado_em, presence: true
  # Tornar descricao opcional, já que pode não ser necessário em todos os casos
  validates :descricao, presence: false

  # Validações personalizadas
  validate :arquivo_anexado
  validate :validar_arquivo

  # Callback para preencher enviado_em automaticamente
  before_validation :set_enviado_em, on: :create

  # Método para facilitar acesso à URL do arquivo
  def arquivo_url
    if arquivo.attached?
      Rails.application.routes.url_helpers.rails_blob_path(arquivo, only_path: true)
    end
  end

  # Método para serialização JSON
  def as_json(options = {})
    super(options).merge({
      arquivo_url: arquivo_url
    })
  end

  private

  # Validação para garantir que o arquivo foi anexado
  def arquivo_anexado
    errors.add(:arquivo, "é obrigatório para documentos pessoais") unless arquivo.attached?
  end

  # Validação para garantir que o tipo e o tamanho do arquivo estão corretos
  def validar_arquivo
    if arquivo.attached?
      # Ampliando os tipos aceitos para maior compatibilidade
      valid_types = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf', 'application/x-pdf']
      
      # Verificar se o content_type está na lista de tipos válidos
      unless valid_types.include?(arquivo.content_type)
        errors.add(:arquivo, "deve ser um dos seguintes tipos: JPEG, PNG ou PDF")
      end
      
      # Verificar tamanho do arquivo (5MB)
      if arquivo.byte_size > 5.megabytes
        errors.add(:arquivo, "deve ser menor que 5MB")
      end
    end
  end

  # Método para definir enviado_em automaticamente se não estiver preenchido
  def set_enviado_em
    self.enviado_em ||= Time.current
  end
end
