class CreateDocumentoPessoals < ActiveRecord::Migration[7.1]
  def change
    create_table :documento_pessoals do |t|
      t.references :credor, null: false, foreign_key: true
      t.string :tipo
      t.string :arquivo_url
      t.datetime :enviado_em

      t.timestamps
    end
  end
end
