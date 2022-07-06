#!/bin/bash
  

CASSANDRA_HOME=/home/zzm/data/kairosdb/apache-cassandra-3.11.2
KAIROSDB_HOME=/home/zzm/data/kairosdb/kairosdb

# # 该脚本远程使用时，因环境变量设置位置不同可能会找不到java，需要手动配置
# # kairosdb/bin/kairosdb.sh,bin/kairosdb-service.sh 需指定export JAVA_HOME=xxxx
# # cassandra/bin/cassandra 需指定export JAVA_HOME=xxxx

echo stop-cassandra...
ps -ef|grep '[o]rg.apache.cassandra.service.CassandraDaemon'|awk '{print $2}'|xargs kill -9
#user=`whoami`
#pgrep -u $user -f cassandra | xargs kill -9
sleep 10

echo clear-cassandra
rm -rf $CASSANDRA_HOME/data
#rm -rf $CASSANDRA_HOME/bin/nohup.out
rm -rf $CASSANDRA_HOME/logs

echo stop-kairosdb...
ps -ef|grep "[o]rg.kairosdb.core.Main -c start -p"|awk '{print $2}' | xargs kill -9
#pgrep -u $user -f kairosdb | xargs kill -9
sleep 20

echo clear-kairosdb
rm -rf $KAIROSDB_HOME/queue

echo start-cassandra...
nohup $CASSANDRA_HOME/bin/cassandra -f > /dev/null 2>&1 &
sleep 30

echo start-kairosdb...
$KAIROSDB_HOME/bin/kairosdb.sh  start
sleep 20
echo finish
