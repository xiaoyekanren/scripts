#!/bin/bash

# 该脚本用于使用benchmark测试所支持的数据库
# benchmark测试iotdb，每次更换一个配置，其他配置项保持不变,DYNAMIC_PARA控制循环
# 清理数据需要依靠benchmark自身或者在init里增加ssh参数来控制


# -----!!!需要确定的参数!!!-----
# benchmark路径
BENCHMARK_HOME=/home/zzm/iotdb-0.12 
# 仅作为log记录
DB=IoTDB                            

# 自动生成的参数
BENCHMARK_CONF=$BENCHMARK_HOME/conf
BENCHMARK_CONF_FILE=$BENCHMARK_HOME/conf/config.properties
BENCHMARK_CONF_FILE_BAK=${BENCHMARK_CONF_FILE}_${DB}_back
BENCHMARK_EXEC_FILE=$BENCHMARK_HOME/benchmark.sh
LOG_DIRECTORY=$BENCHMARK_HOME/work_log/$DB-$DYNAMIC_PARA-$(date +%Y%m%d)

# 批量替换配置文件 函数
alter_static_paras() {
    for alone in ${!static_paras[@]}; do
        echo "change ${alone} to ${static_paras[$alone]}"
        sed -i -e "s/^${alone}=.*/${alone}=${static_paras[$alone]}/g" $BENCHMARK_CONF_FILE
    done
}
# 初始化数据库 函数
init_config() {
    cp $BENCHMARK_CONF_FILE $LOG_DIRECTORY/${para}.properties
    cp $BENCHMARK_CONF_FILE_BAK $BENCHMARK_CONF_FILE
}

# -----一轮测试-----
# 若需要长时间多次循环的测试，从这里往后复制到sleep 60
# 要变换的配置项，只能一个
DYNAMIC_PARA="BATCH_SIZE_PER_WRITE"
DYNAMIC_PARA_VALUES=(1 10 100 1000 2000 3000)
# 声明用于参数修改的字典
declare -A static_paras # 必须声明，声明之后必须使用bash执行
static_paras=(
    # 数据库连接信息
    [DB_SWITCH]="IoTDB-012-SESSION_BY_TABLET"
    [HOST]="192.168.130.37"
    [PORT]="6667"
    # 时长
    [TEST_MAX_TIME]="3600000"
    [LOOP]="999999999"
    # 数据量
    [CLIENT_NUMBER]="10"
    [GROUP_NUMBER]="10"
    [DEVICE_NUMBER]="10000"
    [SENSOR_NUMBER]="100"
    # 数据类型
    [INSERT_DATATYPE_PROPORTION]="0:0:0:0:1:0"
    [ENCODING_DOUBLE]="GORILLA"
    # 其他
    [IS_DELETE_DATA]="true"
    [BENCHMARK_WORK_MODE]="testWithDefaultPath"
    [POINT_STEP]="1000"
)
echo "backup config file..." # 备份配置文件
cp $BENCHMARK_CONF_FILE $BENCHMARK_CONF_FILE_BAK
echo "mkdir record folder..." # 创建log文件夹
mkdir -p $LOG_DIRECTORY

for para in ${DYNAMIC_PARA_VALUES[@]}; do
    echo "----------$(date +"%Y-%m-%d %H:%M:%S")  test $para, start...----------"
    echo "1. change static paras..." # 修改 固定参数
    alter_static_paras
    echo "2. change dynamic para" # 修改 变化参数
    echo "3. change ${DYNAMIC_PARA} to $para"
    sed -i -e "s/^${DYNAMIC_PARA}=.*/${DYNAMIC_PARA}=$para/g" $BENCHMARK_CONF_FILE
    echo "4. start benchmark..." # 启动程序
    $BENCHMARK_EXEC_FILE >$LOG_DIRECTORY/${para}.out
    echo "5. init config, clear data" # 恢复原始配置
    init_config
done
sleep 1
# -----一轮测试结束-----
