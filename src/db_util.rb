require 'active_record'
require 'pg'


ActiveRecord::Base.establish_connection(
  adapter: 'postgresql', 
  host: 'postgres',
  database: 'postgres',
  username: 'user',
  password: 'password',
)


class User < ActiveRecord::Base
end

