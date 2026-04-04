<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>学生打卡 - 移动端登录</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .login-container {
            background: white;
            border-radius: 20px;
            padding: 40px 30px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 400px;
            text-align: center;
        }
        
        .logo {
            font-size: 2.5rem;
            color: #667eea;
            margin-bottom: 10px;
        }
        
        .title {
            font-size: 1.5rem;
            color: #333;
            margin-bottom: 30px;
            font-weight: 600;
        }
        
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 500;
        }
        
        .form-group input {
            width: 100%;
            padding: 15px;
            border: 2px solid #e1e5e9;
            border-radius: 10px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .login-btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .login-btn:hover {
            transform: translateY(-2px);
        }
        
        .login-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }
        
        .qr-info {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 20px;
            border-left: 4px solid #28a745;
        }
        
        .qr-info .icon {
            color: #28a745;
            font-size: 1.2rem;
            margin-right: 8px;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #dc3545;
        }
        
        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #28a745;
        }
        
        .loading {
            display: none;
            margin-top: 10px;
        }
        
        .loading-spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .footer {
            margin-top: 30px;
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo">📱</div>
        <div class="title">学生打卡系统</div>
        
        <% if (request.getParameter("qr") != null) { %>
        <div class="qr-info">
            <span class="icon">🔗</span>
            <strong>二维码登录</strong><br>
            <small>请输入您的学生账号信息</small>
        </div>
        <% } %>
        
        <div id="messageArea"></div>
        
        <form id="loginForm">
            <input type="hidden" id="qrCode" value="${qrCode}">
            
            <div class="form-group">
                <label for="password">🔒 请输入您的密码：</label>
                <input type="password" id="password" name="password" required placeholder="请输入密码">
            </div>
            
            <button type="submit" class="login-btn" id="loginBtn">
                🚀 立即登录
            </button>
            
            <div class="loading" id="loading">
                <div class="loading-spinner"></div>
                <p>登录中...</p>
            </div>
        </form>
        
        <div class="footer">
            <p>仅限学生用户使用</p>
        </div>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const password = document.getElementById('password').value.trim();
            const qrCode = document.getElementById('qrCode').value;
            
            if (!password) {
                showMessage('请输入密码', 'error');
                return;
            }
            
            if (!qrCode) {
                showMessage('缺少二维码参数，请重新扫描二维码', 'error');
                return;
            }
            
            // 显示加载状态
            document.getElementById('loginBtn').disabled = true;
            document.getElementById('loading').style.display = 'block';
            
            // 发送登录请求
            fetch('/mobile/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    password: password,
                    qrCode: qrCode
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showMessage('登录成功！正在跳转...', 'success');
                    console.log('登录成功，准备跳转到:', '/mobile/checkin');
                    setTimeout(() => {
                        console.log('开始跳转到移动端打卡页面');
                        window.location.href = '/mobile/checkin';
                    }, 1500);
                } else {
                    showMessage(data.message || '登录失败', 'error');
                }
            })
            .catch(error => {
                console.error('登录错误:', error);
                showMessage('网络错误，请稍后重试', 'error');
            })
            .finally(() => {
                // 隐藏加载状态
                document.getElementById('loginBtn').disabled = false;
                document.getElementById('loading').style.display = 'none';
            });
        });
        
        function showMessage(message, type) {
            const messageArea = document.getElementById('messageArea');
            const className = type === 'error' ? 'error-message' : 'success-message';
            messageArea.innerHTML = '<div class="' + className + '">' + message + '</div>';
            
            // 3秒后自动清除消息
            setTimeout(() => {
                messageArea.innerHTML = '';
            }, 3000);
        }
        
        // 页面加载完成后聚焦到密码输入框
        window.addEventListener('load', function() {
            document.getElementById('password').focus();
        });
    </script>
</body>
</html>
