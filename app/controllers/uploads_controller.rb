class UploadsController < ApplicationController
  

  # Exibe a lista de todos os credores com associações
  def lista_credores
    @credores = Credor.all.includes(:documentos_pessoais, :certidoes, :precatorio)
    render :lista_credores
  end


  def index
    render :index
  end

  def upload_form
    render :upload_form
  end

  def view_form
    @credores = Credor.includes(:documentos_pessoais, :certidoes, :precatorio).all
  
    if params[:credor_id].present?
      @credor = @credores.find { |c| c.id == params[:credor_id].to_i }
      flash.now[:error] = "Credor não encontrado." unless @credor
    end
  
    render :view_form
  end
  
  def upload_documento
    credor_id = params[:credor_id]
    tipo = params[:tipo]
    arquivo = params[:arquivo]

    if credor_id.blank? || tipo.blank? || arquivo.blank?
      flash[:error] = "Todos os campos são obrigatórios"
      return redirect_to upload_form_path
    end

    unless ['image/jpeg', 'image/png', 'application/pdf'].include?(arquivo.content_type)
      flash[:error] = "Formato de arquivo inválido. Apenas JPEG, PNG e PDF são permitidos."
      return redirect_to upload_form_path
    end

    if arquivo.size > 5.megabytes
      flash[:error] = "Tamanho máximo de arquivo é 5MB"
      return redirect_to upload_form_path
    end

    begin
      credor = Credor.find(credor_id)
      documento = credor.documentos_pessoais.build(tipo: tipo)
      documento.arquivo.attach(arquivo) # ActiveStorage

      if documento.save
        flash[:success] = "Documento enviado com sucesso!"
        redirect_to view_form_path(credor_id: credor_id)
      else
        flash[:error] = "Erro ao salvar documento: #{documento.errors.full_messages.join(', ')}"
        redirect_to upload_form_path
      end

    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Credor não encontrado"
      redirect_to upload_form_path
    rescue => e
      flash[:error] = "Erro ao salvar documento: #{e.message}"
      redirect_to upload_form_path
    end
  end

  def upload_certidao
    credor_id = params[:credor_id]
    tipo = params[:tipo]
    origem = params[:origem] || "manual"
    status = params[:status] || "pendente"
    arquivo = params[:arquivo]

    if credor_id.blank? || tipo.blank? || arquivo.blank?
      flash[:error] = "Todos os campos são obrigatórios"
      return redirect_to upload_form_path
    end

    unless ['image/jpeg', 'image/png', 'application/pdf'].include?(arquivo.content_type)
      flash[:error] = "Formato de arquivo inválido. Apenas JPEG, PNG e PDF são permitidos."
      return redirect_to upload_form_path
    end

    if arquivo.size > 5.megabytes
      flash[:error] = "Tamanho máximo de arquivo é 5MB"
      return redirect_to upload_form_path
    end

    begin
      credor = Credor.find(credor_id)

      certidao = credor.certidoes.build(
        tipo: tipo,
        origem: origem,
        status: status,
        recebida_em: Time.current
      )
      certidao.arquivo.attach(arquivo) # ActiveStorage

      if certidao.save
        flash[:success] = "Certidão enviada com sucesso!"
        redirect_to view_form_path(credor_id: credor_id)
      else
        flash[:error] = "Erro ao salvar certidão: #{certidao.errors.full_messages.join(', ')}"
        redirect_to upload_form_path
      end

    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Credor não encontrado"
      redirect_to upload_form_path
    rescue => e
      flash[:error] = "Erro ao salvar certidão: #{e.message}"
      redirect_to upload_form_path
    end
  end

  def buscar_certidoes
    credor_id = params[:credor_id]

    if credor_id.blank?
      flash[:error] = "ID do credor é obrigatório"
      return redirect_to view_form_path
    end

    begin
      credor = Credor.find(credor_id)

      if credor.respond_to?(:buscar_certidoes_externas!) && credor.buscar_certidoes_externas!
        flash[:success] = "Certidões buscadas com sucesso!"
      else
        flash[:error] = "Erro ao buscar certidões."
      end
      redirect_to view_form_path(credor_id: credor_id)

    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Credor não encontrado"
      redirect_to view_form_path
    rescue => e
      flash[:error] = "Erro ao buscar certidões: #{e.message}"
      redirect_to view_form_path
    end
  end

  def view_credor
    credor_id = params[:credor_id]

    if credor_id.blank?
      flash[:error] = "ID do credor é obrigatório"
      return redirect_to view_form_path
    end

    begin
      @credor = Credor.includes(:documentos_pessoais, :certidoes, :precatorio).find(credor_id)
      render :view_credor
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Credor não encontrado"
      redirect_to view_form_path
    rescue => e
      flash[:error] = "Erro ao buscar dados do credor: #{e.message}"
      redirect_to view_form_path
    end
  end

  def create_credor
    nome = params[:nome]
    cpf_cnpj = params[:cpf_cnpj]
    email = params[:email]
    telefone = params[:telefone]
    numero_precatorio = params[:numero_precatorio]
    valor_nominal = params[:valor_nominal]
    foro = params[:foro]
    data_publicacao = params[:data_publicacao]

    if nome.blank? || cpf_cnpj.blank? || email.blank? || telefone.blank? ||
       numero_precatorio.blank? || valor_nominal.blank? || foro.blank? || data_publicacao.blank?
      flash[:error] = "Todos os campos são obrigatórios"
      return redirect_to upload_form_path
    end

    begin
      credor = Credor.new(
        nome: nome,
        cpf_cnpj: cpf_cnpj,
        email: email,
        telefone: telefone
      )

      precatorio = credor.build_precatorio(
        numero_precatorio: numero_precatorio,
        valor_nominal: valor_nominal.to_f,
        foro: foro,
        data_publicacao: data_publicacao
      )

      if credor.save
        flash[:success] = "Credor criado com sucesso! ID: #{credor.id}"
        redirect_to view_form_path(credor_id: credor.id)
      else
        flash[:error] = "Erro ao criar credor: #{credor.errors.full_messages.join(', ')}"
        redirect_to upload_form_path
      end

    rescue => e
      flash[:error] = "Erro ao criar credor: #{e.message}"
      redirect_to upload_form_path
    end
  end
end
