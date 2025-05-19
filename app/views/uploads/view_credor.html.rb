<div class="row">
  <div class="col-md-12 mb-4">
    <h2 class="text-center">Dados do Credor</h2>
    <p class="text-center">
      <a href="/uploads/view_form" class="btn btn-outline-secondary">Voltar para Consulta</a>
    </p>
  </div>
</div>

<% if @credor_data %>
  <!-- Dados do Credor -->
  <div class="row">
    <div class="col-md-6">
      <div class="card mb-4">
        <div class="card-header">Informações do Credor</div>
        <div class="card-body">
          <table class="table">
            <tr><th>ID:</th><td><%= @credor_data['credor']['id'] %></td></tr>
            <tr><th>Nome:</th><td><%= @credor_data['credor']['nome'] %></td></tr>
            <tr><th>CPF/CNPJ:</th><td><%= @credor_data['credor']['cpf_cnpj'] %></td></tr>
            <tr><th>Email:</th><td><%= @credor_data['credor']['email'] %></td></tr>
            <tr><th>Telefone:</th><td><%= @credor_data['credor']['telefone'] %></td></tr>
          </table>
        </div>
      </div>
    </div>

    <!-- Precatório -->
    <div class="col-md-6">
      <div class="card mb-4">
        <div class="card-header">Dados do Precatório</div>
        <div class="card-body">
          <% if @credor_data['precatorio'] %>
            <table class="table">
              <tr><th>Número:</th><td><%= @credor_data['precatorio']['numero_precatorio'] %></td></tr>
              <tr><th>Valor Nominal:</th><td>R$ <%= @credor_data['precatorio']['valor_nominal'] %></td></tr>
              <tr><th>Foro:</th><td><%= @credor_data['precatorio']['foro'] %></td></tr>
            </table>
          <% else %>
            <p>Nenhum precatório cadastrado para este credor.</p>
          <% end %>
        </div>
      </div>
    </div>
  </div>

  <!-- Documentos Pessoais -->
  <div class="row">
    <div class="col-md-12">
      <div class="card mb-4">
        <div class="card-header">Documentos Pessoais</div>
        <div class="card-body">
          <% if @credor_data['documentos'].any? %>
            <div class="row">
              <% @credor_data['documentos'].each do |documento| %>
                <div class="col-md-4 mb-3">
                  <h5><%= documento['tipo'] %></h5>
                  <p>Enviado em: <%= documento['enviado_em'] %></p>
                  <% if documento['arquivo_url'] %>
                    <a href="<%= documento['arquivo_url'] %>" target="_blank" class="btn btn-sm btn-primary">Visualizar Documento</a>
                  <% else %>
                    <span>Sem arquivo</span>
                  <% end %>
                </div>
              <% end %>
            </div>
          <% else %>
            <p>Nenhum documento pessoal cadastrado.</p>
          <% end %>
        </div>
      </div>
    </div>
  </div>

  <!-- Certidões -->
  <div class="row">
    <div class="col-md-12">
      <div class="card mb-4">
        <div class="card-header">Certidões</div>
        <div class="card-body">
          <% if @credor_data['certidoes'].any? %>
            <div class="row">
              <% @credor_data['certidoes'].each do |certidao| %>
                <div class="col-md-4 mb-3">
                  <h5><%= certidao['tipo'] %></h5>
                  <p>Status: <%= certidao['status'] %></p>
                  <% if certidao['arquivo_url'] %>
                    <a href="<%= certidao['arquivo_url'] %>" target="_blank" class="btn btn-sm btn-primary">Visualizar Certidão</a>
                  <% else %>
                    <span>Sem arquivo</span>
                  <% end %>
                </div>
              <% end %>
            </div>
          <% else %>
            <p>Nenhuma certidão cadastrada.</p>
          <% end %>
        </div>
      </div>
    </div>
  </div>

  <!-- Ações -->
  <div class="row">
    <div class="col-md-12 text-center">
      <a href="/uploads/upload_form" class="btn btn-success">Enviar Documentos</a>
      <a href="/uploads/view_form" class="btn btn-secondary">Voltar</a>
    </div>
  </div>

<% else %>
  <p class="text-center">Nenhum credor encontrado.</p>
<% end %>
