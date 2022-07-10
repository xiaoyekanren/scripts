#/bin/bash

# IoTDB 停止-清理-启动脚本

IOTDB_HOME=/home/zzm/data/apache-iotdb-0.12.5-server-bin
export JAVA_HOME=/usr/local/jdk1.8.0_311
export PATH=$JAVA_HOME/bin:$PATH

# auto generate
IOTDB_BIN=$IOTDB_HOME/sbin
IOTDB_DATA=$IOTDB_HOME/data

# stop-iotdb
jps -l | grep 'org.apache.iotdb.db.service.IoTDB' | awk '{print $1}' | xargs kill -9
sleep 3

# clear-iotdb
rm -rf $IOTDB_DATA

# start-iotdb
nohup $IOTDB_BIN/start-server.sh >/dev/null 2>&1 &
sleep 2
