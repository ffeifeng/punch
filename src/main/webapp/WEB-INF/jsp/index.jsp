<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>学生打卡系统 - 首页</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/metro/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>
    <style>
        body {
            background: #e6fffa;
            margin: 0;
        }
        .header {
            background: linear-gradient(120deg, #4fd1c5 0%, #38b2ac 100%);
            color: #fff;
            padding: 18px 32px;
            font-size: 1.5rem;
            font-weight: bold;
            letter-spacing: 2px;
        }
        .main-content {
            padding: 32px;
        }
    </style>
</head>
<body>
<div class="header">学生打卡系统</div>
<div class="main-content">
    <div class="easyui-panel" title="欢迎" style="width:100%;max-width:600px;margin:auto;">
        <p>欢迎使用学生打卡系统！</p>
        <p>请通过左侧菜单进入各功能模块。</p>
    </div>
</div>
</body>
</html>
