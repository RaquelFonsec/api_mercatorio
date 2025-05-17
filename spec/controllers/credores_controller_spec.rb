require 'rails_helper'

RSpec.describe CredoresController, type: :controller do
  let(:credor) { create(:credor) }
  let(:valid_attributes) {
    { nome: 'João da Silva', cpf_cnpj: '12345678900', email: 'joao@exemplo.com', telefone: '11987654321' }
  }

  # Testando a ação create
  describe 'POST #create' do
    context 'quando os parâmetros são válidos' do
      it 'cria um novo credor' do
        expect {
          post :create, params: { credor: valid_attributes }
        }.to change(Credor, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'quando os parâmetros são inválidos' do
      it 'não cria um novo credor' do
        invalid_attributes = { nome: '', cpf_cnpj: '123', email: 'invalidemail' }
        post :create, params: { credor: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # Testando a ação upload_documento
 # Testando a ação upload_documento
describe 'POST #upload_documento' do
context 'quando o arquivo é enviado com sucesso' do
  it 'faz o upload de um documento' do
    file = fixture_file_upload('documento.pdf', 'application/pdf')
    post :upload_documento, params: { id: credor.id, arquivo: file, tipo: 'identidade' }

    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body)['arquivo_url']).to include('/rails/active_storage/blobs/redirect/')
  end
end
end


  # Testando a ação buscar_certidoes_api
  describe 'POST #buscar_certidoes_api' do
    context 'quando o credor é encontrado' do
      it 'retorna as certidões mockadas' do
        post :buscar_certidoes_api, params: { id: credor.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Busca de certidões via API mockada concluída.')
      end
    end

    context 'quando o credor não é encontrado' do
      it 'retorna erro' do
        post :buscar_certidoes_api, params: { id: 999999 }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Credor não encontrado')
      end
    end
  end

  # Testando a ação upload_certidao_manual
  describe 'POST #upload_certidao_manual' do
  context 'quando o arquivo é enviado corretamente' do
    it 'faz o upload de uma certidão manual' do
      file = fixture_file_upload('certidao.pdf', 'application/pdf')  # Corrigido para o nome correto
      post :upload_certidao_manual, params: { id: credor.id, tipo: 'federal', arquivo: file }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['arquivo_url']).to include('http://test.host/rails/active_storage/blobs/redirect/')
    end
  end
end

  # Testando a ação show
  describe 'GET #show' do
    context 'quando o credor é encontrado' do
      it 'retorna as informações do credor' do
        get :show, params: { id: credor.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['credor']['nome']).to eq(credor.nome)
        expect(JSON.parse(response.body)['credor']['cpf_cnpj']).to eq(credor.cpf_cnpj)
      end
    end

    context 'quando o credor não é encontrado' do
      it 'retorna erro' do
        get :show, params: { id: 999999 }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Credor não encontrado')
      end
    end
  end
end
