#!/bin/bash
set -e

export MYSQL_HOST="${MYSQL_HOST:-mysql}"
export MYSQL_DATABASE="${MYSQL_DATABASE:-$MYSQL_ENV_MYSQL_DATABASE}"
export MYSQL_USER="${MYSQL_USER:-$MYSQL_ENV_MYSQL_USER}"
export MYSQL_PASSWORD="${MYSQL_PASSWORD:-$MYSQL_ENV_MYSQL_PASSWORD}"

cd /opt/webistrano
cp -p config/webistrano_config.rb.sample config/webistrano_config.rb
cat <<EOS > config/database.yml
production:
  adapter: mysql
  host: <%= ENV['MYSQL_HOST'] %>
  database: <%= ENV['MYSQL_DATABASE'] %>
  username: <%= ENV['MYSQL_USER'] %>
  password: <%= ENV['MYSQL_PASSWORD'] %>
  socket: /tmp/mysql.sock
EOS

RAILS_ENV=production bundle exec rake db:migrate
ruby script/server -p 3000 -e production

exit 0
