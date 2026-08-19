require "test_helper"

class ProcessingJobTest < ActiveSupport::TestCase
  test "default status pending" do
    job = ProcessingJob.new(item: Item.create!(title: "x"))
    assert_equal "pending", job.status
    assert job.pending?
  end

  test "valid statuses" do
    %i[pending processing completed failed].each do |status|
      job = ProcessingJob.new(item: Item.create!(title: "x"), status: status)
      assert job.valid?, "expected #{status} to be valid"
    end
  end

  test "item required" do
    assert_not ProcessingJob.new.valid?
  end

  test "single job per item" do
    item = Item.create!(title: "x")
    item.create_processing_job!
    assert_not ProcessingJob.new(item: item).valid?
  end

  test "timestamps ordered" do
    job = ProcessingJob.new(item: Item.create!(title: "x"))
    job.started_at = 1.minute.from_now
    job.completed_at = Time.current
    assert_not job.valid?
  end
end
