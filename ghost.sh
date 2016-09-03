#!/bin/sh

gh-ost \
--max-load=Threads_running=25 \
--critical-load=Threads_running=1000 \
--throttle-control-replicas="127.0.0.1:33307" \
--chunk-size=1000 \
--max-lag-millis=1500 \
--user="root" \
--password="root" \
--database="test" \
--table="my_table" \
--host="127.0.0.1" \
--port=33307 \
--verbose \
--alter="engine=innodb" \
--switch-to-rbr \
--allow-master-master \
--cut-over=default \
--exact-rowcount \
--concurrent-rowcount \
--default-retries=120 \
--serve-socket-file=/tmp/ghost.sock \
--panic-flag-file=/tmp/ghost.panic.flag \
--postpone-cut-over-flag-file=/tmp/ghost.postpone.flag \
[--execute]

# --postpone-cut-over-flag-file=/tmp/ghost.postpone.flag
