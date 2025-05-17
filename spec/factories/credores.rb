
FactoryBot.define do
  factory :credor do
    nome { "João Silva" }
    cpf_cnpj { "12345678901" }
    email { "joao@example.com" }
    telefone { "11987654321" }

    # Trait para adicionar o precatório ao credor
    trait :com_precatorio do
      after(:create) do |credor|
        create(:precatorio, credor: credor) 
      end
    end
  end
end
