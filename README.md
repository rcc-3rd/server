
## usage
docker-compose up -d
docker-compose exec bus bash

bundle install -j4
bundle exec ruby src/db_migrate.rb

./start
#bundle exec ruby server.rb -p 8080 -o 0.0.0.0 -e production
