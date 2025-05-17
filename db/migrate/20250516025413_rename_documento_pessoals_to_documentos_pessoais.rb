class RenameDocumentoPessoalsToDocumentosPessoais < ActiveRecord::Migration[7.1]
  def change
    rename_table :documento_pessoals, :documentos_pessoais
  end
end
