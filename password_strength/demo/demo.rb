require "io/console"
require_relative "../lib/password_strength"
print "Enter your password: "
password = STDIN.noecho(&:gets).chomp
puts
score = PasswordStrength::Analyzer.score(password)
puts "Score: #{score}/7"
puts "Strength: #{PasswordStrength::Analyzer.label(score)}"
