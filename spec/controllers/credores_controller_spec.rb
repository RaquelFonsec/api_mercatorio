require 'rails_helper'

RSpec.describe CredoresController, type: :controller do
  let!(:credor) { create(:credor) }
  let(:valid_attributes) do
    { nome: 'João da Silva', cpf_cnpj: '12345678900', email: 'joao@exemplo.com', telefone: '11987654321' }
  end

  let(:invalid_attributes) do
    { nome: '', cpf_cnpj: '123', email: 'invalidemail' }
  end

  describe 'POST #create' do
    context 'com parâmetros válidos' do
      it 'cria um novo credor' do
        expect {
          post :create, params: { credor: valid_attributes }
        }.to change(Credor, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['nome']).to eq('João da Silva')
      end

      it 'atualiza um credor existente pelo cpf_cnpj' do
        existing = create(:credor, cpf_cnpj: '12345678900', nome: 'Antigo Nome')
        post :create, params: { credor: valid_attributes }
        existing.reload
        expect(existing.nome).to eq('João da Silva')
      end
    end

    context 'com parâmetros inválidos' do
      it 'não cria o credor e retorna erro' do
        post :create, params: { credor: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to be_present
      end
    end
  end

  describe 'GET #show' do
    context 'quando o credor existe' do
      it 'retorna o credor com documentos e certidões' do
        get :show, params: { id: credor.id }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['credor']['id']).to eq(credor.id)
        expect(json['documentos']).to be_an(Array)
        expect(json['certidoes']).to be_an(Array)
      end
    end

    context 'quando o credor não existe' do
      it 'retorna erro 404' do
        get :show, params: { id: 999999 }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Credor não encontrado')
      end
    end
  end

  describe 'POST #upload_documento' do
  let(:arquivo) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_document.pdf'), 'application/pdf') }
    context 'com arquivo e tipo válido' do
      it 'faz upload do documento' do
        post :upload_documento, params: { id: credor.id, tipo: 'rg', arquivo: arquivo }
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['tipo']).to eq('rg')
        expect(json['arquivo_url']).to be_present
      end
    end

    context 'sem arquivo' do
      it 'retorna erro' do
        post :upload_documento, params: { id: credor.id, tipo: 'rg' }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Arquivo não encontrado.')
      end
    end

    context 'credor não encontrado' do
      it 'retorna erro 404' do
        post :upload_documento, params: { id: 999999, tipo: 'rg', arquivo: arquivo }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Credor não encontrado')
      end
    end
  end
end
