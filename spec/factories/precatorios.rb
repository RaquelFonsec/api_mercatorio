
FactoryBot.define do
  factory :precatorio do
    valor { 1000.00 }
    descricao { "Precatorio de exemplo" }
    credor
  end
end
