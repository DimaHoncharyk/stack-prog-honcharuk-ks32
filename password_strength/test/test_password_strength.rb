require "minitest/autorun"
require_relative "../lib/password_strength"

class TestPasswordStrength < Minitest::Test
  def test_weak_password
    score = PasswordStrength::Analyzer.score("password")
    assert_equal "weak", PasswordStrength::Analyzer.label(score)
  end

  def test_medium_password
    score = PasswordStrength::Analyzer.score("Pass1234")
    assert_equal "medium", PasswordStrength::Analyzer.label(score)
  end

  def test_strong_password
    score = PasswordStrength::Analyzer.score("P@ssw0rd!1234")
    assert_equal "strong", PasswordStrength::Analyzer.label(score)
  end
end
