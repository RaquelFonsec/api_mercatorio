<div class="row">
  <div class="col-md-12 mb-4">
    <h2 class="text-center">Upload de Documentos e Certidões</h2>
  </div>
</div>

<div class="row">
  <!-- Formulário para cadastro de credor -->
  <div class="col-md-6">
    <div class="card">
      <div class="card-header">
        Cadastrar Novo Credor
      </div>
      <div class="card-body">
        <%= form_with url: '/uploads/create_credor', method: :post, local: true do |form| %>
          <div class="mb-3">
            <label class="form-label">Nome Completo</label>
            <%= form.text_field :nome, class: 'form-control', required: true %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">CPF/CNPJ</label>
            <%= form.text_field :cpf_cnpj, class: 'form-control', required: true %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">Email</label>
            <%= form.email_field :email, class: 'form-control', required: true %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">Telefone</label>
            <%= form.telephone_field :telefone, class: 'form-control', required: true %>
          </div>
          
          <h5 class="mt-4">Dados do Precatório</h5>
          
          <div class="mb-3">
            <label class="form-label">Número do Precatório</label>
            <%= form.text_field :numero_precatorio, class: 'form-control', required: true %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">Valor Nominal</label>
            <%= form.number_field :valor_nominal, step: '0.01', class: 'form-control', required: true %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">Foro</label>
            <%= form.text_field :foro, class: 'form-control', required: true %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">Data de Publicação</label>
            <%= form.date_field :data_publicacao, class: 'form-control', required: true %>
          </div>
          
          <div class="d-grid">
            <%= form.submit 'Cadastrar Credor', class: 'btn btn-primary' %>
          </div>
        <% end %>
      </div>
    </div>
  </div>
  
  <!-- Formulários para upload de documentos e certidões -->
  <div class="col-md-6">
    <!-- Upload de Documento Pessoal -->
    <div class="card mb-4">
      <div class="card-header">
        Upload de Documento Pessoal
      </div>
      <div class="card-body">
        <%= form_with url: '/uploads/upload_documento', method: :post, multipart: true, local: true do |form| %>
          <div class="mb-3">
            <label class="form-label">ID do Credor</label>
            <%= form.number_field :credor_id, class: 'form-control', required: true %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">Tipo de Documento</label>
            <%= form.select :tipo, 
              [
                ['RG', 'RG'], 
                ['CPF', 'CPF'], 
                ['Comprovante de Residência', 'comprovante_residencia'],
                ['Outro', 'outro']
              ], 
              {}, 
              { class: 'form-select', required: true } 
            %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">Arquivo (JPEG, PNG ou PDF, máx. 5MB)</label>
            <%= form.file_field :arquivo, class: 'form-control', required: true, accept: 'image/jpeg,image/png,application/pdf' %>
          </div>
          
          <div class="d-grid">
            <%= form.submit 'Enviar Documento', class: 'btn btn-success' %>
          </div>
        <% end %>
      </div>
    </div>
    
    <!-- Upload de Certidão -->
    <div class="card">
      <div class="card-header">
        Upload de Certidão
      </div>
      <div class="card-body">
        <%= form_with url: '/uploads/upload_certidao', method: :post, multipart: true, local: true do |form| %>
          <div class="mb-3">
            <label class="form-label">ID do Credor</label>
            <%= form.number_field :credor_id, class: 'form-control', required: true %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">Tipo de Certidão</label>
            <%= form.select :tipo, 
              [
                ['Federal', 'federal'], 
                ['Estadual', 'estadual'], 
                ['Municipal', 'municipal'],
                ['Trabalhista', 'trabalhista'],
                ['Outro', 'outro']
              ], 
              {}, 
              { class: 'form-select', required: true } 
            %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">Status</label>
            <%= form.select :status, 
              [
                ['Pendente', 'pendente'], 
                ['Positiva', 'positiva'], 
                ['Negativa', 'negativa']
              ], 
              {}, 
              { class: 'form-select', required: true } 
            %>
          </div>
          
          <div class="mb-3">
            <label class="form-label">Arquivo (JPEG, PNG ou PDF, máx. 5MB)</label>
            <%= form.file_field :arquivo, class: 'form-control', required: true, accept: 'image/jpeg,image/png,application/pdf' %>
          </div>
          
          <div class="d-grid">
            <%= form.submit 'Enviar Certidão', class: 'btn btn-success' %>
          </div>
        <% end %>
      </div>
    </div>
  </div>
</div>

<div class="row mt-4">
  <div class="col-md-12">
    <div class="card">
      <div class="card-header">
        Buscar Certidões via API
      </div>
      <div class="card-body">
        <p>Use esta opção para buscar certidões automaticamente para um credor já cadastrado.</p>
        
        <%= form_with url: '/uploads/buscar_certidoes', method: :post, local: true do |form| %>
          <div class="mb-3">
            <label class="form-label">ID do Credor</label>
            <%= form.number_field :credor_id, class: 'form-control', required: true %>
          </div>
          
          <div class="d-grid">
            <%= form.submit 'Buscar Certidões', class: 'btn btn-primary' %>
          </div>
        <% end %>
      </div>
    </div>
  </div>
</div>

<div class="row mt-4">
  <div class="col-md-12 text-center">
    <a href="/uploads/view_form" class="btn btn-outline-primary">Ir para Visualização</a>
    <a href="/" class="btn btn-outline-secondary">Voltar para Início</a>
  </div>
</div>