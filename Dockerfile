FROM mysql

RUN mkdir -p /var/log/mysql
RUN touch /var/log/mysql/mysql-bin.log
RUN chown -R mysql:mysql /var/log/mysql

ARG kind=master
ADD "${kind}.cnf" "/etc/mysql/conf.d"

EXPOSE 3306
CMD ["mysqld"]
