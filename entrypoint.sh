#!/bin/bash
set -e

export MYSQL_HOST="${MYSQL_HOST:-mysql}"
export MYSQL_DATABASE="${MYSQL_DATABASE:-$MYSQL_ENV_MYSQL_DATABASE}"
export MYSQL_USER="${MYSQL_USER:-$MYSQL_ENV_MYSQL_USER}"
export MYSQL_PASSWORD="${MYSQL_PASSWORD:-$MYSQL_ENV_MYSQL_PASSWORD}"

waitDbConnection() {
  
  prog="mysqladmin -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} status"
  timeout=60

  printf "Waiting for database server to accect connections"
  while ! ${prog} > /dev/null 2>&1
  do
    timeout=$(expr $timeout - 1)
    if [[ $timeout -eq 0 ]]; then
      printf "\n Could not connect to database server. Aborting...\n"
      exit 1
    fi
    printf "."
    sleep 1
  done

}

appShowKeyPair() {
  printf "[id_rsa.pub]============================\n"
  cat ${DATA_DIR}/.ssh/id_rsa.pub
  printf "========================================\n"
}

appStart() {

  waitDbConnection

  if [ ! -e ${DATA_DIR}/.ssh/id_rsa ]; then
    mkdir -p ${DATA_DIR}/.ssh
    chmod 700 ${DATA_DIR}/.ssh
    ssh-keygen -f ${DATA_DIR}/.ssh/id_rsa -t rsa -N ""
  fi

  ln -sn ${DATA_DIR}/.ssh ~/.ssh

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
  app:show-keypair)
    appShowKeyPair
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
