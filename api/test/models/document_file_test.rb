require "test_helper"

class DocumentFileTest < ActiveSupport::TestCase
  def setup
    @item = Item.create!(title: "x")
  end

  test "valid file" do
    assert build_file.valid?
  end

  test "storage_key unique" do
    build_file.save!
    assert_not build_file(original_filename: "other.pdf").valid?
  end

  test "sha256 must be 64 hex chars" do
    assert_not build_file(sha256: "zz").valid?
  end

  test "size_bytes cannot be negative" do
    assert_not build_file(size_bytes: -1).valid?
  end

  test "belongs to item" do
    file = build_file
    file.save!
    assert_equal @item, file.item
  end

  private

  def build_file(overrides = {})
    @item.document_files.new({
      storage_key: "ab/#{"a" * 64}", sha256: "a" * 64,
      mime_type: "application/pdf", size_bytes: 10, original_filename: "x.pdf"
    }.merge(overrides))
  end
end
