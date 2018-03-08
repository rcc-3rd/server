require 'active_record'
require 'mysql2'


ActiveRecord::Base.establish_connection(
  adapter: 'mysql2', 
  host: 'mysql',
  database: 'mysql',
  username: 'root',
  password: 'password',
)


class User < ActiveRecord::Base
end

