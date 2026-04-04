<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>学生二维码</title>
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
        
        .qr-container {
            background: white;
            border-radius: 20px;
            padding: 40px 30px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 400px;
            width: 100%;
        }
        
        .logo {
            font-size: 3rem;
            margin-bottom: 20px;
        }
        
        .title {
            font-size: 1.5rem;
            color: #333;
            margin-bottom: 10px;
            font-weight: 600;
        }
        
        .student-name {
            font-size: 1.2rem;
            color: #667eea;
            margin-bottom: 30px;
            font-weight: 500;
        }
        
        .qr-code {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 30px;
            border: 2px solid #e9ecef;
        }
        
        .qr-placeholder {
            width: 200px;
            height: 200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            color: #6c757d;
            border: 2px dashed #dee2e6;
        }
        
        .instructions {
            background: #e6fffa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 4px solid #4fd1c5;
            text-align: left;
        }
        
        .instructions h4 {
            margin: 0 0 10px 0;
            color: #2d3748;
            font-size: 1.1rem;
        }
        
        .instructions ol {
            margin: 0;
            padding-left: 20px;
            color: #4a5568;
        }
        
        .instructions li {
            margin-bottom: 8px;
            line-height: 1.5;
        }
        
        .login-link {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            padding: 12px 24px;
            border-radius: 25px;
            font-weight: 600;
            transition: transform 0.2s;
        }
        
        .login-link:hover {
            transform: translateY(-2px);
            text-decoration: none;
            color: white;
        }
        
        .qr-info {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-top: 20px;
            font-size: 12px;
            color: #6c757d;
            word-break: break-all;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            border-left: 4px solid #dc3545;
        }
    </style>
    <!-- 引入QRCode.js库 -->
    <script src="${pageContext.request.contextPath}/static/js/qrcode/qrcode.min.js" onerror="console.error('QRCode.js加载失败，路径：', this.src)"></script>
</head>
<body>
    <div class="qr-container">
        <div class="logo">📱</div>
        <div class="title">学生打卡二维码</div>
        
        <div id="studentInfo" style="display:none;">
            <div class="student-name" id="studentName"></div>
            
            <div class="qr-code">
                <canvas id="qrCanvas" style="display:none; width:200px; height:200px; border-radius:10px; border:1px solid #e9ecef;"></canvas>
                <div id="qrDiv" style="display:none; width:200px; height:200px; margin:0 auto; border-radius:10px; overflow:hidden;"></div>
                <div class="qr-placeholder" id="qrPlaceholder">
                    正在生成二维码...
                </div>
            </div>
            
            <div class="instructions">
                <h4>📋 使用说明</h4>
                <ol>
                    <li>使用手机或平板扫描上方二维码</li>
                    <li>在打开的页面中输入您的密码</li>
                    <li>登录成功后即可进行打卡操作</li>
                    <li>查看当日打卡事项和总积分</li>
                </ol>
            </div>
            
            <a href="#" id="directLoginLink" class="login-link">
                🔗 直接登录
            </a>
            
            <div class="qr-info">
                <strong>二维码信息：</strong><br>
                <span id="qrCodeValue"></span>
            </div>
        </div>
        
        <div id="errorInfo" class="error-message" style="display:none;">
            <strong>❌ 错误</strong><br>
            <span id="errorMessage"></span>
        </div>
    </div>

    <script>
        // 从URL参数获取二维码
        const urlParams = new URLSearchParams(window.location.search);
        const qrCode = urlParams.get('qr');
        
        // 检查QRCode.js是否正确加载
        console.log('QRCode库加载状态:', typeof QRCode !== 'undefined' ? '已加载' : '未加载');
        if (typeof QRCode !== 'undefined') {
            console.log('QRCode对象:', QRCode);
            console.log('QRCode可用方法:', Object.getOwnPropertyNames(QRCode));
            console.log('QRCode.toCanvas存在:', typeof QRCode.toCanvas === 'function');
            console.log('QRCode.toDataURL存在:', typeof QRCode.toDataURL === 'function');
        }
        
        if (!qrCode) {
            showError('缺少二维码参数');
        } else {
            loadStudentInfo(qrCode);
        }
        
        function loadStudentInfo(qrCode) {
            console.log('正在加载学生信息，二维码:', qrCode);
            
            // 通过二维码获取学生信息
            fetch('/user/getStudentByQrCode?qrCode=' + encodeURIComponent(qrCode))
                .then(response => {
                    console.log('API响应状态:', response.status);
                    return response.json();
                })
                .then(data => {
                    console.log('API响应数据:', data);
                                    if (data.success) {
                    showStudentInfo(data.student, qrCode);
                    // 生成登录页面的二维码，使用IP地址而不是localhost
                    const currentOrigin = window.location.origin;
                    let qrUrl;
                    
                    if (currentOrigin.includes('localhost') || currentOrigin.includes('127.0.0.1')) {
                        // 如果当前是localhost，替换为实际IP地址
                        qrUrl = currentOrigin.replace('localhost', '192.168.101.57').replace('127.0.0.1', '192.168.101.57') + '/mobile/login?qr=' + encodeURIComponent(qrCode);
                    } else {
                        qrUrl = currentOrigin + '/mobile/login?qr=' + encodeURIComponent(qrCode);
                    }
                    
                    console.log('生成二维码URL:', qrUrl);
                    generateQRCode(qrUrl);
                } else {
                        showError(data.message || '无效的二维码');
                    }
                })
                .catch(error => {
                    console.error('加载学生信息失败:', error);
                    showError('加载失败，请稍后重试');
                });
        }
        
        function showStudentInfo(student, qrCode) {
            document.getElementById('studentName').textContent = student.realName + ' 同学';
            document.getElementById('qrCodeValue').textContent = qrCode;
            
            // 设置直接登录链接，使用IP地址
            const currentOrigin = window.location.origin;
            let loginUrl;
            
            if (currentOrigin.includes('localhost') || currentOrigin.includes('127.0.0.1')) {
                loginUrl = currentOrigin.replace('localhost', '192.168.101.57').replace('127.0.0.1', '192.168.101.57') + '/mobile/login?qr=' + encodeURIComponent(qrCode);
            } else {
                loginUrl = currentOrigin + '/mobile/login?qr=' + encodeURIComponent(qrCode);
            }
            
            document.getElementById('directLoginLink').href = loginUrl;
            console.log('直接登录链接:', loginUrl);
            
            document.getElementById('studentInfo').style.display = 'block';
        }
        
        function generateQRCode(url) {
            const canvas = document.getElementById('qrCanvas');
            const placeholder = document.getElementById('qrPlaceholder');
            
            console.log('正在生成二维码，URL:', url);
            
            // 使用QRCode.js库生成二维码
            if (typeof QRCode !== 'undefined') {
                try {
                    // 方法1：尝试使用toCanvas方法
                    if (typeof QRCode.toCanvas === 'function') {
                        console.log('使用QRCode.toCanvas方法');
                        QRCode.toCanvas(canvas, url, {
                            width: 200,
                            height: 200,
                            margin: 2,
                            color: {
                                dark: '#333333',
                                light: '#FFFFFF'
                            },
                            errorCorrectionLevel: 'M'
                        }, function (error) {
                            if (error) {
                                console.error('QRCode.toCanvas失败:', error);
                                tryAlternativeMethod();
                            } else {
                                console.log('二维码生成成功');
                                placeholder.style.display = 'none';
                                canvas.style.display = 'block';
                            }
                        });
                        return;
                    }
                    
                    // 方法2：尝试使用构造函数方式
                    else if (typeof QRCode === 'function') {
                        console.log('使用QRCode构造函数方法');
                        try {
                            // 直接使用页面上的div
                            const qrDiv = document.getElementById('qrDiv');
                            console.log('qrDiv元素:', qrDiv);
                            qrDiv.innerHTML = ''; // 清空内容
                            
                            console.log('创建QRCode实例，参数:', {
                                text: url,
                                width: 200,
                                height: 200,
                                colorDark: '#333333',
                                colorLight: '#FFFFFF',
                                correctLevel: QRCode.CorrectLevel ? QRCode.CorrectLevel.M : 0
                            });
                            
                            const qr = new QRCode(qrDiv, {
                                text: url,
                                width: 200,
                                height: 200,
                                colorDark: '#333333',
                                colorLight: '#FFFFFF',
                                correctLevel: QRCode.CorrectLevel ? QRCode.CorrectLevel.M : 0
                            });
                            
                            console.log('QRCode实例创建完成:', qr);
                            
                            // 检查div内容
                            setTimeout(() => {
                                console.log('qrDiv内容:', qrDiv.innerHTML);
                                console.log('qrDiv子元素数量:', qrDiv.children.length);
                                
                                if (qrDiv.children.length > 0) {
                                    // 直接显示div，不需要转换到canvas
                                    placeholder.style.display = 'none';
                                    qrDiv.style.display = 'block';
                                    console.log('二维码生成成功（构造函数方式）');
                                } else {
                                    console.error('二维码div为空，尝试其他方法');
                                    tryAlternativeMethod();
                                }
                            }, 200);
                            
                            return;
                        } catch (error) {
                            console.error('构造函数方式失败:', error);
                            tryAlternativeMethod();
                        }
                    }
                    
                    // 方法3：尝试其他可能的API
                    else {
                        tryAlternativeMethod();
                    }
                    
                } catch (error) {
                    console.error('QRCode.js调用失败:', error);
                    tryAlternativeMethod();
                }
            } else {
                console.warn('QRCode.js库未加载');
                showQRCodeFallback();
            }
            
            function tryAlternativeMethod() {
                console.log('尝试备用二维码生成方法');
                
                // 尝试使用toDataURL方法
                if (typeof QRCode.toDataURL === 'function') {
                    QRCode.toDataURL(url, {
                        width: 200,
                        height: 200,
                        margin: 2,
                        color: {
                            dark: '#333333',
                            light: '#FFFFFF'
                        }
                    }, function (error, dataURL) {
                        if (error) {
                            console.error('QRCode.toDataURL失败:', error);
                            showQRCodeFallback();
                        } else {
                            // 将DataURL绘制到canvas上
                            const img = new Image();
                            img.onload = function() {
                                const ctx = canvas.getContext('2d');
                                canvas.width = 200;
                                canvas.height = 200;
                                ctx.drawImage(img, 0, 0, 200, 200);
                                placeholder.style.display = 'none';
                                canvas.style.display = 'block';
                                console.log('二维码生成成功（DataURL方式）');
                            };
                            img.src = dataURL;
                        }
                    });
                } else {
                    showQRCodeFallback();
                }
            }
            
            function showQRCodeFallback() {
                placeholder.innerHTML = `
                    <div style="text-align:center;padding:20px;">
                        <div style="font-size:3rem;margin-bottom:15px;">📱</div>
                        <div style="color:#333;font-size:16px;font-weight:600;margin-bottom:15px;">学生专用登录</div>
                        <div style="background:linear-gradient(135deg, #667eea 0%, #764ba2 100%);color:white;border-radius:10px;padding:15px;margin:10px 0;">
                            <div style="font-size:14px;font-weight:600;">快速登录链接</div>
                            <div style="font-size:12px;margin-top:5px;opacity:0.9;">点击下方按钮直接登录</div>
                        </div>
                        <div style="color:#6c757d;font-size:12px;">暂时无法生成二维码图片</div>
                        <div style="color:#6c757d;font-size:12px;margin-top:5px;">请使用下方登录按钮</div>
                    </div>
                `;
            }
        }
        
        function showError(message) {
            document.getElementById('errorMessage').textContent = message;
            document.getElementById('errorInfo').style.display = 'block';
        }
    </script>
</body>
</html>
