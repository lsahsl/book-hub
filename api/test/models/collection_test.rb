require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  test "name required" do
    assert_not Collection.new(name: "").valid?
  end

  test "name unique" do
    Collection.create!(name: "Sci-Fi")
    assert_not Collection.new(name: "Sci-Fi").valid?
  end

  test "items through collection_items" do
    item = Item.create!(title: "Dune")
    coll = Collection.create!(name: "Sci-Fi")
    coll.items << item
    assert_equal [ item ], coll.items
    assert coll.collection_items.exists?(item: item)
  end

  test "duplicate item in collection rejected" do
    item = Item.create!(title: "Dune")
    coll = Collection.create!(name: "Sci-Fi")
    coll.items << item
    assert_not coll.collection_items.new(item: item).valid?
  end
end
