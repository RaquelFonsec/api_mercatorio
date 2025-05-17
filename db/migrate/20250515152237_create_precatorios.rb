class CreatePrecatorios < ActiveRecord::Migration[7.1]
  def change
    create_table :precatorios do |t|
      t.references :credor, null: false, foreign_key: true
      t.string :numero_precatorio
      t.decimal :valor_nominal
      t.string :foro
      t.date :data_publicacao

      t.timestamps
    end
  end
end
