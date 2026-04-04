<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.punch.entity.User" %>
<%
    User user = (User) session.getAttribute("user");
    boolean isParent = user != null && user.getParentId() == null && !"admin".equals(user.getUsername());
%>
<!DOCTYPE html>
<html>
<head>
    <title>抽奖记录 - 学生打卡系统</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>
    <style>
        body { background: #e6fffa; margin: 0; }
        .header { background: linear-gradient(120deg, #4fd1c5 0%, #38b2ac 100%); color: #fff; padding: 18px 32px; font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
        .main-content { padding: 24px 32px; }
    </style>
</head>
<body>
<div class="header">🎁 抽奖记录</div>
<div class="main-content">
    <div style="margin-bottom:16px;">
        <select id="search_student" class="easyui-combobox" prompt="选择孩子" style="width:130px;"
                data-options="valueField:'id',textField:'text',editable:false" id="studentFilter">
        </select>
        <select id="search_redeemed" class="easyui-combobox" prompt="兑奖状态" style="width:110px;"
                data-options="editable:false,valueField:'value',textField:'label',data:[{value:'',label:'全部'},{value:0,label:'未兑换'},{value:1,label:'已兑换'}]">
        </select>
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="doSearch()">查询</a>
    </div>
    <table id="recordTable" class="easyui-datagrid" style="width:100%;height:500px;"
           data-options="url:'/lottery/record/list',method:'get',pagination:true,rownumbers:true,singleSelect:true,fitColumns:true">
        <thead>
        <tr>
            <th data-options="field:'id',width:50">ID</th>
            <th data-options="field:'studentName',width:90">孩子姓名</th>
            <th data-options="field:'itemName',width:140">奖品名称</th>
            <th data-options="field:'lotteryTime',width:140">抽奖时间</th>
            <th data-options="field:'isRedeemed',width:90,formatter:formatRedeemed">兑奖状态</th>
            <th data-options="field:'redeemedTime',width:140">兑换时间</th>
            <th data-options="field:'redeemedByName',width:90">兑换人</th>
            <th data-options="field:'operation',width:100,formatter:formatOp">操作</th>
        </tr>
        </thead>
    </table>
</div>

<script>
$(document).ready(function() {
    // 加载孩子列表
    $.get('/user/getStudentList', function(data) {
        var studentData = [{id: '', text: '全部孩子'}];
        if (data && data.length > 0) {
            data.forEach(function(s) {
                studentData.push({ id: s.id, text: s.realName });
            });
        }
        $('#search_student').combobox('loadData', studentData);
        $('#search_student').combobox('setValue', '');
    });
});

function doSearch() {
    var params = {};
    var sid = $('#search_student').combobox('getValue');
    if (sid) params.studentId = sid;
    var redeemed = $('#search_redeemed').combobox('getValue');
    if (redeemed !== '') params.isRedeemed = redeemed;
    $('#recordTable').datagrid('load', params);
}

function formatRedeemed(val) {
    return val == 1
        ? '<span style="color:#38a169;font-weight:bold;">✅ 已兑换</span>'
        : '<span style="color:#e67e22;font-weight:bold;">⏳ 未兑换</span>';
}

function formatOp(val, row) {
    if (row.isRedeemed == 1) {
        return '<span style="color:#999;">已兑奖</span>';
    }
    return '<a href="javascript:void(0)" onclick="redeemRecord(' + row.id + ')" '
        + 'style="color:#38b2ac;font-weight:bold;">✅ 已兑奖</a>';
}

function redeemRecord(id) {
    $.messager.confirm('确认', '确认该奖品已经发放给孩子了吗？', function(r) {
        if (r) {
            $.post('/lottery/record/redeem', { id: id }, function(res) {
                if (res.success) {
                    $.messager.show({ title: '成功', msg: '已标记为已兑奖', showType: 'slide', timeout: 2000 });
                    $('#recordTable').datagrid('reload');
                } else {
                    $.messager.alert('错误', '操作失败', 'error');
                }
            });
        }
    });
}
</script>
</body>
</html>
