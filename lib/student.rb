require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade 
  attr_reader :id

  def initialize(id=nil, name, grade)
  	@name = name
  	@grade = grade
  	@id = id
  end

  def self.create_table
  	sql = <<-SQL
  	CREATE TABLE IF NOT EXISTS students (
  	id INTEGER PRIMARY KEY,
  	name TEXT,
  	grade INTEGER
  	)
  	SQL

  	DB[:conn].execute(sql)
  end

  def self.drop_table
  	sql = "DROP TABLE IF EXISTS students"
  	DB[:conn].execute(sql)
  end

  def update
  	sql = "UPDATE students SET name = ?, grade = ? Where id = ?"
  	DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save
  	if self.id
  		self.update
  	else
	  	sql = <<-SQL
	  	INSERT INTO students (name, grade)
	  	VALUES (?, ?)
	  	SQL

	  	DB[:conn].execute(sql, self.name, self.grade)
	  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
	  end
  end

  def self.create(name, grade)
  	new_student = Student.new(name, grade)
  	new_student.save
  	new_student
  end

  def self.new_from_db(array)
  	new_student = self.new(array[0], array[1], array[2])
  end

  def self.find_by_name(name)
  	sql = "SELECT * FROM students WHERE name = ?"
  	result = DB[:conn].execute(sql, name)[0]
  	self.new(result[0], result[1], result[2])

  	DB[:conn].execute(sql, name).map do |row|
  		self.new_from_db(row)
  	end.first
  end



end
