require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "email нормалізується і має бути унікальним" do
    create_user(email: "Anna@Example.com")
    duplicate = User.new(full_name: "Анна", email: "anna@example.com", phone: "1", birth_date: "1990-01-01",
                         password: "Password123", password_confirmation: "Password123")
    assert_not duplicate.valid?
    assert duplicate.errors[:email].any?
  end

  test "пароль коротший за 8 символів недопустимий" do
    user = User.new(full_name: "Анна", email: "short@example.com", phone: "1", birth_date: "1990-01-01",
                    password: "short", password_confirmation: "short")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "після 5 невдалих спроб обліковий запис блокується" do
    user = create_user
    4.times { user.register_failed_attempt! }
    assert_not user.reload.locked?
    user.register_failed_attempt!
    assert user.reload.locked?
  end

  test "успішний вхід скидає лічильник спроб" do
    user = create_user
    3.times { user.register_failed_attempt! }
    user.reset_failed_attempts!
    assert_equal 0, user.reload.failed_attempts
  end
end
