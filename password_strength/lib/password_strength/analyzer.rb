module PasswordStrength
  class Analyzer
    COMMON_WORDS = %w[password qwerty 123456 admin user welcome].freeze
    MIN_LENGTH = 8
    def self.score(password)
      score = 0
      score += 1 if password.length >= MIN_LENGTH
      score += 1 if password.length >= 12
      score += 1 if password =~ /[A-Z]/
      score += 1 if password =~ /[a-z]/
      score += 1 if password =~ /\d/
      score += 1 if password =~ /[^A-Za-z0-9]/
      score -= 2 if COMMON_WORDS.any? { |w| password.downcase.include?(w) }
      score -= 1 if password =~ /(.)\1{2,}/
      [[score, 0].max, 7].min
    end

    def self.label(score)
      case score
      when 0..2 then "weak"
      when 3..5 then "medium"
      else "strong"
      end
    end
  end
end
