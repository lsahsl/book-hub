class CreateTags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :tags, :name, unique: true

    create_table :item_tags do |t|
      t.references :item, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :tag, null: false, foreign_key: { on_delete: :cascade }, index: false

      t.timestamps
    end

    add_index :item_tags, %i[item_id tag_id], unique: true
  end
end
