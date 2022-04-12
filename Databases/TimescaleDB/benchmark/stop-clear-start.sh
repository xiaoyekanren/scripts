#/bin/bash

# PostgresDB 停止-启动脚本

# postgres
PG_MAIN=/home/zzm/data/timescaledb
PG_HOME=$PG_MAIN/pgsql
PG_BIN=$PG_HOME/bin
PG_DATA=$PG_MAIN/pg_data
LOG=$PG_HOME/log/`date +"%Y-%m-%d-%H-%M-%S"`.log


# stop
ps -ef|grep '[p]gsql/bin/postgres -D'|awk '{print $2}'| xargs kill -9
sleep 3

# clear-iotdb
# wait

#startup
$PG_BIN/pg_ctl -D $PG_DATA -l $LOG start