#/bin/bash

#kairosdb cassandra 停止-清理数据-启动脚本

CASSANDRA_HOME=/home/zzm/data/apache-cassandra-3.11.2
KAIROSDB_HOME=/home/zzm/data/kairosdb

echo stop-cassandra...
ps -ef | grep '[o]rg.apache.cassandra.service.CassandraDaemon' | awk '{print $2}' | xargs kill -9
#user=`whoami`
#pgrep -u $user -f cassandra | xargs kill -9
sleep 10

echo clear-cassandra
rm -rf $CASSANDRA_HOME/data
rm -rf $CASSANDRA_HOME/bin/nohup.out
rm -rf $CASSANDRA_HOME/logs

echo stop-kairosdb...
ps -ef | grep "[o]rg.kairosdb.core.Main -c start -p" | awk '{print $2}' | xargs kill -9
#pgrep -u $user -f kairosdb | xargs kill -9
sleep 20

echo clear-kairosdb
rm -rf $KAIROSDB_HOME/queue

echo start-cassandra...
nohup $CASSANDRA_HOME/bin/cassandra -f >/dev/null 2>&1 &
sleep 30

echo start-kairosdb...
$KAIROSDB_HOME/bin/kairosdb.sh start
sleep 20
