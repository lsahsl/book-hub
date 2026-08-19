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

ActiveRecord::Schema[7.2].define(version: 2026_08_19_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collection_items", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id", "item_id"], name: "index_collection_items_on_collection_id_and_item_id", unique: true
  end

  create_table "collections", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_collections_on_name", unique: true
  end

  create_table "document_files", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.string "storage_key", null: false
    t.string "sha256", null: false
    t.string "mime_type", null: false
    t.bigint "size_bytes", default: 0, null: false
    t.string "original_filename", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_document_files_on_item_id"
    t.index ["storage_key"], name: "index_document_files_on_storage_key", unique: true
    t.check_constraint "size_bytes >= 0", name: "document_files_size_bytes_check"
  end

  create_table "item_tags", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "tag_id"], name: "index_item_tags_on_item_id_and_tag_id", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.string "title", null: false
    t.text "authors", default: [], null: false, array: true
    t.string "isbn"
    t.string "publisher"
    t.integer "year"
    t.string "language"
    t.string "genre"
    t.text "description"
    t.integer "page_count"
    t.jsonb "identifiers", default: {}, null: false
    t.string "kind", default: "book", null: false
    t.string "source", default: "born_digital", null: false
    t.string "metadata_status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "kind::text = ANY (ARRAY['book'::character varying, 'magazine'::character varying, 'manual'::character varying, 'document'::character varying, 'scan'::character varying, 'image'::character varying]::text[])", name: "items_kind_check"
    t.check_constraint "metadata_status::text = ANY (ARRAY['pending'::character varying, 'needs_review'::character varying, 'reviewed'::character varying]::text[])", name: "items_metadata_status_check"
    t.check_constraint "page_count IS NULL OR page_count > 0", name: "items_page_count_check"
    t.check_constraint "source::text = ANY (ARRAY['born_digital'::character varying, 'physical_scan'::character varying]::text[])", name: "items_source_check"
    t.check_constraint "year IS NULL OR year >= 1000 AND year <= 2100", name: "items_year_check"
  end

  create_table "processing_jobs", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.string "status", default: "pending", null: false
    t.string "error_message"
    t.jsonb "error_details"
    t.jsonb "extraction"
    t.jsonb "confidence"
    t.jsonb "warnings", default: [], null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_processing_jobs_on_item_id", unique: true
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'processing'::character varying, 'completed'::character varying, 'failed'::character varying]::text[])", name: "processing_jobs_status_check"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "collection_items", "collections", on_delete: :cascade
  add_foreign_key "collection_items", "items", on_delete: :cascade
  add_foreign_key "document_files", "items", on_delete: :cascade
  add_foreign_key "item_tags", "items", on_delete: :cascade
  add_foreign_key "item_tags", "tags", on_delete: :cascade
  add_foreign_key "processing_jobs", "items", on_delete: :cascade
end
