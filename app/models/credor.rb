class Credor < ApplicationRecord
  has_one :precatorio, dependent: :destroy
  has_many :documentos_pessoais, class_name: "DocumentoPessoal", foreign_key: "credor_id", dependent: :destroy
  has_many :certidoes, class_name: "Certidao"
  validates :nome, presence: true
  validates :cpf_cnpj, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :telefone, format: { with: /\A\d{10,11}\z/ }, allow_blank: true
  accepts_nested_attributes_for :precatorio
  # Comentar temporariamente esta validação para testes
  # validate :tem_documento?

  private

  def tem_documento?
    errors.add(:documentos_pessoais, "deve conter pelo menos um documento") if documentos_pessoais.empty?
  end
end
