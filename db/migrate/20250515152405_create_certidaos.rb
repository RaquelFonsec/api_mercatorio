class CreateCertidaos < ActiveRecord::Migration[7.1]
  def change
    create_table :certidaos do |t|
      t.references :credor, null: false, foreign_key: true
      t.string :tipo
      t.string :origem
      t.string :arquivo_url
      t.text :conteudo_base64
      t.string :status
      t.datetime :recebida_em

      t.timestamps
    end
  end
end
