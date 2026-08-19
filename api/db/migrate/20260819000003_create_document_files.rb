class CreateDocumentFiles < ActiveRecord::Migration[7.2]
  def change
    create_table :document_files do |t|
      t.references :item, null: false, foreign_key: { on_delete: :cascade }
      t.string :storage_key, null: false
      t.string :sha256, null: false
      t.string :mime_type, null: false
      t.bigint :size_bytes, null: false, default: 0
      t.string :original_filename, null: false

      t.timestamps
    end

    add_index :document_files, :storage_key, unique: true
    add_check_constraint :document_files, "size_bytes >= 0",
                         name: "document_files_size_bytes_check"
  end
end
