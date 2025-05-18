require 'rails_helper'

RSpec.describe CertidoesUploadsController, type: :controller do
  let!(:credor) { create(:credor) }

  let(:valid_file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_document.pdf'), 'application/pdf') }
  let(:valid_base64) { Base64.encode64(File.read(Rails.root.join('spec', 'fixtures', 'files', 'test_document.pdf'))) }
  let(:tipo_valido) { 'federal' }  # <-- tipo válido do enum Certidao

  describe 'POST #upload_certidao_manual' do
    context 'quando credor não existe' do
      it 'retorna 404' do
        post :upload_certidao_manual, params: { id: 9999, tipo: tipo_valido, arquivo: valid_file }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Credor não encontrado')
      end
    end

    context 'quando tipo é inválido' do
      it 'retorna erro 422' do
        post :upload_certidao_manual, params: { id: credor.id, tipo: 'tipo_invalido', arquivo: valid_file }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Tipo inválido')
      end
    end

    context 'quando arquivo está presente' do
      it 'faz upload e retorna criado' do
        post :upload_certidao_manual, params: { id: credor.id, tipo: tipo_valido, arquivo: valid_file }
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['tipo']).to eq(tipo_valido)
        expect(json['arquivo_url']).to be_present
      end
    end

    context 'quando conteudo_base64 está presente' do
      it 'faz upload e retorna criado' do
        post :upload_certidao_manual, params: { id: credor.id, tipo: tipo_valido, conteudo_base64: valid_base64 }
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['tipo']).to eq(tipo_valido)
        expect(json['arquivo_url']).to be_present
      end
    end

    context 'quando nem arquivo nem conteudo_base64 estão presentes' do
      it 'retorna erro 422' do
        post :upload_certidao_manual, params: { id: credor.id, tipo: tipo_valido }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('É necessário fornecer um arquivo ou conteúdo base64')
      end
    end

    context 'quando conteúdo base64 está inválido' do
      it 'retorna erro 422' do
        post :upload_certidao_manual, params: { id: credor.id, tipo: tipo_valido, conteudo_base64: 'inválido' }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Conteúdo Base64 não é um PDF válido')
      end
    end
  end
end
