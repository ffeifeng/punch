#!/bin/bash

# 打卡系统启动脚本
# 使用外部配置文件启动应用

APP_NAME="punch"
JAR_FILE="punch.war"
CONFIG_FILE="application-prod.yml"
PID_FILE="app.pid"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件 $CONFIG_FILE 不存在!"
    echo "请确保在当前目录下有 application-prod.yml 配置文件"
    exit 1
fi

# 检查WAR文件是否存在
if [ ! -f "$JAR_FILE" ]; then
    echo "错误: WAR文件 $JAR_FILE 不存在!"
    echo "请确保在当前目录下有 punch.war 文件"
    exit 1
fi

# 停止已运行的应用
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat $PID_FILE)
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo "停止已运行的应用 (PID: $OLD_PID)..."
        kill $OLD_PID
        sleep 3
    fi
    rm -f $PID_FILE
fi

# 启动应用
echo "启动 $APP_NAME 应用..."
echo "使用配置文件: $CONFIG_FILE"

nohup java -jar \
    -Dspring.profiles.active=prod \
    -Dspring.config.location=classpath:/application.yml,file:./$CONFIG_FILE \
    -Dspring.config.additional-location=file:./$CONFIG_FILE \
    -Dmybatis.mapper-locations=classpath:mapper/*.xml \
    -Xmx512m \
    -Xms256m \
    $JAR_FILE > app.log 2>&1 &

# 保存PID
echo $! > $PID_FILE

echo "应用已启动，PID: $(cat $PID_FILE)"
echo "日志文件: app.log"
echo "配置文件: $CONFIG_FILE"
echo ""
echo "查看日志: tail -f app.log"
echo "停止应用: ./stop.sh"