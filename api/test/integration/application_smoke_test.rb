require "test_helper"

class ApplicationSmokeTest < ActionDispatch::IntegrationTest
  test "health check responds 200" do
    get "/up"
    assert_response :success
  end

  test "application bootstraps with a database connection" do
    assert ActiveRecord::Base.connection.active?
  end
end