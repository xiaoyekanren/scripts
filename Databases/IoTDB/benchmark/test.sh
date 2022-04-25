#/bin/bash

# 调用iotdb-benchmark去测试 iotdb 的脚本，DYNAMIC_PARA控制循环
# 清理数据需要依靠benchmark自身

# 需要确定的参数
BENCHMARK_HOME=/home/zzm/iotdb-0.12
DB=IoTDB
# 要变换的配置项，只能一个
DYNAMIC_PARA="BATCH_SIZE_PER_WRITE"
DYNAMIC_PARA_VALUES=(1000)
# 声明用于参数修改的字典
declare -A static_paras # 必须声明
static_paras=(
    [DB_SWITCH]="IoTDB-012-SESSION_BY_TABLET"
    [HOST]="192.168.130.37"
    [PORT]="6667"
    [TEST_MAX_TIME]="3600000"
    [LOOP]="999999999"
    [IS_DELETE_DATA]="true"
    [CLIENT_NUMBER]="10"
    [GROUP_NUMBER]="10"
    [DEVICE_NUMBER]="10000"
    [SENSOR_NUMBER]="100"
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
        echo 'change ${alone} to ${static_paras[$alone]}'
        sed -i -e "s/^${alone}=.*/${alone}=${static_paras[$alone]}/g" $BENCHMARK_CONF_FILE
    done
}

init_config() {
    cp $BENCHMARK_CONF_FILE $LOG_DIRECTORY/${para}.properties
    cp $BENCHMARK_CONF_FILE_BAK $BENCHMARK_CONF_FILE
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
