class Calculator
  def add(a, b)
    a + b
  end

  def subtract(a, b)
    a - b
  end

  def multiply(a, b)
    a * b
  end

  def divide(a, b)
    a / b
  end

  def power(a, b)
    a ** b
  end

  def sqrt(a)
    Math.sqrt a
  end

  def factorial(n)
    (1..n).reduce 1, :*
  end

  def gcd(a, b)
    b.zero? ? a : gcd(b, a % b)
  end

  def lcm(a, b)
    a * b / gcd(a, b)
  end

  def prime?(n)
    return false if n < 2
    (2..Math.sqrt(n)).none? { |i| (n % i).zero? }
  end

  def fibonacci(n)
    return n if n < 2
    fibonacci(n - 1) + fibonacci(n - 2)
  end

  def collatz(n)
    return 0 if n == 1
    1 + (n.even? ? collatz(n / 2) : collatz(3 * n + 1))
  end

  def harmonic(n)
    (1..n).sum { |i| 1.0 / i }
  end

  def sieve(limit)
    (2..limit).reject { |n| (2..Math.sqrt(n)).any? { |i| (n % i).zero? } }
  end
end
