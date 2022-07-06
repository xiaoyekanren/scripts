#/bin/bash

#influxdb 停止-清理数据-启动脚本

# influxdb
INFLUXDB_HOME=/home/zzm/data/influxdb-1.5.5-1
INFLUXDB_BIN=$INFLUXDB_HOME/usr/bin
INFLUXDB_DATA=$INFLUXDB_HOME/data
INFLUXDB_CONF_FILE=$INFLUXDB_HOME/etc/influxdb/influxdb.conf

# stop
ps -ef | grep '[i]nfluxd -config' | awk {'print $2'} | xargs kill -9
sleep 3

# clear-iotdb
rm -rf $INFLUXDB_DATA

# start-iotdb
cd $INFLUXDB_HOME
nohup $INFLUXDB_BIN/influxd -config $INFLUXDB_CONF_FILE >nohup.out 2>&1 &
sleep 2
