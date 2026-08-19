class ProcessingJob < ApplicationRecord
  enum :status, { pending: "pending", processing: "processing",
                  completed: "completed", failed: "failed" }

  belongs_to :item

  validates :status, presence: true
  validates :item_id, uniqueness: true
  validate :timestamps_ordered

  private

  def timestamps_ordered
    return if started_at.nil? || completed_at.nil?

    errors.add(:completed_at, "must be after started_at") if completed_at < started_at
  end
end
