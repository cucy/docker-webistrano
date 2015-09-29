#!/bin/bash
set -e

export MYSQL_HOST="${MYSQL_HOST:-mysql}"
export MYSQL_DATABASE="${MYSQL_DATABASE:-$MYSQL_ENV_MYSQL_DATABASE}"
export MYSQL_USER="${MYSQL_USER:-$MYSQL_ENV_MYSQL_USER}"
export MYSQL_PASSWORD="${MYSQL_PASSWORD:-$MYSQL_ENV_MYSQL_PASSWORD}"

appStart() {

  cd /opt/webistrano

  cp config/webistrano.yml.sample config/webistrano.yml

  cat <<EOS > config/database.yml
production:
  adapter: mysql
  host: <%= ENV['MYSQL_HOST'] %>
  database: <%= ENV['MYSQL_DATABASE'] %>
  username: <%= ENV['MYSQL_USER'] %>
  password: <%= ENV['MYSQL_PASSWORD'] %>
  socket: /tmp/mysql.sock
EOS

  bundle exec rake db:migrate RAILS_ENV=production 
  bundle exec thin -e production start
}

case ${1} in
  app:start)
    appStart
    ;;    
  *)
    if [[ -x $1 ]]; then
      $1
    else
      prog=$(which $1)
      if [[ -n ${prog} ]] ; then
        shift 1
        $prog $@
      else
        appHelp
      fi
    fi
    ;;
esac


exit 0
