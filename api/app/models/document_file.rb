class DocumentFile < ApplicationRecord
  self.table_name = "document_files"

  belongs_to :item

  validates :storage_key, presence: true, uniqueness: true,
                          format: { with: %r{\A[0-9a-f]{2}/[0-9a-f]{64}\z} }
  validates :sha256, presence: true, format: { with: /\A[0-9a-f]{64}\z/ }
  validates :mime_type, presence: true
  validates :size_bytes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :original_filename, presence: true
end
