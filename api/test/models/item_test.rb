require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "valid item with defaults" do
    item = Item.new(title: "The Hobbit")
    assert item.valid?
    assert_equal "book", item.kind
    assert_equal "born_digital", item.source
    assert_equal "pending", item.metadata_status
  end

  test "title required" do
    assert_not Item.new(title: "").valid?
  end

  test "invalid kind rejected" do
    assert_raises(ArgumentError) { Item.new(title: "x", kind: :invalid) }
  end

  test "year bounds" do
    assert_not Item.new(title: "x", year: 999).valid?
    assert_not Item.new(title: "x", year: 2101).valid?
    assert Item.new(title: "x", year: 2020).valid?
  end

  test "page_count must be positive" do
    assert_not Item.new(title: "x", page_count: 0).valid?
    assert Item.new(title: "x", page_count: 1).valid?
  end

  test "authors must be array of strings" do
    assert Item.new(title: "x", authors: [ "Tolkien" ]).valid?
    assert_not Item.new(title: "x", authors: [ nil ]).valid?
  end

  test "identifiers must be hash" do
    assert Item.new(title: "x", identifiers: { "isbn13" => "9783161484100" }).valid?
    assert_not Item.new(title: "x", identifiers: "isbn").valid?
  end

  test "associations" do
    item = Item.create!(title: "x")
    file = item.document_files.create!(
      storage_key: "ab/#{"a" * 64}", sha256: "a" * 64,
      mime_type: "application/pdf", size_bytes: 10, original_filename: "x.pdf"
    )
    assert_equal [ file ], item.document_files

    job = item.create_processing_job!
    assert_equal job, item.processing_job
    assert job.pending?
  end
end
