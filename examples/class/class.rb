class Person
  def initialize(name, age)
    @name = name
    @age = age
  end
  attr_accessor :name, :age

  def introduce
    puts "My name is #{@name} and I am #{@age} years old."
  end

  def birthday
    @age += 1
    puts "#{@name} is turning #{@age} years old."
  end
end

me = Person.new 'Mazza', 19
me.introduce
me.birthday
me.introduce
