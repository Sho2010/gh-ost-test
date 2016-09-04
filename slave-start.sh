#!/bin/sh

echo "Waiting for master 10sec..."
sleep 10s

echo "Start slave process."
export MYSQL_PWD=${MYSQL_REPLICATION_PASS}
log_file=`mysql -u root -h master --port ${MYSQL_MASTER_PORT} -e "SHOW MASTER STATUS\G" | grep File: | awk '{print $2}'`
pos=`mysql -u root -h master --port ${MYSQL_MASTER_PORT} -e "SHOW MASTER STATUS\G" | grep Position: | awk '{print $2}'`

export MYSQL_PWD=${MYSQL_ROOT_PASSWORD}
mysql -u root -e "CHANGE MASTER TO MASTER_HOST='master', MASTER_PORT=${MYSQL_MASTER_PORT}, MASTER_USER='${MYSQL_REPLICATION_USER}', MASTER_PASSWORD='${MYSQL_REPLICATION_PASS}', MASTER_LOG_FILE='${log_file}', MASTER_LOG_POS=${pos};"
mysql -u root -e "start slave"

