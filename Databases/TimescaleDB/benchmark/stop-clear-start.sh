#!/bin/bash

PG_MAIN=/home/zzm/data/timescaledb

# auto generate
PG_HOME=$PG_MAIN/pgsql
PG_DATA=$PG_MAIN/pg_data
PG_BIN=$PG_HOME/bin
LOG=$PG_HOME/log/`date +"%Y-%m-%d-%H-%M-%S"`.log

# stop
ps -ef|grep '[p]gsql/bin/postgres -D'|awk '{print $2}'| xargs kill -9
sleep 3

# clear
rm -rf $PG_DATA/*

# init
$PG_BIN/initdb -d $PG_DATA
sed -i "s:^max_connections.*:max_connections = 1000:g" $PG_DATA/postgresql.conf
sed -i "s/^#listen_addresses =.*/listen_addresses = '*'/g" $PG_DATA/postgresql.conf

# # use timescaledb-tune to auto set.
# timescaledb-tune -conf-path=/home/zzm/data/timescaledb/pg_data/postgresql.conf -pg-config=/home/zzm/data/timescaledb/pgsql/bin/pg_config
# shared_preload_libraries
sed -i "s/^#shared_preload_libraries.*/shared_preload_libraries = 'timescaledb'/g" $PG_DATA/postgresql.conf
# memory
sed -i "s/^shared_buffers.*/shared_buffers = 7968MB/g" $PG_DATA/postgresql.conf
sed -i "s/^#effective_cache_size.*/effective_cache_size = 23904MB/g" $PG_DATA/postgresql.conf
sed -i "s/^#maintenance_work_mem.*/maintenance_work_mem = 2047MB/g" $PG_DATA/postgresql.conf
sed -i "s/^#work_mem = 4MB.*/work_mem = 5099kB/g" $PG_DATA/postgresql.conf
# Parallelism
echo "timescaledb.max_background_workers = 8" >> $PG_DATA/postgresql.conf
sed -i "s/^#max_worker_processes = 8.*/max_worker_processes = 27/g" $PG_DATA/postgresql.conf
sed -i "s/^#max_parallel_workers_per_gather = 0.*/max_parallel_workers_per_gather = 8/g" $PG_DATA/postgresql.conf
# WAL
sed -i "s/^#wal_buffers = -1.*/wal_buffers = 16MB/g" $PG_DATA/postgresql.conf
sed -i "s/^#min_wal_size = 80MB.*/min_wal_size = 512MB/g" $PG_DATA/postgresql.conf
sed -i "s/^#max_wal_size = 1GB.*/max_wal_size = 1GB/g" $PG_DATA/postgresql.conf
# Miscellaneous
sed -i "s/^#default_statistics_target = 100.*/default_statistics_target = 500/g" $PG_DATA/postgresql.conf
sed -i "s/^#random_page_cost = 4.0.*/random_page_cost = 1.1/g" $PG_DATA/postgresql.conf
sed -i "s/^#checkpoint_completion_target = 0.5.*/checkpoint_completion_target = 0.9/g" $PG_DATA/postgresql.conf
sed -i "s/^#max_locks_per_transaction = 64.*/max_locks_per_transaction = 256/g" $PG_DATA/postgresql.conf
sed -i "s/^#autovacuum_max_workers = 3.*/autovacuum_max_workers = 10/g" $PG_DATA/postgresql.conf
sed -i "s/^#autovacuum_naptime = 1min.*/autovacuum_naptime = 10/g" $PG_DATA/postgresql.conf
sed -i "s/^#effective_io_concurrency = 1.*/effective_io_concurrency = 200/g" $PG_DATA/postgresql.conf

#startup
$PG_BIN/pg_ctl -D $PG_DATA -l $LOG start
sleep 3

#createdb
$PG_BIN/createuser -dlrs postgres
$PG_BIN/psql -U postgres -c "alter user postgres with password '123456';"
$PG_BIN/psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;"
echo 'finish'
