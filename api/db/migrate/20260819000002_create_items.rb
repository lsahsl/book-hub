class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.string :title, null: false
      t.text :authors, array: true, default: [], null: false
      t.string :isbn
      t.string :publisher
      t.integer :year
      t.string :language
      t.string :genre
      t.text :description
      t.integer :page_count
      t.jsonb :identifiers, default: {}, null: false
      t.string :kind, null: false, default: "book"
      t.string :source, null: false, default: "born_digital"
      t.string :metadata_status, null: false, default: "pending"

      t.timestamps
    end

    add_check_constraint :items, "kind IN ('book','magazine','manual','document','scan','image')",
                         name: "items_kind_check"
    add_check_constraint :items, "source IN ('born_digital','physical_scan')",
                         name: "items_source_check"
    add_check_constraint :items, "metadata_status IN ('pending','needs_review','reviewed')",
                         name: "items_metadata_status_check"
    add_check_constraint :items, "page_count IS NULL OR page_count > 0",
                         name: "items_page_count_check"
    add_check_constraint :items, "year IS NULL OR year BETWEEN 1000 AND 2100",
                         name: "items_year_check"
  end
end
