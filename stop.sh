#!/bin/bash

# 打卡系统停止脚本

PID_FILE="app.pid"

if [ ! -f "$PID_FILE" ]; then
    echo "PID文件不存在，应用可能没有运行"
    exit 1
fi

PID=$(cat $PID_FILE)

if ps -p $PID > /dev/null 2>&1; then
    echo "停止应用 (PID: $PID)..."
    kill $PID
    
    # 等待进程结束
    count=0
    while ps -p $PID > /dev/null 2>&1 && [ $count -lt 10 ]; do
        sleep 1
        count=$((count + 1))
    done
    
    if ps -p $PID > /dev/null 2>&1; then
        echo "强制停止应用..."
        kill -9 $PID
    fi
    
    rm -f $PID_FILE
    echo "应用已停止"
else
    echo "应用未运行 (PID: $PID)"
    rm -f $PID_FILE
fi
