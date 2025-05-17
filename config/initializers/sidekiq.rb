require 'sidekiq'
require 'sidekiq-cron'

# Configuração simples sem namespace
redis_config = { url: 'redis://localhost:6379/0' }

Sidekiq.configure_server do |config|
  config.redis = redis_config
  
  # Configuração do job para executar diariamente às 2h da manhã
  if defined?(Sidekiq::Cron)
    Sidekiq::Cron::Job.load_from_hash(
      'revalidar_certidoes' => {
        'class' => 'RevalidarCertidoesJob',
        'cron' => '0 2 * * *',  # Executa todos os dias às 2h
        'description' => 'Revalida todas as certidões diariamente às 2h'
      }
    )
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
