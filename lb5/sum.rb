# Лямбда sum3
sum3 = ->(a, b, c) { a + b + c }
def curry3(proc_or_lambda)
  expected_arity = 3
  make_curried = lambda do |*args|
    if args.size > expected_arity
      raise ArgumentError, "забагато аргументів (#{args.size} > #{expected_arity})"
    end
    if args.size == expected_arity
      proc_or_lambda.call(*args)
    else
      ->(*more_args) { make_curried.call(*(args + more_args)) }
    end
  end
  ->(*args) { make_curried.call(*args) }
end

cur = curry3(sum3)

puts cur.call(1).call(2).call(3)       #=> 6
puts cur.call(1, 2).call(3)            #=> 6
puts cur.call(1).call(2, 3)            #=> 6
p cur.call()                           #=> #<Proc:...>
puts cur.call(1, 2, 3)                 #=> 6

begin
  cur.call(1, 2, 3, 4)
rescue ArgumentError => e
  puts e.message
end
f = ->(a, b, c) { "#{a}-#{b}-#{c}" }
cF = curry3(f)
puts cF.call('A').call('B', 'C')
