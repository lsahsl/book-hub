class CreateCollections < ActiveRecord::Migration[7.2]
  def change
    create_table :collections do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :collections, :name, unique: true

    create_table :collection_items do |t|
      t.references :collection, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :item, null: false, foreign_key: { on_delete: :cascade }, index: false

      t.timestamps
    end

    add_index :collection_items, %i[collection_id item_id], unique: true
  end
end
