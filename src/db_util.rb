require 'active_record'
require 'mysql'


ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3', 
  database: 'goroku.sqlite3'
)


class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :chapters  do |t|
      t.integer :chap
      t.integer :line
      t.string :section
    end

  end

  def self.down
    drop_table :chapters
  end
end


InitialSchema.migrate(:up)

class Chapter < ActiveRecord::Base
end

File.open('1.yml') do |f|
  i = 0
  f.each_line do |l|
    i += 1
    Chapter.create(chap: 1, line: i, section: l)
  end
end
File.open('2.yml') do |f|
  i = 0
  f.each_line do |l|
    i += 1
    Chapter.create(chap: 2, line: i, section: l)
  end
end
File.open('3.yml') do |f|
  i = 0
  f.each_line do |l|
    i += 1
    Chapter.create(chap: 3, line: i, section: l)
  end
end
File.open('4.yml') do |f|
  i = 0
  f.each_line do |l|
    i += 1
    Chapter.create(chap: 4, line: i, section: l)
  end
end
File.open('5.yml') do |f|
  i = 0
  f.each_line do |l|
    i += 1
    Chapter.create(chap:5, line: i, section: l)
  end
end
File.open('6.yml') do |f|
  i = 0
  f.each_line do |l|
    i += 1
    Chapter.create(chap: 6, line: i, section: l)
  end
end
