# spec/factories/certidoes.rb
FactoryBot.define do
    factory :certidao do
      association :credor
      tipo { :federal }
      origem { :manual }
      status { :pendente }
      recebida_em { Time.current }
  
      after(:build) do |certidao|
        unless certidao.arquivo.attached?
          certidao.arquivo.attach(
            io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_document.pdf')),
            filename: 'test_document.pdf',
            content_type: 'application/pdf'
          )
        end
      end
    end
  end
  