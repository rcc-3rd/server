require 'active_record'
require 'pg'


ActiveRecord::Base.establish_connection(
  adapter: 'postgresql', 
  host: 'postgres',
  database: 'postgres',
  username: 'postgres',
  password: 'password',
)


class InitialSchema < ActiveRecord::Migration[5.1]
  def self.up
    create_table :users do |t|
      t.string :line_id
      t.string :name
      t.string :profile
      t.integer :active
    end
    add_index :users, [:line_id], :unique => true
  end

  def self.down
    drop_table :users
  end
end


InitialSchema.migrate(:up)
#InitialSchema.migrate(:down)

