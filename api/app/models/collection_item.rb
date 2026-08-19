class CollectionItem < ApplicationRecord
  belongs_to :collection
  belongs_to :item

  validates :collection_id, uniqueness: { scope: :item_id }
end
