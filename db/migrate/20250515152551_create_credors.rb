class CreateCredors < ActiveRecord::Migration[7.1]
  def change
    create_table :credors do |t|
      t.string :nome
      t.string :cpf_cnpj
      t.string :email
      t.string :telefone

      t.timestamps
    end
    add_index :credors, :cpf_cnpj, unique: true
  end
end
