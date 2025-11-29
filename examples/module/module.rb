module School
  class Person
    def initialize(name, age)
      @name = name
      @age = age
    end
    attr_accessor :name, :age

    def introduce
      puts "My name is #{@name} and I am #{@age} years old."
    end
  end

  class Teacher < Person
    def initialize(name, age, subject)
      super(name, age)
      @subject = subject
    end
    attr_accessor :subject

    def teach
      puts "#{@name} is teaching #{@subject}."
    end
  end

  class Student < Person
    def initialize(name, age, grade)
      super(name, age)
      @grade = grade
    end
    attr_accessor :grade

    def study
      puts "#{@name} is studying in grade #{@grade}."
    end
  end
end

teachers = [
  School::Teacher.new('John', 30, 'Math'),
  School::Teacher.new('Jane', 35, 'Science'),
  School::Teacher.new('Bob', 25, 'English')
]

students = [
  School::Student.new('Alice', 20, 10),
  School::Student.new('Bob', 25, 11),
  School::Student.new('Charlie', 18, 12)
]

teachers.each do |teacher|
  teacher.introduce
  teacher.teach

  students.each do |student|
    student.introduce
    student.study
  end
end
