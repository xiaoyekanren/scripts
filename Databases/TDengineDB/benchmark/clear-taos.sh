#/bin/bash

#taosd 停止-清理数据-启动脚本

systemctl stop taosd
sleep 1
rm -rf /home/zzm/data/taos_data/*
sleep 5
systemctl start taosd
