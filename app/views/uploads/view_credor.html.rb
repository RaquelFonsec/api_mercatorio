<div class="row">
  <div class="col-md-12 mb-4">
    <h2 class="text-center">Dados do Credor</h2>
    <% if @credor_data %>
      <p class="text-center">
        <a href="/uploads/view_form" class="btn btn-outline-secondary">Voltar para Consulta</a>
      </p>
    <% end %>
  </div>
</div>

<% if @credor_data %>
  <!-- Dados do Credor -->
  <div class="row">
    <div class="col-md-6">
      <div class="card mb-4">
        <div class="card-header">
          Informações do Credor
        </div>
        <div class="card-body">
          <table class="table">
            <tr>
              <th>ID:</th>
              <td><%= @credor_data['credor']['id'] %></td>
            </tr>
            <tr>
              <th>Nome:</th>
              <td><%= @credor_data['credor']['nome'] %></td>
            </tr>
            <tr>
              <th>CPF/CNPJ:</th>
              <td><%= @credor_data['credor']['cpf_cnpj'] %></td>
            </tr>
            <tr>
              <th>Email:</th>
              <td><%= @credor_data['credor']['email'] %></td>
            </tr>
            <tr>
              <th>Telefone:</th>
              <td><%= @credor_data['credor']['telefone'] %></td>
            </tr>
            <tr>
              <th>Cadastrado em:</th>
              <td><%= DateTime.parse(@credor_data['credor']['created_at']).strftime('%d/%m/%Y %H:%M') %></td>
            </tr>
          </table>
        </div>
      </div>
    </div>
    
    <div class="col-md-6">
      <div class="card mb-4">
        <div class="card-header">
          Dados do Precatório
        </div>
        <div class="card-body">
          <% if @credor_data['precatorio'] %>
            <table class="table">
              <tr>
                <th>Número:</th>
                <td><%= @credor_data['precatorio']['numero_precatorio'] %></td>
              </tr>
              <tr>
                <th>Valor Nominal:</th>
                <td>R$ <%= number_with_precision(@credor_data['precatorio']['valor_nominal'].to_f, precision: 2, delimiter: '.', separator: ',') %></td>
              </tr>
              <tr>
                <th>Foro:</th>
                <td><%= @credor_data['precatorio']['foro'] %></td>
              </tr>
              <tr>
                <th>Data de Publicação:</th>
                <td><%= Date.parse(@credor_data['precatorio']['data_publicacao']).strftime('%d/%m/%Y') %></td>
              </tr>
            </table>
          <% else %>
            <p class="text-center">Nenhum precatório cadastrado para este credor.</p>
          <% end %>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Documentos Pessoais -->
  <div class="row">
    <div class="col-md-12">
      <div class="card mb-4">
        <div class="card-header">
          Documentos Pessoais
        </div>
        <div class="card-body">
          <% if @credor_data['documentos'] && @credor_data['documentos'].any? %>
            <div class="row">
              <% @credor_data['documentos'].each do |documento| %>
                <div class="col-md-4 mb-3">
                  <div class="document-card">
                    <h5><%= documento['tipo'] %></h5>
                    <p>Enviado em: <%= DateTime.parse(documento['enviado_em']).strftime('%d/%m/%Y %H:%M') %></p>
                    <% if documento['arquivo_url'] %>
                      <a href="http://localhost:3000<%= documento['arquivo_url'] %>" target="_blank" class="btn btn-sm btn-primary">Visualizar Documento</a>
                    <% else %>
                      <span class="badge bg-warning text-dark">Sem arquivo</span>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          <% else %>
            <p class="text-center">Nenhum documento pessoal cadastrado para este credor.</p>
          <% end %>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Certidões -->
  <div class="row">
    <div class="col-md-12">
      <div class="card mb-4">
        <div class="card-header">
          Certidões
        </div>
        <div class="card-body">
          <% if @credor_data['certidoes'] && @credor_data['certidoes'].any? %>
            <div class="row">
              <% @credor_data['certidoes'].each do |certidao| %>
                <div class="col-md-4 mb-3">
                  <div class="document-card">
                    <h5><%= certidao['tipo'].capitalize %></h5>
                    <p>
                      <span class="badge <%= certidao['status'] == 'negativa' ? 'bg-success' : (certidao['status'] == 'positiva' ? 'bg-danger' : 'bg-warning text-dark') %>">
                        <%= certidao['status'].capitalize %>
                      </span>
                      <span class="badge bg-info text-dark">
                        <%= certidao['origem'].capitalize %>
                      </span>
                    </p>
                    <p>Recebida em: <%= DateTime.parse(certidao['recebida_em']).strftime('%d/%m/%Y %H:%M') %></p>
                    <% if certidao['arquivo_url'] %>
                      <a href="http://localhost:3000<%= certidao['arquivo_url'] %>" target="_blank" class="btn btn-sm btn-primary">Visualizar Certidão</a>
                    <% else %>
                      <span class="badge bg-warning text-dark">Sem arquivo</span>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          <% else %>
            <p class="text-center">Nenhuma certidão cadastrada para este credor.</p>
          <% end %>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Ações -->
  <div class="row">
    <div class="col-md-12 text-center mb-4">
      <a href="/uploads/upload_form" class="btn btn-success">Enviar Novos Documentos</a>
      <a href="/uploads/buscar_certidoes?credor_id=<%= @credor_data['credor']['id'] %>" 
         class="btn btn-primary"
         data-method="post"
         data-confirm="Deseja buscar certidões automaticamente para este credor?">
        Buscar Certidões via API
      </a>
      <a href="/uploads/view_form" class="btn btn-outline-secondary">Voltar para Consulta</a>
    </div>
  </div>
<% end %>