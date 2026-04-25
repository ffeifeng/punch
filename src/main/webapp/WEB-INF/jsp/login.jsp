<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>学生打卡系统 - 登录</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/metro/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 25%, #f093fb 50%, #4facfe 75%, #00f2fe 100%);
            background-size: 400% 400%;
            animation: gradientBG 15s ease infinite;
            height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Microsoft YaHei', '微软雅黑', sans-serif;
            position: relative;
            overflow: hidden;
        }
        
        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        
        /* 可爱的浮动小图标背景 */
        .bg-icons {
            position: absolute;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 0;
        }
        
        .bg-icon {
            position: absolute;
            font-size: 40px;
            opacity: 0.15;
            animation: float 6s ease-in-out infinite;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(10deg); }
        }
        
        .login-panel {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3), 
                        0 0 0 1px rgba(255,255,255,0.1) inset;
            padding: 50px 40px 40px 40px;
            width: 420px;
            z-index: 1;
            animation: slideIn 0.6s ease-out;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .login-title {
            font-size: 2.2rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            text-align: center;
            margin-bottom: 12px;
            font-weight: bold;
            letter-spacing: 2px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .login-subtitle {
            text-align: center;
            color: #718096;
            font-size: 0.9rem;
            margin-bottom: 32px;
        }
        
        .login-icon {
            font-size: 3rem;
            text-align: center;
            margin-bottom: 20px;
            animation: bounce 2s ease-in-out infinite;
        }
        
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
        
        .input-group {
            margin-bottom: 24px;
            position: relative;
        }
        
        .input-label {
            display: block;
            margin-bottom: 10px;
            color: #4a5568;
            font-weight: 600;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .input-wrapper {
            position: relative;
        }
        
        /* 美化EasyUI输入框 */
        .textbox {
            border-radius: 12px !important;
            border: 2px solid #e2e8f0 !important;
            transition: all 0.3s ease !important;
        }
        
        .textbox:hover {
            border-color: #cbd5e0 !important;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15) !important;
        }
        
        .textbox-focused {
            border-color: #667eea !important;
            box-shadow: 0 4px 20px rgba(102, 126, 234, 0.25) !important;
        }
        
        .easyui-linkbutton {
            width: 100%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
            border: none !important;
            border-radius: 12px !important;
            padding: 14px !important;
            font-size: 1.1rem !important;
            font-weight: 700 !important;
            letter-spacing: 2px !important;
            transition: all 0.3s ease !important;
            box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4) !important;
            color: white !important;
            text-align: center !important;
        }
        
        .easyui-linkbutton .l-btn-text {
            font-size: 1.1rem !important;
            font-weight: 700 !important;
            color: white !important;
            line-height: 1.5 !important;
        }
        
        .easyui-linkbutton:hover {
            transform: translateY(-2px) !important;
            box-shadow: 0 12px 32px rgba(102, 126, 234, 0.5) !important;
        }
        
        .easyui-linkbutton:active {
            transform: translateY(0) !important;
        }
        
        .register-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            font-size: 0.95rem;
        }
        
        .register-link:hover {
            color: #764ba2;
            transform: scale(1.05);
        }
        
        .captcha-container {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 12px;
        }
        
        .captcha-image {
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            cursor: pointer;
            height: 48px;
            width: 140px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .captcha-image:hover {
            transform: scale(1.05);
            border-color: #667eea;
            box-shadow: 0 6px 16px rgba(102, 126, 234, 0.3);
        }
        
        .captcha-refresh {
            color: #667eea;
            font-size: 0.85rem;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s ease;
            font-weight: 500;
        }
        
        .captcha-refresh:hover {
            color: #764ba2;
            transform: scale(1.05);
        }
        
        /* 修复EasyUI提示框层级问题 */
        .textbox-prompt {
            z-index: 1 !important;
        }
        .validatebox-tip {
            z-index: 1 !important;
        }
        
        /* 错误提示样式 */
        .error-message {
            background: linear-gradient(135deg, #fee 0%, #fcc 100%);
            border: none;
            color: #c33;
            padding: 14px 18px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-size: 0.95rem;
            display: none;
            animation: shake 0.5s, fadeIn 0.3s;
            box-shadow: 0 4px 16px rgba(204, 51, 51, 0.2);
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            10%, 30%, 50%, 70%, 90% { transform: translateX(-8px); }
            20%, 40%, 60%, 80% { transform: translateX(8px); }
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .success-message {
            background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
            border: none;
            color: #155724;
            padding: 14px 18px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-size: 0.95rem;
            display: none;
            animation: fadeIn 0.3s;
            box-shadow: 0 4px 16px rgba(21, 87, 36, 0.2);
        }
    </style>
</head>
<body>
<!-- 可爱的浮动背景图标 -->
<div class="bg-icons">
    <div class="bg-icon" style="left: 10%; top: 20%; animation-delay: 0s;">📚</div>
    <div class="bg-icon" style="left: 80%; top: 15%; animation-delay: 1s;">✨</div>
    <div class="bg-icon" style="left: 15%; top: 70%; animation-delay: 2s;">🎯</div>
    <div class="bg-icon" style="left: 85%; top: 65%; animation-delay: 3s;">🌟</div>
    <div class="bg-icon" style="left: 50%; top: 10%; animation-delay: 1.5s;">💡</div>
    <div class="bg-icon" style="left: 60%; top: 85%; animation-delay: 2.5s;">🎨</div>
</div>
<div class="login-panel">
    <div class="login-icon">🎓</div>
    <div class="login-title">
        学生打卡系统
    </div>
    <div class="login-subtitle">✨ 让学习更有趣，让成长更精彩 ✨</div>
    <div id="errorMessage" class="error-message"></div>
    <div id="successMessage" class="success-message"></div>
    <form id="loginForm" method="post" action="/login">
        <!-- 隐藏字段用于传递错误信息 -->
        <input type="hidden" name="errorMessage" value="${errorMessage}" />
        <div class="input-group">
            <label class="input-label">
                <span>👤</span>
                <span>用户名</span>
            </label>
            <div class="input-wrapper">
                <input class="easyui-textbox" name="username" style="width:100%;height:48px" 
                       data-options="prompt:'请输入用户名',iconCls:'icon-man',required:true" 
                       placeholder="请输入用户名">
            </div>
        </div>
        <div class="input-group">
            <label class="input-label">
                <span>🔒</span>
                <span>密码</span>
            </label>
            <div class="input-wrapper">
                <input class="easyui-textbox" name="password" type="password" style="width:100%;height:48px" 
                       data-options="prompt:'请输入密码',iconCls:'icon-lock',required:true" 
                       placeholder="请输入密码">
            </div>
        </div>
        <div class="input-group">
            <label class="input-label">
                <span>🔐</span>
                <span>验证码</span>
            </label>
            <div class="input-wrapper">
                <input class="easyui-textbox" name="captcha" style="width:100%;height:48px" 
                       data-options="prompt:'请输入验证码',iconCls:'icon-ok',required:true" 
                       placeholder="请输入验证码">
            </div>
            <div class="captcha-container">
                <img id="captchaImage" onclick="refreshCaptcha()" title="点击刷新验证码"
                     class="captcha-image" alt="验证码">
                <a href="javascript:refreshCaptcha()" class="captcha-refresh">
                    🔄 换一张
                </a>
            </div>
        </div>
        <a id="loginBtn" href="javascript:void(0)" class="easyui-linkbutton" 
           style="height:52px;width:100%;display:flex;align-items:center;justify-content:center;font-size:1.15rem;font-weight:700;color:white;" 
           onclick="$('#loginForm').submit();">🚀 登 录</a>
    </form>
    <a class="register-link" href="/register">📝 家长注册</a>
</div>
<script>
$(document).ready(function() {
    // 刷新验证码
    refreshCaptcha();
    
    // 延迟初始化，确保EasyUI组件加载完成
    setTimeout(function() {
        // 回车键触发登录
        $(document).on('keydown', function(e) {
            if (e.key === 'Enter' || e.keyCode === 13) {
                e.preventDefault();
                $('#loginForm').submit();
            }
        });

        // 监听表单提交
        $('#loginForm').submit(function(e) {
            e.preventDefault(); // 阻止默认提交
            
            // 获取表单数据 - 使用更安全的方式
            var username = '';
            var password = '';
            var captcha = '';
            
            try {
                // 尝试使用textbox方法获取
                username = $('input[name="username"]').textbox('getValue');
                password = $('input[name="password"]').textbox('getValue');
                captcha = $('input[name="captcha"]').textbox('getValue');
            } catch(e) {
                // 如果textbox未初始化，使用val方法
                username = $('input[name="username"]').val();
                password = $('input[name="password"]').val();
                captcha = $('input[name="captcha"]').val();
            }
            
            // 前端验证
            if (!username || username.trim() === '') {
                showError('❌ 请输入用户名');
                return false;
            }
            if (!password || password.trim() === '') {
                showError('❌ 请输入密码');
                return false;
            }
            if (!captcha || captcha.trim() === '') {
                showError('❌ 请输入验证码');
                return false;
            }
            
            // 禁用提交按钮
            try {
                $('#loginBtn').linkbutton('disable');
            } catch(e) {
                $('#loginBtn').attr('disabled', true);
            }
            
            // Ajax提交
            $.ajax({
                url: '/login',
                type: 'POST',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                },
                data: {
                    username: username,
                    password: password,
                    captcha: captcha
                },
                success: function(response, textStatus, xhr) {
                    console.log('Success callback - textStatus:', textStatus);
                    console.log('Response type:', typeof response);
                    console.log('Response length:', response ? response.length : 0);
                    
                    // 检查是否为重定向或者成功响应
                    var responseURL = xhr.getResponseHeader('X-Redirect-URL');
                    
                    // 如果返回的是HTML
                    if (typeof response === 'string' && response.indexOf('<!DOCTYPE') >= 0) {
                        console.log('Response is HTML');
                        // 检查是否包含登录表单（说明是返回login页面，即登录失败）
                        if (response.indexOf('id="loginForm"') >= 0) {
                            console.log('Contains loginForm - Login failed');
                            // 登录失败，从返回的HTML中提取后端errorMessage
                            var parser = new DOMParser();
                            var doc = parser.parseFromString(response, 'text/html');
                            var errorInput = doc.querySelector('input[name="errorMessage"]');
                            var errorMsg = '❌ 登录失败';
                            
                            if (errorInput && errorInput.value && errorInput.value !== '') {
                                errorMsg = '❌ ' + errorInput.value;
                            }
                            
                            showError(errorMsg);
                            refreshCaptcha();
                            try {
                                $('#loginBtn').linkbutton('enable');
                            } catch(e) {
                                $('#loginBtn').attr('disabled', false);
                            }
                        } else {
                            console.log('No loginForm - Login success');
                            // 返回的是其他页面（如main页面），说明登录成功
                            showSuccess('✅ 登录成功，正在跳转...');
                            setTimeout(function() {
                                window.location.href = '/main';
                            }, 500);
                        }
                    } else {
                        console.log('Response is not HTML - Login success');
                        // 非HTML响应，登录成功
                        showSuccess('✅ 登录成功，正在跳转...');
                        setTimeout(function() {
                            window.location.href = '/main';
                        }, 500);
                    }
                },
                error: function(xhr) {
                    console.log('Error callback - status:', xhr.status);
                    console.log('Error callback - statusText:', xhr.statusText);
                    if (xhr.status === 302 || xhr.status === 0) {
                        // 重定向，登录成功
                        showSuccess('✅ 登录成功，正在跳转...');
                        setTimeout(function() {
                            window.location.href = '/main';
                        }, 500);
                    } else {
                        showError('❌ 登录失败，请检查输入信息');
                        refreshCaptcha();
                        try {
                            $('#loginBtn').linkbutton('enable');
                        } catch(e) {
                            $('#loginBtn').attr('disabled', false);
                        }
                    }
                }
            });
            
            return false;
        });
    }, 200);
});

// 显示错误信息
function showError(message) {
    $('#errorMessage').html(message).fadeIn();
    setTimeout(function() {
        $('#errorMessage').fadeOut();
    }, 3000);
}

// 显示成功信息
function showSuccess(message) {
    $('#successMessage').html(message).fadeIn();
}

// 刷新验证码图片
function refreshCaptcha() {
    $('#captchaImage').attr('src', '/captcha/image?t=' + new Date().getTime());
}
</script>
</body>
</html>
