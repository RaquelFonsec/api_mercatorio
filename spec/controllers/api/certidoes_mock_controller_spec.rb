require 'rails_helper'

RSpec.describe Api::CertidoesMockController, type: :controller do
  describe "GET #buscar_certidoes_api" do
    let!(:credor) { create(:credor, cpf_cnpj: "12345678900") }

    context "quando o credor existe" do
      before do
        get :buscar_certidoes_api, params: { cpf_cnpj: credor.cpf_cnpj }
      end

      it "retorna status 200 (ok)" do
        expect(response).to have_http_status(:ok)
      end

      it "retorna as certidões no JSON" do
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Busca de certidões via API mockada concluída.")
        expect(json["certidoes_recebidas"]).to be_an(Array)
        expect(json["certidoes_recebidas"].length).to eq(2)

        primeira_certidao = json["certidoes_recebidas"].first
        expect(primeira_certidao["tipo"]).to eq("federal")
        expect(primeira_certidao["status"]).to eq("negativa")
        expect(primeira_certidao["conteudo_base64"]).to be_present
      end

      it "cria certidões no banco para o credor" do
        expect(Certidao.where(credor_id: credor.id).count).to eq(2)
      end
    end

    context "quando o credor não existe" do
      before do
        get :buscar_certidoes_api, params: { cpf_cnpj: "00000000000" }
      end

      it "retorna status 404 (not_found)" do
        expect(response).to have_http_status(:not_found)
      end

      it "retorna mensagem de erro no JSON" do
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Credor não encontrado")
      end
    end

    context "quando ocorre um erro inesperado" do
      before do
        allow(Credor).to receive(:find_by).and_raise(StandardError.new("Erro inesperado"))
        get :buscar_certidoes_api, params: { cpf_cnpj: credor.cpf_cnpj }
      end

      it "retorna status 500 (internal_server_error)" do
        expect(response).to have_http_status(:internal_server_error)
      end

      it "retorna mensagem de erro no JSON" do
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Erro inesperado")
      end
    end
  end
end
