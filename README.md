📦 Mercatório Backend Challenge


O Mercatório Backend Challenge é um projeto de API REST que simula a etapa de originação de precatórios na Mercatório. A aplicação permite o cadastro de credores, seus respectivos precatórios, além do upload e gestão de documentos pessoais e certidões.


O objetivo do sistema é simular o fluxo inicial de análise jurídica e documental dos direitos creditórios, implementando funcionalidades como a obtenção manual e automática de certidões, upload de documentos pessoais e consulta consolidada dos dados do credor.


Para fins de simulação, uma API mock local é utilizada para simular a busca automática de certidões a partir do CPF/CNPJ do credor.

Além disso, a aplicação utiliza o Sidekiq Cron para executar um job de revalidação automática das certidões a cada 24 horas. Esse job consulta todas as certidões cadastradas e verifica sua validade, garantindo que os dados estejam sempre atualizados e sincronizados com a fonte de origem. Essa abordagem assegura a integridade das informações e facilita a gestão dos documentos pelos usuários.


A aplicação foi desenvolvida seguindo boas práticas de desenvolvimento RESTful, com suporte a upload de arquivos e documentação para execução local.


## Índice

1. [Testes RSpec para CredoresController](#testes-rspec-para-credorescontroller)  
   1.1. Criação de Credores (`POST #create`)  
   1.2. Upload de Documentos (`POST #upload_documento`)  
   1.3. Busca de Certidões via API (`POST #buscar_certidoes_api`)  
   1.4. Upload Manual de Certidões (`POST #upload_certidao_manual`)  
   1.5. Visualização de Credor (`GET #show`)  

2. [Configuração de Rotas](#configuração-de-rotas)  
   2.1. Painel Sidekiq com Autenticação  
   2.2. Rotas RESTful para Credores com Ações Customizadas  
   2.3. Namespace API para Certidões e Credores  

3. [Modelos](#modelos)  
   3.1. `Certidao` — Relacionamentos, enums, validações e métodos  
   3.2. `Credor` — Relacionamentos e validações  
   3.3. `DocumentoPessoal` — Relacionamentos, validações e callbacks  
   3.4. `Precatorio` — Relacionamentos e validações  

---

## Descrição Resumida

Este projeto gerencia credores, documentos pessoais e certidões, suportando upload de arquivos, integração simulada com API externa, e inclui painel de tarefas com Sidekiq.

---

## Como Rodar os Testes

- Utilizar RSpec para executar os testes do controller `CredoresController`.
- Fixtures são usados para upload de arquivos (PDFs).
- Testes cobrem cenários válidos e inválidos para criação e upload.

---

## Tecnologias Utilizadas

- Ruby on Rails  
- RSpec  
- Active Storage (upload de arquivos)  
- Sidekiq (fila de tarefas)  

---


 API de Gestão de Credores, Precatórios, Documentos e Certidões

API para cadastro e gerenciamento de credores, precatórios, documentos pessoais e certidões, com suporte a upload de arquivos, consultas e revalidação automática das certidões via job Sidekiq.

---

 Endpoints Principais

1. Criar Credor com Precatório

- POST /credores

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




Response

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







POST /credores/:id/documentos — Upload de documentos pessoais

Faz o upload de documentos pessoais vinculados a um credor, como identidade, comprovante de residência, etc.

Request

URL: /credores/:id/documentos
(substitua :id pelo ID do credor)

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

Response

Status: 201 Created

Body: URL temporária para acessar o documento enviado

{
  "arquivo_url": "/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MzQsInB1ciI6ImJsb2JfaWQifX0=--e3ca8071bea82cd8956755c32c76661119d07b44/RG.pdf"
}





POST /credores/:id/certidoes — Upload de certidões via JSON com conteúdo em Base64

Esse endpoint recebe uma certidão vinculada ao credor, enviando os dados via JSON, incluindo o arquivo codificado em Base64.


Como usar

1. Gerar a string Base64 do arquivo
 
Para enviar arquivos via JSON, a API espera que o conteúdo do arquivo esteja codificado em Base64 (uma representação do arquivo em texto).

No Linux ou macOS, para gerar essa string você pode usar o comando:

base64 "/caminho/para/arquivo.pdf" | tr -d '\n'

Esse comando converte o arquivo para Base64 e remove todas as quebras de linha (tr -d '\n'), porque a string Base64 precisa estar contínua, sem quebras.

2. Visualizar uma prévia (50 caracteres)
   
Se quiser apenas ver os primeiros caracteres da codificação Base64 (para conferir ou mostrar um exemplo), pode usar:

base64 "/caminho/para/arquivo.pdf" | head -c 50

O que fazer com a string Base64 gerada?
 você deve colocar no campo conteudo_base64 do JSON para enviar o arquivo para a API.

Exemplo de requisição POST para criar uma certidão manual com conteúdo Base64

Você deve enviar um JSON no corpo da requisição com os seguintes campos:


{
  "tipo": "federal",
  "origem": "manual",
  "status": "pendente",
  "recebida_em": "2025-05-17T18:22:33Z",
  "conteudo_base64": "JVBERi0xLjUNCiW1tbW1DQoxIDAgb2JqDQo8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFIvTGFuZw=="
}

tipo: tipo da certidão (ex: federal, estadual, municipal, etc.)

origem: origem da certidão (ex: manual)

status: status atual (ex: pendente, aprovado)

recebida_em: data em que a certidão foi recebida (formato ISO 8601)

conteudo_base64: conteúdo do arquivo codificado em Base64 

Exemplo de resposta da API
Após o envio correto, a API retornará um JSON contendo os dados da certidão criada, incluindo a URL 

EXEMPLO

{
  "id": 90,
  "tipo": "federal",
  "origem": "manual",
  "status": "pendente",
  "recebida_em": "2025-05-17T21:38:05.123Z",
  "arquivo_url": "http://localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTE0LCJwdXIiOiJibG9iX2lkIn19--c2b638341d662a9ea12261e80d2bda8b4a31572f/arquivo_1747517885.pdf"
}







GET /credores/:id

Descrição
Este endpoint retorna os dados completos de um credor específico, incluindo suas informações pessoais, precatórios vinculados, documentos pessoais e certidões cadastradas.

URL
GET http://localhost:3000/credores/:id

onde :id é o ID do credor que você deseja consultar.


Exemplo de requisição (curl)

curl -X GET http://localhost:3000/credores/1


Exemplo de resposta JSON para GET /credores/:id



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
    },
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

Explicação dos campos



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

foro: Tribunal ou foro responsável pelo precatório (ex: TJSP).

data_publicacao: Data de publicação do precatório.



documentos
Lista com os documentos pessoais enviados pelo credor.

Cada documento inclui:

id: Identificador do documento.

tipo: Tipo do documento (ex: RG, CNH).

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

arquivo_url:





POST /credores/:id/buscar-certidoes (Postman)

Descrição

Simula a obtenção automática de certidões para um credor específico usando uma API mockada. Essa chamada gera certidões fictícias vinculadas ao credor, que são retornadas na resposta.


POST http://localhost:3000/credores/1/buscar-certidoes


(Substitua 1 pelo id do credor desejado)

Corpo da requisição

Não é necessário enviar um corpo (payload) na requisição para este endpoint.


Exemplo de resposta


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


Explicação dos campos da resposta

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






GET /api/certidoes (Postman)
Descrição

Este endpoint simula uma API de certidões que retorna uma lista de certidões para um dado CPF ou CNPJ. É uma API mockada para testes e demonstrações.

GET http://localhost:3000/api/certidoes?cpf_cnpj=00000000000

Parâmetros da Query

Parâmetro	Tipo	Descrição	Exemplo


cpf_cnpj	string	CPF ou CNPJ do credor	00000000000



Exemplo de resposta


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


###Explicação dos campos

cpf_cnpj: CPF ou CNPJ consultado.

certidoes: Lista de certidões retornadas pela API.

tipo: Tipo da certidão (ex.: federal, estadual, trabalhista).

status: Status atual da certidão (ex.: pendente, negativa).

conteudo_base64: Conteúdo ficticio criado para teste  da certidão codificado em Base64 (pode ser decodificado para obter o arquivo original, como PDF).





# Revalidação Automática de Certidões com Sidekiq e Redis


## Descrição do Job `RevalidarCertidoesJob`

O job `RevalidarCertidoesJob` automatiza a revalidação das certidões no sistema, buscando todas as certidões que precisam ser revalidadas (mais de 24 horas desde a última validação) e atualizando seu status e conteúdo via uma API mockada.


### Fluxo de funcionamento:
- Executado em background pelo Sidekiq.
- Busca as certidões para revalidação (`Certidao.para_revalidar`).
- Para cada certidão:
  - Chama o serviço externo mockado para revalidar.
  - Atualiza status e conteúdo da certidão.
  - Registra logs de sucesso ou erro.

---

## Configuração do Sidekiq com Cron e Redis

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


Como executar

Iniciar o Redis

Via terminal (Linux/Ubuntu):

sudo service redis-server start

Executar o Sidekiq

bundle exec sidekiq

Iniciar o servidor Rails

rails server
rails c RevalidarCertidoesJob.perform_now(para teste)

Acesse no navegador

http://localhost:3000/sidekiq


