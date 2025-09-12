def word_stats(text)
  words = text.scan(/\b[\p{L}']+\b/)
  total_words = words.length
  longest_word = words.max_by(&:length)
  unique_words = words.map(&:downcase).uniq.length
  { words: total_words, longest: longest_word, unique: unique_words }
end
print "Введіть рядок тексту: "
user_input = gets.chomp
stats = word_stats(user_input)
puts "#{stats[:words]} слів, найдовше: #{stats[:longest]}, унікальних: #{stats[:unique]}"
