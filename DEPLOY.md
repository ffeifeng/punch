# 部署说明

## 配置文件外置方案

本项目支持将配置文件放在包外面，方便不同环境的部署。

### 本地开发

1. 默认使用 `application-local.yml` 配置（已内置在jar包中）
2. 直接运行即可：
   ```bash
   mvn spring-boot:run
   ```

### 生产环境部署

#### 1. 打包应用
```bash
mvn clean package
```

#### 2. 准备配置文件
将项目根目录下的 `application-prod.yml` 复制到服务器，并修改其中的配置：
- 数据库连接信息
- Redis连接信息（如果使用）
- 其他环境相关配置

#### 3. 部署到阿里云

**Linux服务器：**
```bash
# 上传文件到服务器
scp target/punch.war application-prod.yml start.sh stop.sh user@your-server:/opt/punch/

# 登录服务器
ssh user@your-server

# 进入应用目录
cd /opt/punch

# 给脚本执行权限
chmod +x start.sh stop.sh

# 启动应用
./start.sh
```

**Windows服务器：**
```cmd
# 将以下文件上传到服务器：
# - target\punch.war
# - application-prod.yml  
# - start.bat

# 双击运行 start.bat 或在命令行中执行
start.bat
```

#### 4. 验证部署
访问：`http://your-server:8081`

#### 5. 查看日志
```bash
# Linux
tail -f app.log

# Windows
type app.log
```

#### 6. 停止应用
```bash
# Linux
./stop.sh

# Windows
Ctrl+C 或关闭命令行窗口
```

### 配置文件说明

- `application.yml` - 基础配置（内置在jar包中）
- `application-local.yml` - 本地开发配置（内置在jar包中）
- `application-prod.yml` - 生产环境配置（外置，需要手动配置）

### 启动参数说明

应用启动时使用以下参数：
- `-Dspring.profiles.active=prod` - 激活生产环境配置
- `-Dspring.config.location=file:./application-prod.yml` - 指定外部配置文件位置
- `-Xmx512m -Xms256m` - JVM内存配置

### 注意事项

1. **配置文件安全**：生产环境的配置文件包含敏感信息，请确保文件权限设置正确
2. **数据库连接**：确保数据库服务正常运行且网络连接正常
3. **端口占用**：确保8081端口未被占用
4. **日志目录**：确保应用有权限创建和写入日志文件
5. **防火墙**：如需外网访问，请开放相应端口
