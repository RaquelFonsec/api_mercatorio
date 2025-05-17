class Precatorio < ApplicationRecord
  belongs_to :credor

  validates :numero_precatorio, presence: true
  validates :valor_nominal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :foro, presence: true
  validates :data_publicacao, presence: true
end