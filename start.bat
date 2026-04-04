@echo off
chcp 65001 > nul

rem 打卡系统启动脚本 (Windows)
rem 使用外部配置文件启动应用

set APP_NAME=punch
set JAR_FILE=punch.war
set CONFIG_FILE=application-prod.yml

rem 检查配置文件是否存在
if not exist "%CONFIG_FILE%" (
    echo 错误: 配置文件 %CONFIG_FILE% 不存在!
    echo 请确保在当前目录下有 application-prod.yml 配置文件
    pause
    exit /b 1
)

rem 检查WAR文件是否存在
if not exist "%JAR_FILE%" (
    echo 错误: WAR文件 %JAR_FILE% 不存在!
    echo 请确保在当前目录下有 punch.war 文件
    pause
    exit /b 1
)

echo 启动 %APP_NAME% 应用...
echo 使用配置文件: %CONFIG_FILE%
echo.

java -jar ^
    -Dspring.profiles.active=prod ^
    -Dspring.config.location=file:./%CONFIG_FILE% ^
    -Xmx512m ^
    -Xms256m ^
    %JAR_FILE%

pause