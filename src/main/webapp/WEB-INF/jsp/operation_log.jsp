<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>操作日志 - 学生打卡系统</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js">
var ctx = '${pageContext.request.contextPath}';</script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js">
var ctx = '${pageContext.request.contextPath}';</script>
    <style>
        body { background: #e6fffa; margin: 0; }
        .header { background: linear-gradient(120deg, #4fd1c5 0%, #38b2ac 100%); color: #fff; padding: 18px 32px; font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
        .main-content { padding: 32px; }
    </style>
</head>
<body>
<div class="header">操作日志</div>
<div class="main-content">
    <div style="margin-bottom:16px;">
        <input id="search_userName" class="easyui-textbox" prompt="操作人姓�? style="width:120px;">
        <input id="search_operation" class="easyui-textbox" prompt="操作类型" style="width:120px;">
        <input id="search_content" class="easyui-textbox" prompt="操作内容" style="width:150px;">
        <input id="search_ip" class="easyui-textbox" prompt="IP地址" style="width:120px;">
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="doSearch()">查询</a>
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="clearSearch()">清空</a>
    </div>
    <table id="logTable" class="easyui-datagrid" style="width:100%;height:480px;"
           data-options="url:'/operationLog/list',method:'get',pagination:true,rownumbers:true,singleSelect:true,fitColumns:true">
        <thead>
        <tr>
            <th data-options="field:'id',width:40">ID</th>
            <th data-options="field:'userName',width:100">操作�?/th>
            <th data-options="field:'operation',width:100">操作类型</th>
            <th data-options="field:'targetType',width:80">目标类型</th>
            <th data-options="field:'targetId',width:80">目标ID</th>
            <th data-options="field:'content',width:180">内容</th>
            <th data-options="field:'ip',width:100">IP</th>
            <th data-options="field:'createTime',width:120">时间</th>
        </tr>
        </thead>
    </table>
</div>
<script>
var ctx = '${pageContext.request.contextPath}';
function doSearch() {
    $('#logTable').datagrid('load', {
        userName: $('#search_userName').textbox('getValue'),
        operation: $('#search_operation').textbox('getValue'),
        content: $('#search_content').textbox('getValue'),
        ip: $('#search_ip').textbox('getValue')
    });
}

function clearSearch() {
    $('#search_userName').textbox('setValue', '');
    $('#search_operation').textbox('setValue', '');
    $('#search_content').textbox('setValue', '');
    $('#search_ip').textbox('setValue', '');
    $('#logTable').datagrid('load', {});
}
</script>
</body>
</html>
