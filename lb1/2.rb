def play_game
  number = rand(1..100)
  attempts = 0
  puts "🎲 Гра 'Вгадай число'!"
  puts "Комп'ютер загадав число від 1 до 100. Спробуйте його вгадати!"
  loop do
    print "Ваш варіант: "
    guess = gets.to_i
    attempts += 1

    if guess < number
      puts "Більше!"
    elsif guess > number
      puts "Менше!"
    else
      puts "УРААААА ти вгадав! Число було #{number}."
      puts "Кількість спроб: #{attempts}"
      break
    end
  end
end

play_game


