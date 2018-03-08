require 'active_record'
require 'pg'


ActiveRecord::Base.establish_connection(
  adapter: 'postgresql', 
  host: 'postgres',
  database: 'postgres',
  username: 'postgres',
  password: 'password',
)


class User < ActiveRecord::Base
end

