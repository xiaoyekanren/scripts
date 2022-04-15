#/bin/bash

# 调用iotdb-benchmark去测试 taosd 的脚本，DYNAMIC_PARA控制循环
# 需要在 taosd 所在服务器放置 stop-clear-start.sh脚本，两者配合使用

# 需要确定的参数
BENCHMARK_HOME=/home/zzm/tdengine
DB=TDengine
# 要变换的配置项，只能一个
DYNAMIC_PARA="GROUP_NUMBER"
DYNAMIC_PARA_VALUES=(1 5 10 15 20 50 100)
# 声明用于参数修改的字典
declare -A static_paras # 必须声明
static_paras=(
    [DB_SWITCH]="TDengine"
    [HOST]="192.168.130.37"
    [PORT]="6030"
    [USERNAME]="root"
    [PASSWORD]="taosdata"
    [DB_NAME]="test"
    [TEST_MAX_TIME]="3600000"
    [LOOP]="999999999"
    [IS_DELETE_DATA]="true"
    [CLIENT_NUMBER]="100"
    [DEVICE_NUMBER]="10000"
    [SENSOR_NUMBER]="100"
    [BATCH_SIZE]="100"
    [BENCHMARK_WORK_MODE]="testWithDefaultPath"
    [POINT_STEP]="10"
    [INSERT_DATATYPE_PROPORTION]="0:0:0:0:1:0"
    [ENCODING_DOUBLE]="GORILLA"
)

# ------
# 以下内容无需修改
# ------

alter_static_paras() {
    for alone in ${!static_paras[@]}; do
        sed -i -e "s/^${alone}=.*/${alone}=${static_paras[$alone]}/g" $BENCHMARK_CONF_FILE
    done
}

init_config() {
    cp $BENCHMARK_CONF_FILE $LOG_DIRECTORY/${para}.properties
    cp $BENCHMARK_CONF_FILE_BAK $BENCHMARK_CONF_FILE
    ssh root@192.168.130.37 "/bin/bash /home/zzm/data/clear-taos.sh"
}
# 自动生成的参数
BENCHMARK_CONF=$BENCHMARK_HOME/conf
BENCHMARK_CONF_FILE=$BENCHMARK_HOME/conf/config.properties
BENCHMARK_CONF_FILE_BAK=${BENCHMARK_CONF_FILE}_$(date +%Y%m%d%H%M)
BENCHMARK_EXEC_FILE=$BENCHMARK_HOME/benchmark.sh
LOG_DIRECTORY=$BENCHMARK_HOME/work_log/$DB-$DYNAMIC_PARA-$(date +%Y%m%d)

# 准备工作
# 1 备份配置文件
cp $BENCHMARK_CONF_FILE $BENCHMARK_CONF_FILE_BAK
# 2 创建log文件夹
mkdir -p $LOG_DIRECTORY
# 主程序
for para in ${DYNAMIC_PARA_VALUES[@]}; do
    echo "$(date +"%Y-%m-%d %H:%M:%S")  test $para, start..."
    # 修改固定参数
    alter_static_paras
    # 修改变化参数
    sed -i -e "s/^${DYNAMIC_PARA}=.*/${DYNAMIC_PARA}=$para/g" $BENCHMARK_CONF_FILE
    # 启动程序
    $BENCHMARK_EXEC_FILE >$LOG_DIRECTORY/${para}.out
    # 恢复原始配置
    init_config
done

