class Item < ApplicationRecord
  enum :kind, { book: "book", magazine: "magazine", manual: "manual",
                document: "document", scan: "scan", image: "image" }
  enum :source, { born_digital: "born_digital", physical_scan: "physical_scan" }
  enum :metadata_status, { pending: "pending", needs_review: "needs_review",
                           reviewed: "reviewed" }

  has_many :document_files, dependent: :destroy
  has_one :processing_job, dependent: :destroy
  has_many :collection_items, dependent: :destroy
  has_many :collections, through: :collection_items
  has_many :item_tags, dependent: :destroy
  has_many :tags, through: :item_tags

  validates :title, presence: true
  validates :kind, :source, :metadata_status, presence: true
  validates :year, numericality: { only_integer: true,
                                   greater_than_or_equal_to: 1000,
                                   less_than_or_equal_to: 2100 }, allow_nil: true
  validates :page_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :authors_must_be_array_of_strings
  validate :identifiers_must_be_hash

  private

  def authors_must_be_array_of_strings
    return if authors.nil?

    unless authors.is_a?(Array) && authors.all? { |a| a.is_a?(String) }
      errors.add(:authors, "must be an array of strings")
    end
  end

  def identifiers_must_be_hash
    return if identifiers.nil?

    errors.add(:identifiers, "must be a hash") unless identifiers.is_a?(Hash)
  end
end
