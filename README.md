


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

Testes Automatizados
A aplicação inclui uma suíte de testes automatizados desenvolvida com RSpec para garantir o funcionamento correto dos endpoints e regras de negócio.
Para executar os testes, rode o comando:


bundle exec rspec


Índice

Testes RSpec para CredoresController

Criação de Credores (POST #create)

Upload de Documentos (POST #upload_documento)

Busca de Certidões via API (POST #buscar_certidoes_api)

Upload Manual de Certidões (POST #upload_certidao_manual)

Visualização de Credor (GET #show)

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

CredoresController — CRUD, upload de documentos e certidões, busca via API

Api::CertidoesMockController — Mock da API de certidões

Api::DocumentosPessoaisController — API para gerenciamento de documentos pessoais

Service Classes

Api::CertidoesMockService — Serviço para simular a busca de certidões via API externa mockada

Jobs

RevalidarCertidoesJob — Job para revalidação periódica das certidões via API mock

Como Rodar os Testes

Utilizar RSpec para executar os testes do controller CredoresController.
Fixtures são usados para upload de arquivos (PDFs).
Testes cobrem cenários válidos e inválidos para criação e upload.
API de Gestão de Credores, Precatórios, Documentos e Certidões



API para cadastro e gerenciamento de credores, precatórios, documentos pessoais e certidões, com suporte a upload de arquivos, consultas e revalidação automática das certidões via job Sidekiq.

Endpoints Principais

Criar Credor com Precatório

POST /credores


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

Body: URL temporária para acessar o documento enviado

{
  "arquivo_url": "/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MzQsInB1ciI6ImJsb2JfaWQifX0=--e3ca8071bea82cd8956755c32c76661119d07b44/RG.pdf" ( Dados de Exemplo ficticio)

}





Upload de Certidões via JSON com conteúdo em Base64

POST /credores/:id/certidoes

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

Você deve enviar um JSON no corpo da requisição com os seguintes campos:


{
  "tipo": "federal",
  "origem": "manual",
  "status": "pendente",
  "recebida_em": "2025-05-17T18:22:33Z",
  "conteudo_base64": "JVBERi0xLjUNCiW1tbW1DQoxIDAgb2JqDQo8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFIvTGFuZw==" (Dados ficticios de exemplo)
}





tipo: tipo da certidão (ex: federal, estadual, municipal, etc.)

origem: origem da certidão (ex: manual)

status: status atual (ex: pendente, aprovado)

recebida_em: data em que a certidão foi recebida (formato ISO 8601)

conteudo_base64: conteúdo do arquivo codificado em Base64

Exemplo de resposta da API:

Após o envio correto, a API retornará um JSON contendo os dados da certidão criada, incluindo a URL:



{
  "id": 90,
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
POST http://localhost:3000/credores/:id/buscar-certidoes

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
GET http://localhost:3000/api/certidoes?cpf_cnpj=00000000000

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

O job RevalidarCertidoesJob automatiza a revalidação das certidões no sistema, buscando todas as certidões que precisam ser revalidadas (mais de 24 horas desde a última validação) e atualizando seu status e conteúdo via uma API mockada.


Fluxo de funcionamento:

Executado em background pelo Sidekiq.

Busca as certidões para revalidação (Certidao.para_revalidar).

Para cada certidão:

Chama o serviço externo mockado para revalidar.

Atualiza status e conteúdo da certidão.

Registra logs de sucesso ou erro.

Configuração do Sidekiq com Cron e Redis

Usamos Sidekiq Cron para agendar a execução diária às 2h da manhã.



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


Para teste manual:

rails c

RevalidarCertidoesJob.perform_now


Acesse no navegador

http://localhost:3000/sidekiq


Contribuições

Fique à vontade para abrir issues, enviar pull requests ou sugerir melhorias!

Suporte

Se tiver dúvidas ou problemas, abra uma issue ou entre em contato.

Obrigado por usar este projeto! 🚀


