


Projeto API REST - Originação de Precatórios na Mercatório

Projeto API REST que simula a etapa de originação de precatórios na Mercatório, permitindo o cadastro de credores, seus precatórios, upload e gestão de documentos pessoais e certidões.
O sistema suporta o fluxo inicial de análise jurídica e documental dos direitos creditórios, com funcionalidades para obtenção manual e automática de certidões, upload de documentos e consulta consolidada dos dados do credor.
Uma API mock local simula a busca automática de certidões via CPF/CNPJ, enquanto um job agendado com Sidekiq Cron executa a revalidação periódica das certidões para manter os dados atualizados e íntegros.


Funcionalidades Principais


Cadastro de credores e seus precatórios.
Upload de documentos pessoais (ex: RG, comprovante de residência) com validação de formato e tamanho.
Upload manual e automático de certidões, incluindo suporte a arquivos Base64.
Consulta consolidada de credores, documentos, precatórios e certidões.
Revalidação automática diária das certidões via job Sidekiq Cron.
API mockada para simular consulta externa de certidões.
Painel Sidekiq para gerenciamento das filas.

Interface Web Completa: Plataforma web intuitiva e responsiva para gerenciar todo o fluxo de cadastro de credores, seus precatórios e respectivos documentos.

Cadastro de Credores e Precatórios: Criação de credores com todos os dados essenciais, incluindo precatórios vinculados e seus detalhes financeiros.

Upload de Documentos Pessoais: Envio de documentos pessoais (ex: RG, CPF, comprovante de residência) com validação de formato e tamanho.

Upload de Certidões: Upload manual e automático de certidões, com suporte a arquivos Base64 para integração com sistemas externos.

Consulta Consolidada: Visualização centralizada de credores, documentos pessoais, precatórios e certidões em um único painel.

Validações de Upload de Arquivos
Tipos permitidos: JPEG, PNG, PDF.
Tamanho máximo: 5MB por arquivo.
Essas restrições garantem integridade e segurança no armazenamento dos documentos.


Tecnologias Utilizadas
Ruby 3.1.2
Rails 7.1.5.1
PostgreSQL 14.17
Redis 7.4.0
Sidekiq 7.3.9 (com Sidekiq Cron)
RSpec para testes automatizados
Active Storage para upload de arquivos



Como Executar o Projeto Localmente
Requisitos
Ruby 3.1.2
Rails 7.1.5.1
PostgreSQL 14.17
Redis 7.4.0
Sidekiq 7.3.9
Passos para Instalação
Clone o repositório:


git clone https://github.com/RaquelFonsec/api_mercatorio.git
cd api_mercatorio


Instale as gems:

bundle install

Configure o banco de dados:


rails db:create
rails db:migrate


Inicie o servidor Redis:

redis-server

Inicie o Sidekiq:

bundle exec sidekiq

Execute o servidor Rails:

rails server





##interface web - http://localhost:3000


![image](https://github.com/user-attachments/assets/bbd32be5-7def-42c4-b1ff-ea44ab555599)





![image](https://github.com/user-attachments/assets/cf9d6c90-45e0-4c1d-b66a-ab0ce4096047)






![image](https://github.com/user-attachments/assets/1376de1d-3bef-4887-b6e2-2506bf44ee8e)




Testes Automatizados
A aplicação inclui uma suíte de testes automatizados desenvolvida com RSpec para garantir o funcionamento correto dos endpoints e regras de negócio.
Para executar os testes, rode o comando:

bundle exec rspec

###Testes do CredoresController##

POST #create

Testa criação de credor com parâmetros válidos e inválidos, incluindo atualização se o cpf_cnpj já existir.

GET #show

Verifica resposta ao buscar credor existente e tratamento de erro quando não encontrado.

POST #upload_documento

Testa upload de documento com arquivo válido, sem arquivo (erro) e para credor inexistente (erro 404).





####Testes do CertidoesUploadsController - Ação upload_certidao_manual:####

Verifica o upload manual de certidões para um credor específico.

Testa casos de sucesso para envio de arquivo e conteúdo Base64.

Valida erros para credor inexistente, tipo inválido, ausência de arquivo/conteúdo, e conteúdo Base64 inválido.

Garante respostas HTTP corretas (201 para sucesso, 404 e 422 para erros).



###Testes para RevalidarCertidoesJob###

Executa o job e revalida certidões pendentes: Verifica se o job atualiza o status da certidão para "negativa" e mantém o attachment quando a API retorna sucesso.

Marca a certidão como inválida e remove o attachment quando a API retorna erro: Verifica se o job atualiza o status para "invalida" e remove o attachment quando a API não encontra certidões.




##Teste Api::CertidoesMockController ##

Testa o endpoint buscar_certidoes_api do controller Api::CertidoesMockController, verificando respostas corretas para credor existente, não existente e erro inesperado, além da criação das certidões no banco.



##Teste do Api::CertidoesMockService:##


Verifica se o serviço retorna um hash contendo o CPF/CNPJ correto, uma lista de certidões com os atributos esperados (tipo, status, conteudo_base64), se os status das certidões estão dentro dos valores permitidos, e se o conteúdo base64 

é uma string válida decodificável contendo texto esperado.





Índice

Testes Rspec

Configuração de Rotas

Painel Sidekiq com Autenticação

Rotas RESTful para Credores com Ações Customizadas

Namespace API para Certidões e Credores

Modelos

Certidao — Relacionamentos, enums, validações e métodos

Credor — Relacionamentos e validações

DocumentoPessoal — Relacionamentos, validações e callbacks

Precatorio — Relacionamentos e validações

Controllers

###CredoresController — Gerenciamento de Credores, Upload de Documentos e Exibição de Informações


create: Cria ou atualiza um credor e seu precatório associado. Se o credor já existir, apenas os dados são atualizados; caso contrário, um novo registro é criado.


upload_documento: Realiza o upload de documentos pessoais vinculados ao credor, como RG, CPF ou comprovantes, salvando o arquivo no banco e gerando um link de acesso.


show: Exibe detalhes completos do credor, incluindo dados cadastrais, precatório associado, documentos pessoais e certidões vinculadas, além de links para download dos arquivos.


Rescue e Tratamento de Erros: Implementa tratamento de exceções para casos de credores não encontrados ou falhas no upload de arquivos.


Antes das Ações: Utiliza before_action :set_credor para carregar o credor em ações específicas, garantindo que apenas credores válidos sejam manipulados.


Buscar certidões via API mock (POST /credores/:id/buscar-certidoes) que cria certidões fictícias com conteúdo em Base64.



 Api::CertidoesMockController - Simulação de busca de certidões via API mockada

Ação: buscar_certidoes_api

- Recebe `cpf_cnpj` como parâmetro.
- 
- Busca o credor correspondente no banco.
- 
- Se não encontrado, retorna erro 404.
- 
- Se encontrado, cria certidões mockadas (federal e trabalhista) em Base64 associadas ao credor.
- 
- Salva essas certidões no banco.
- 
- Retorna JSON com mensagem de sucesso e dados das certidões criadas.
- 
- Trata erros inesperados com resposta 500 e mensagem de erro.




####CertidoesUploadsController — Upload Manual de Certidões

upload_certidao_manual: Permite o upload de certidões manualmente associadas a um credor.

Processamento:

Verifica se o credor existe.

Valida o tipo da certidão.

Salva o arquivo diretamente ou decodifica o Base64 e o transforma em um PDF temporário.

Retorna os detalhes da certidão criada, incluindo o link para download.

Tratamento de erros inclui credor não encontrado, tipo inválido e falhas na decodificação do Base64.




Service Classes

Api::CertidoesMockService: Serviço responsável por simular a busca de certidões via API externa mockada, retornando certidões fictícias para um CPF/CNPJ específico.


Jobs

RevalidarCertidoesJob: Job responsável pela revalidação periódica das certidões existentes, utilizando o serviço Api::CertidoesMockService para atualizar status e conteúdo base64.


Comandos para verificar onde os arquivos do Active Storage estão armazenados e visualizar seu conteúdo

Localizar o diretório raiz do armazenamento local

No console Rails (rails c), execute:

ActiveStorage::Blob.service.root


Retorna o caminho absoluto da pasta onde os arquivos são salvos localmente, por exemplo:

/caminho/para/seu/projeto/storage

Listar o conteúdo (pastas e arquivos) da pasta de armazenamento

No console Rails, rode:

Dir.entries(ActiveStorage::Blob.service.root)
Mostra as subpastas organizadas por hash onde os arquivos estão guardados.

Explorar arquivos específicos

Para ver arquivos dentro das subpastas, use comandos do terminal, por exemplo:

ls -l /caminho/para/seu/projeto/storage/<subpasta>






API para cadastro e gerenciamento de credores, precatórios, documentos pessoais e certidões, com suporte a upload de arquivos, consultas e revalidação automática das certidões via job Sidekiq.

Endpoints Principais

Criar Credor com Precatório

POST /credores

Como enviar a requisição no Postman:

Método: Selecione POST.

http://localhost:3000/credores

Headers: Adicione o header:Content-Type: application/json

Body:

Selecione raw.

Escolha o formato JSON.

Insira o seguinte JSON no campo Body:

Request Body (JSON):

{
  "credor": {
    "nome": "Maria Silva",
    "cpf_cnpj": "12345678900",
    "email": "maria@example.com",
    "telefone": "11999999999",
    "precatorio": {
      "numero_precatorio": "0001234-56.2020.8.26.0050",
      "valor_nominal": 50000.00,
      "foro": "TJSP",
      "data_publicacao": "2023-10-01"
    }
  }
}






Response:

Status: 201 Created

Body:

{
  "nome": "Maria Silva",
  "cpf_cnpj": "12345678900",
  "email": "maria@example.com",
  "telefone": "11999999999",
  "id": 1,
  "created_at": "2025-05-16T00:04:20.378Z",
  "updated_at": "2025-05-16T23:10:52.520Z"
}



Upload de Documentos Pessoais

POST /credores/:id/documentos

Faz o upload de documentos pessoais vinculados a um credor, como identidade, comprovante de residência, etc.

Request:

URL: /credores/:id/documentos (substitua :id pelo ID do credor)  

Method: POST

Content-Type: multipart/form-data

Form Data:

arquivo (file): Arquivo do documento a ser enviado (ex: PDF, imagem)

tipo (string): Tipo do documento (ex: "RG", "comprovante_residencia")

Exemplo usando curl:



curl -X POST http://localhost:3000/credores/1/documentos \
  -F "arquivo=@/caminho/para/seu/documento.pdf" \
  -F "tipo=RG"



Nota: Substitua /caminho/para/seu/documento.pdf pelo caminho real do arquivo no seu computador.

Response:

Status: 201 Created

Body: URL temporária para acessar o documento enviado http://localhost:3000

{
  "arquivo_url": "/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MzQsInB1ciI6ImJsb2JfaWQifX0=--e3ca8064bea82cd8956755c32c76661119d07b44/RG.pdf" ( Dados de Exemplo ficticio)

}





Upload de Certidões via JSON com conteúdo em Base64

POST /credores/:id/certidoes (VIA POSTMAN)

Esse endpoint recebe uma certidão vinculada ao credor, enviando os dados via JSON, incluindo o arquivo codificado em Base64.

Como usar:

Gerar a string Base64 do arquivo

Para enviar arquivos via JSON, a API espera que o conteúdo do arquivo esteja codificado em Base64 (uma representação do arquivo em texto ).

No Linux ou macOS, para gerar essa string você pode usar o comando:


base64 "/caminho/para/arquivo.pdf" | tr -d '\n'


Esse comando converte o arquivo para Base64 e remove todas as quebras de linha (tr -d '\n'), porque a string Base64 precisa estar contínua, sem quebras.

Visualizar uma prévia (50 caracteres)

Se quiser apenas ver os primeiros caracteres da codificação Base64 (para conferir ou mostrar um exemplo), pode usar:

base64 "/caminho/para/arquivo.pdf" | head -c 50

O que fazer com a string Base64 gerada? 

Você deve colocar no campo conteudo_base64 do JSON para enviar o arquivo para a API.

Exemplo de requisição POST para criar uma certidão manual com conteúdo Base64:

No Postman Headers: Adicione o header:Content-Type: application/json

Body:

Selecione raw.

Escolha o formato JSON.

Insira o conteúdo no formato JSON, incluindo o campo conteudo_base64.

   POST http://localhost:3000/credores/1/certidoes \
  -H "Content-Type: application/json" \
  -d '{
    "tipo": "federal",
    "origem": "manual",
    "status": "pendente",
    "recebida_em": "2025-05-17T18:22:33Z",
    "conteudo_base64": "JVBERi0xLjUNCiW1tbW1DQoxIDAgb2JqDQo8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFIvTGFuZw=="
  }'



Lembre-se de trocar o 1 no caminho pela ID correta do credor e substituir o valor do "conteudo_base64" pela sua string Base64 real (gerada com o comando base64 /caminho/arquivo.pdf | tr -d '\n').


tipo: tipo da certidão (ex: federal, estadual, municipal, etc.)

origem: origem da certidão (ex: manual)

status: status atual (ex: pendente, aprovado)

recebida_em: data em que a certidão foi recebida (formato ISO 8601)

conteudo_base64: conteúdo do arquivo codificado em Base64

Exemplo de resposta da API:

Após o envio correto, a API retornará um JSON contendo os dados da certidão criada, incluindo a URL:



{
  "id": 10,
  "tipo": "federal",
  "origem": "manual",
  "status": "pendente",
  "recebida_em": "2025-05-17T21:38:05.123Z",
  "arquivo_url": "http://localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTE0LCJwdXIiOiJibG9iX2lkIn19--c2b638341d662a9ea12261e80d2bda8b4a31572f/arquivo_1747517885.pdf" (Dados ficticios de exemplo)
}








Consultar Dados do Credor

GET /credores/:id

Descrição

Este endpoint retorna os dados completos de um credor específico, incluindo suas informações pessoais, precatórios vinculados, documentos pessoais e certidões cadastradas.

URL
GET http://localhost:3000/credores/:id


onde :id é o ID do credor que você deseja consultar.

Exemplo de requisição (curl )

curl -X GET http://localhost:3000/credores/1


Exemplo de resposta JSON:





{
  "credor": {
    "id": 1,
    "nome": "Maria Silva",
    "cpf_cnpj": "12345678900",
    "email": "maria@example.com",
    "telefone": "11999999999",
    "created_at": "2025-05-16T00:04:20.378Z",
    "updated_at": "2025-05-16T23:10:52.520Z"
  },

  
  "precatorio": {
    "id": 3,
    "numero_precatorio": "0001234-56.2020.8.26.0050",
    "valor_nominal": "50000.0",
    "foro": "TJSP",
    "data_publicacao": "2023-10-01"
  },


  
  "documentos": [
    {
      "id": 13,
      "tipo": "RG",
      "enviado_em": "2025-05-17T14:07:57.946Z",
      "arquivo_url": "http://localhost:3000/rails/active_storage/blobs/redirect/..."
    }
    // mais documentos...
  ],


  
  "certidoes": [
    {
      "id": 34,
      "tipo": "federal",
      "origem": "manual",
      "status": "pendente",
      "recebida_em": "2025-05-17T15:39:48.360Z",
      "arquivo_url": null
    },
    {
      "id": 37,
      "tipo": "federal",
      "origem": "manual",
      "status": "pendente",
      "recebida_em": "2025-05-17T16:14:12.168Z",
      "arquivo_url": "http://localhost:3000/rails/active_storage/blobs/redirect/..."
    }
    // mais certidões...
  ]
}


Explicação dos campos:


credor

id: Identificador único do credor.

nome: Nome completo do credor.

cpf_cnpj: Documento CPF ou CNPJ do credor.

email: Endereço de e-mail cadastrado.

telefone: Número de telefone cadastrado.

created_at e updated_at: Datas de criação e última atualização do registro do credor.

precatorio

id: Identificador único do precatório.

numero_precatorio: Número oficial do precatório.

valor_nominal: Valor original do precatório.

foro: Tribunal ou foro responsável pelo precatório (ex: TJSP ).

data_publicacao: Data de publicação do precatório.

documentos

Lista com os documentos pessoais enviados pelo credor.

Cada documento inclui:

id: Identificador do documento.

tipo: Tipo do documento (ex: RG, Comprovante de Residencia etc).

enviado_em: Data e hora em que o documento foi enviado.

arquivo_url: URL para acessar ou baixar o arquivo do documento.

certidoes

Lista das certidões associadas ao credor.

Cada certidão inclui:

id: Identificador da certidão.

tipo: Tipo da certidão (ex: federal, estadual).

origem: Como a certidão foi inserida (ex: manual, API).

status: Status atual da certidão (ex: pendente, aprovada).

recebida_em: Data em que a certidão foi recebida.

arquivo_url: URL para acessar o arquivo da certidão.

Buscar Certidões via API Mockada

POST /credores/:id/buscar-certidoes

Descrição

Simula a obtenção automática de certidões para um credor específico usando uma API mockada. Essa chamada gera certidões fictícias vinculadas ao credor, que são retornadas na resposta.


URL
POST http://localhost:3000/credores/:id/buscar-certidoes (VIA POSTMAN)

(Substitua :id pelo id do credor desejado )

Corpo da requisição

Não é necessário enviar um corpo (payload) na requisição para este endpoint.

Exemplo de resposta:




{
  "message": "Busca de certidões via API mockada concluída.",
  "certidoes_recebidas": [
    {
      "id": 91,
      "credor_id": 1,
      "tipo": "federal",
      "origem": "api",
      "arquivo_url": null,
      "conteudo_base64": "Q29udGXDumRvIGRhIGNlcnRpZMOjbyBmZWRlcmFsIGVtIFBERg==",
      "status": "negativa",
      "recebida_em": "2025-05-17T21:55:59.072Z",
      "created_at": "2025-05-17T21:55:59.079Z",
      "updated_at": "2025-05-17T21:55:59.079Z"
    },
    {
      "id": 92,
      "credor_id": 1,
      "tipo": "trabalhista",
      "origem": "api",
      "arquivo_url": null,
      "conteudo_base64": "Q29udGXDumRvIGRhIGNlcnRpZMOjbyB0cmFiYWxoaXN0YSBlbSBQREY=",
      "status": "positiva",
      "recebida_em": "2025-05-17T21:55:59.085Z",
      "created_at": "2025-05-17T21:55:59.091Z",
      "updated_at": "2025-05-17T21:55:59.091Z"
    }
  ]
}






Explicação dos campos da resposta:

message: Confirma que a busca simulada de certidões foi concluída.

certidoes_recebidas: Lista de certidões obtidas pela simulação.

Cada item da lista possui:

id: Identificador único da certidão.

credor_id: ID do credor associado.

tipo: Tipo da certidão (exemplo: federal, trabalhista).

origem: Origem da certidão — neste caso, 'api' indica que foi obtida via API mockada.

arquivo_url: Link para download do arquivo da certidão (pode ser null se não disponível).

conteudo_base64: Conteúdo do arquivo codificado em Base64.

status: Resultado da certidão (exemplo: positiva, negativa).

recebida_em: Data e hora em que a certidão foi recebida.

created_at e updated_at: Datas de criação e atualização do registro.



API Mockada de Certidões

GET /api/certidoes

Descrição

Este endpoint simula uma API de certidões que retorna uma lista de certidões para um dado CPF ou CNPJ. É uma API mockada para testes e demonstrações.


URL
GET http://localhost:3000/api/certidoes?cpf_cnpj=00000000000 (VIA POSTMAN)

Parâmetros da Query


Parâmetro

Tipo string Descrição

Exemplo  cpf_cnpj

CPF ou CNPJ do credor

00000000000




Exemplo de resposta:




{
  "cpf_cnpj": "00000000000",
  "certidoes": [
    {
      "tipo": "federal",
      "status": "pendente",
      "conteudo_base64": "Q29udGXDumRvIGRhIGNlcnRpZMOjbyBmZWRlcmFsIHBhcmEgMDAwMDAwMDAwMDA="
    },
    {
      "tipo": "estadual",
      "status": "pendente",
      "conteudo_base64": "Q29udGXDumRvIGRhIGNlcnRpZMOjbyBlc3RhZHVhbCBwYXJhIDAwMDAwMDAwMDAw"
    },
    {
      "tipo": "trabalhista",
      "status": "negativa",
      "conteudo_base64": "Q29udGXDumRvIGRhIGNlcnRpZMOjbyB0cmFiYWxoaXN0YSBwYXJhIDAwMDAwMDAwMDAw"
    }
  ]
}



Explicação dos campos:


cpf_cnpj: CPF ou CNPJ consultado.


certidoes: Lista de certidões retornadas pela API.

tipo: Tipo da certidão (ex.: federal, estadual, trabalhista ).

status: Status atual da certidão (ex.: pendente, negativa).

conteudo_base64: Conteúdo fictício criado para teste da certidão codificado em Base64 (pode ser decodificado para obter o arquivo original, como PDF).



Revalidação Automática de Certidões com Sidekiq e Redis

Descrição do Job RevalidarCertidoesJob

O job RevalidarCertidoesJob automatiza a revalidação das certidões no sistema, buscando todas as certidões que precisam ser revalidadas (com mais de 24 horas desde a última validação) e atualizando seu status e conteúdo via uma API mockada.

Fluxo de funcionamento:

Executado em background pelo Sidekiq.

Busca as certidões que precisam de revalidação (usando o escopo Certidao.para_revalidar).

Para cada certidão:

Chama o serviço externo (mockado) para obter a revalidação.

Atualiza o status e o conteúdo da certidão.

Registra logs de sucesso ou erro.

Configuração do Sidekiq com Cron e Redis

Utilizamos o sidekiq-cron para agendar a execução diária do job às 2h da manhã, e o Redis como backend de filas.



require 'sidekiq'

require 'sidekiq-cron'

redis_config = { url: 'redis://localhost:6379/0' }

Sidekiq.configure_server do |config|

  config.redis = redis_config

  if defined?(Sidekiq::Cron)
  
    Sidekiq::Cron::Job.load_from_hash(
    
      'revalidar_certidoes' => {
      
        'class' => 'RevalidarCertidoesJob',
        
        'cron' => '0 2 * * *',
        
        'description' => 'Revalida todas as certidões diariamente às 2h'
      }
    )
    
  end
end

Sidekiq.configure_client do |config|

  config.redis = redis_config  
end



Como executar:

Iniciar o Redis

Via terminal (Linux/Ubuntu):

sudo service redis-server start


Executar o Sidekiq

bundle exec sidekiq 


Iniciar o servidor Rails


rails server


Executar o job manualmente 

rails c

RevalidarCertidoesJob.perform_later


Acompanhe os jobs e filas no painel web do Sidekiq acessando:

http://localhost:3000/sidekiq


Para ver logs específicos do Sidekiq: tail -f log/sidekiq.log | grep "Sidekiq"


Explicação da resposta retornada pelo Job RevalidarCertidoesJob

O job RevalidarCertidoesJob realiza a revalidação automática das certidões em background e gera logs que indicam o resultado da operação para cada certidão processada.

Exemplo de log retornado:


2025-05-18T12:50:11.487Z pid=398395 tid=8x87 class=RevalidarCertidoesJob jid=39e4d90d043ce7239b96567a INFO: Certidão #3 revalidada com sucesso. Novo status: negativa para o credor 12345678900

2025-05-18T12:50:11.487Z pid=398395 tid=8x87 class=RevalidarCertidoesJob jid=39e4d90d043ce7239b96567a INFO: Performed RevalidarCertidoesJob (Job ID: 1df909f2-2bf2-43e1-91a4-631c611945d3) from Sidekiq(default) in 295.01ms

2025-05-18T12:50:11.488Z pid=398395 tid=8x87 class=RevalidarCertidoesJob jid=39e4d90d043ce7239b96567a elapsed=0.318 INFO: done Revalidação Automática de Certidões com Sidekiq e Redis


O que cada parte significa:

Certidão #3 revalidada com sucesso: A certidão de ID 3 foi atualizada com sucesso após consultar a API mockada.

Novo status: negativa: O status atualizado da certidão (ex: negativa, positiva, pendente).

para o credor 12345678900: Indica o CPF/CNPJ do credor relacionado.

Performed RevalidarCertidoesJob ... in 295.01ms: Tempo que o job levou para executar.

done Revalidação Automática de Certidões com Sidekiq e Redis: Confirmação que o processo foi concluído.







Contribuições

Fique à vontade para abrir issues, enviar pull requests ou sugerir melhorias!

Suporte

Se tiver dúvidas ou problemas, abra uma issue ou entre em contato.

Obrigado por usar este projeto! 🚀


