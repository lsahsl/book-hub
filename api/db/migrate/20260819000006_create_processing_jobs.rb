class CreateProcessingJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :processing_jobs do |t|
      t.references :item, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.string :status, null: false, default: "pending"
      t.string :error_message
      t.jsonb :error_details
      t.jsonb :extraction
      t.jsonb :confidence
      t.jsonb :warnings, default: [], null: false
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :processing_jobs, :item_id, unique: true
    add_check_constraint :processing_jobs, "status IN ('pending','processing','completed','failed')",
                         name: "processing_jobs_status_check"
  end
end
