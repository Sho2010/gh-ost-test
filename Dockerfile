FROM mysql

MAINTAINER "sho20100@gmail.com"

RUN mkdir -p /var/log/mysql
RUN touch /var/log/mysql/mysql-bin.log
RUN chown -R mysql:mysql /var/log/mysql

ADD "master.cnf" "/etc/mysql/conf.d"

EXPOSE 3306
CMD ["mysqld"]
