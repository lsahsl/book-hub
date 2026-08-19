require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    assert User.new(email: "a@b.com", password: "password123").valid?
  end

  test "email required" do
    assert_not User.new(email: "", password: "password123").valid?
  end

  test "email format invalid" do
    assert_not User.new(email: "not-an-email", password: "password123").valid?
  end

  test "email uniqueness" do
    User.create!(email: "a@b.com", password: "password123")
    assert_not User.new(email: "a@b.com", password: "password123").valid?
  end

  test "password minimum length" do
    assert_not User.new(email: "a@b.com", password: "short").valid?
  end

  test "password digest authenticates" do
    user = User.create!(email: "a@b.com", password: "password123")
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong")
  end
end
