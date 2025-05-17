class ChangeCertidaosTipoOrigemStatusToInteger < ActiveRecord::Migration[7.1]
  def up
    # Alterando 'tipo' para integer com valores definidos
    change_column :certidaos, :tipo, :integer, using: "CASE tipo WHEN 'federal' THEN 0 WHEN 'estadual' THEN 1 WHEN 'municipal' THEN 2 WHEN 'trabalhista' THEN 3 ELSE 0 END"
    
    # Alterando 'origem' para integer com valores definidos
    change_column :certidaos, :origem, :integer, using: "CASE origem WHEN 'manual' THEN 0 WHEN 'api' THEN 1 ELSE 0 END"
    
    # Alterando 'status' para integer com valores definidos
    change_column :certidaos, :status, :integer, using: "CASE status WHEN 'pendente' THEN 0 WHEN 'negativa' THEN 1 WHEN 'positiva' THEN 2 WHEN 'invalida' THEN 3 ELSE 0 END"
  rescue ActiveRecord::StatementInvalid
    # Caso ocorra erro (dados inválidos), atribui 0 como valor padrão
    change_column :certidaos, :tipo, :integer, using: "0"
    change_column :certidaos, :origem, :integer, using: "0"
    change_column :certidaos, :status, :integer, using: "0"
  end

  def down
    # Revertendo para string caso precise desfazer a migração
    change_column :certidaos, :tipo, :string
    change_column :certidaos, :origem, :string
    change_column :certidaos, :status, :string
  end
end
