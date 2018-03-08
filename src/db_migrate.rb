require 'active_record'
require 'mysql2'


ActiveRecord::Base.establish_connection(
  adapter: 'mysql2', 
  host: 'mysql',
  database: 'mysql',
  username: 'root',
  password: 'password',
)


class InitialSchema < ActiveRecord::Migration[5.1]
  def self.up
    create_table :users  do |t|
      t.string :name
      t.string :profile
      t.integer :active
      t.string :line_id
    end

  end

  def self.down
    drop_table :users
  end
end


InitialSchema.migrate(:up)

