# What's this?

[gh-ostを試したくなって](http://github.com/github/gh-ost)

MySQLのmaster-slave環境が欲しくなったので作った。

セキュリティに関してはガバガバなのはわかりきってるので適宜よろしくやってほしい。

`gh-ost`はまだうまく動かない...

# Usage

~~~
$ docker-compose build
$ docker-compose up
~~~

## 簡単な解説

### docker-compose.yml

特に難しいことはしてない

### Dockerfile

特に難しいことはしてない

### Dockerfile-slave

slave側がちょっとだけ変わったことしてる
[mysqlの公式docker hub](https://hub.docker.com/_/mysql/)を見るとわかるんだけど
`docker-entrypoint-initdb.d`に`*.sh`, `*.sql` のファイルを入れておくと
DBが立ち上がった後に実行してくれる。

今回だとSlaveに登録するためのスクリプトを追加。

~~~
FROM mysql

# ...
ADD "slave-start.sh" "/docker-entrypoint-initdb.d"

EXPOSE 3306
CMD ["mysqld"]
~~~

### slave-start.sh

slaveを開始するためのスクリプト
初めて作ったからあってるかどうかはよく分かんない

~~~
#!/bin/sh

# masterに繋いで bin-logのファイル名とポジションを取得する
export MYSQL_PWD=${MYSQL_MASTER_ROOT_PASS}
log_file=`mysql -u root -h master -e "SHOW MASTER STATUS\G" | grep File: | awk '{print $2}'`
pos=`mysql -u root -h master -e "SHOW MASTER STATUS\G" | grep Position: | awk '{print $2}'`

# slaveの開始
export MYSQL_PWD=${MYSQL_ROOT_PASSWORD}
mysql -u root -e "CHANGE MASTER TO MASTER_HOST='master', MASTER_USER='root', MASTER_PASSWORD='root', MASTER_LOG_FILE='${log_file}', MASTER_LOG_POS=${pos};"
mysql -u root -e "start slave"
~~~

### my.cnfでbinary logを有効化する

master.cnf

~~~my.cnf
[mysqld]
log-bin=/var/log/mysql/bin-log
server-id=1
~~~

slave.cnf

~~~my.cnf
[mysqld]
log-bin=/var/log/mysql/bin-log
server-id=2
~~~

## 実行結果

~~~
$ docker-compose up
...

$ d ps
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                     NAMES
627c80aff381        ghost-mysql:slave    "docker-entrypoint.sh"   31 minutes ago      Up 31 minutes       0.0.0.0:33307->3306/tcp   ghosttest_slave_1
ae410b180056        ghost-mysql:master   "docker-entrypoint.sh"   31 minutes ago      Up 31 minutes       0.0.0.0:33306->3306/tcp   ghosttest_master_1

# master確認
$ d exec -it ae4 mysql -u root -p -e "show master status\G;"
Enter password:
*************************** 1. row ***************************
             File: bin-log.000003
         Position: 1021
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set:

# slave確認
$ d exec -it 627 mysql -u root -p -e "show slave status\G;"
Enter password:
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: master
                  Master_User: root
                  Master_Port: 3306
...
               Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
...
~~~

