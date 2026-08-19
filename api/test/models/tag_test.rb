require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "name required" do
    assert_not Tag.new(name: "").valid?
  end

  test "name unique" do
    Tag.create!(name: "fantasy")
    assert_not Tag.new(name: "fantasy").valid?
  end

  test "items through item_tags" do
    item = Item.create!(title: "The Hobbit")
    tag = Tag.create!(name: "fantasy")
    tag.items << item
    assert_equal [ item ], tag.items
    assert tag.item_tags.exists?(item: item)
  end

  test "duplicate tag on item rejected" do
    item = Item.create!(title: "The Hobbit")
    tag = Tag.create!(name: "fantasy")
    tag.items << item
    assert_not tag.item_tags.new(item: item).valid?
  end
end
