# config/initializers/sidekiq_cron.rb

# Define o cron job para revalidar as certidões todos os dias às 2h da manhã
Sidekiq::Cron::Job.create(
  name: 'Revalidar certidões - todos os dias às 2h', 
  cron: '0 2 * * *',  # Executa todos os dias às 2h
  class: 'RevalidarCertidoesJob'
)
