# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_05_17_173819) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "certidaos", force: :cascade do |t|
    t.bigint "credor_id", null: false
    t.integer "tipo"
    t.integer "origem"
    t.string "arquivo_url"
    t.text "conteudo_base64"
    t.integer "status"
    t.datetime "recebida_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credor_id"], name: "index_certidaos_on_credor_id"
  end

  create_table "credors", force: :cascade do |t|
    t.string "nome"
    t.string "cpf_cnpj"
    t.string "email"
    t.string "telefone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf_cnpj"], name: "index_credors_on_cpf_cnpj", unique: true
  end

  create_table "documento_pessoals", force: :cascade do |t|
    t.bigint "credor_id", null: false
    t.string "tipo"
    t.string "arquivo_url"
    t.datetime "enviado_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credor_id"], name: "index_documento_pessoals_on_credor_id"
  end

  create_table "precatorios", force: :cascade do |t|
    t.bigint "credor_id", null: false
    t.string "numero_precatorio"
    t.decimal "valor_nominal"
    t.string "foro"
    t.date "data_publicacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credor_id"], name: "index_precatorios_on_credor_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "certidaos", "credors"
  add_foreign_key "documento_pessoals", "credors"
  add_foreign_key "precatorios", "credors"
end
