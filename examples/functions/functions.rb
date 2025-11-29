def fact(num)
  if num.zero?
    1
  else
    num * fact(num - 1)
  end
end

def fibonacci(num)
  if num.zero? || num.one?
    1
  else
    fibonacci(num - 1) + fibonacci(num - 2)
  end
end

puts "Factorial of 5 is #{fact(5)}"
puts "Fibonacci of 5 is #{fibonacci(5)}"
