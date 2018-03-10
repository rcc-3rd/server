# CLEVA

![CLEVA_logo](https://raw.githubusercontent.com/rcc-3rd/server/images/cleva_logo.png "ロゴ")

## about
**CLEVA**はRCC_3rdが提供する完全に新しい最高にクールなソリューションです！


## usage
1. edit files for your env
  * docker-compose.yml.tmp -> docker-compose.yml
  * config/cred.yml.tmp -> config/cred.yml

2. `docker-compose up -d`
3. `docker-compose exec bus bash`

4. `bundle install -j4`
5. `bundle exec ruby src/db_migrate.rb`

6. `./start`
