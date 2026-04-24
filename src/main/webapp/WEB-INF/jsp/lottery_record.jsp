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
        <a href="javascript:void(0)" class="easyui-linkbutton"
           style="background:#e67e22;border-color:#d35400;color:#fff;margin-left:8px;"
           onclick="openBatchRedeem()">📦 批量兑奖</a>
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
        return '<a href="javascript:void(0)" onclick="toggleRedeem(' + row.id + ',0)"'
            + ' style="color:#999;text-decoration:none;" title="点击撤回为未兑奖">✅ 已兑奖</a>';
    }
    return '<a href="javascript:void(0)" onclick="toggleRedeem(' + row.id + ',1)"'
        + ' style="color:#e67e22;font-weight:bold;" title="点击标记为已兑奖">⏳ 未兑奖</a>';
}

function toggleRedeem(id, newStatus) {
    $.post('/lottery/record/toggleRedeem', { id: id, isRedeemed: newStatus }, function(res) {
        if (res.success) {
            $('#recordTable').datagrid('reload');
        } else {
            $.messager.alert('错误', '操作失败', 'error');
        }
    }, 'json');
}

function openBatchRedeem() {
    var sid = $('#search_student').combobox('getValue') || '';
    var url = '/lottery/record/unredeemedSummary' + (sid ? '?studentId=' + sid : '');
    $.get(url, function(res) {
        if (!res.success || !res.list || res.list.length === 0) {
            $.messager.alert('提示', '当前没有未兑奖记录', 'info');
            return;
        }
        var rows = res.list.map(function(item) {
            return '<label style="display:flex;align-items:center;gap:8px;padding:8px 0;border-bottom:1px solid #f0f0f0;cursor:pointer;">'
                + '<input type="checkbox" class="batch-item-chk" value="' + item.itemId + '">'
                + '<span style="flex:1;font-size:0.95rem;">' + item.itemName + '</span>'
                + '<span style="background:#fed7aa;color:#9c4221;border-radius:10px;padding:2px 10px;font-size:0.82rem;font-weight:bold;">'
                + item.cnt + ' 条</span>'
                + '</label>';
        }).join('');
        var total = res.list.reduce(function(s, i){ return s + parseInt(i.cnt); }, 0);
        $('#batchRedeemBody').html(
            '<div style="margin-bottom:10px;color:#718096;font-size:0.88rem;">勾选要批量兑奖的奖品（共 <strong style="color:#e67e22;">'
            + total + '</strong> 条未兑奖）：</div>'
            + '<div style="margin-bottom:10px;">'
            + '<label style="cursor:pointer;font-size:0.88rem;color:#4a5568;">'
            + '<input type="checkbox" id="batchChkAll" onchange="toggleAllBatch(this)"> 全选/取消全选</label>'
            + '</div>'
            + rows
        );
        $('#batchRedeemDlg').dialog('open');
    });
}
function toggleAllBatch(chk) {
    $('.batch-item-chk').prop('checked', chk.checked);
}
function doBatchRedeem() {
    var ids = [];
    $('.batch-item-chk:checked').each(function(){ ids.push(parseInt($(this).val())); });
    if (ids.length === 0) { $.messager.alert('提示', '请至少选择一种奖品', 'warning'); return; }
    var sid = $('#search_student').combobox('getValue') || '';
    $.ajax({
        url: '/lottery/record/batchRedeem', type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ itemIds: ids, studentId: sid }),
        success: function(res) {
            if (res.success) {
                $('#batchRedeemDlg').dialog('close');
                $.messager.show({ title: '成功', msg: res.message, showType: 'slide', timeout: 3000 });
                $('#recordTable').datagrid('reload');
            } else {
                $.messager.alert('失败', res.message || '操作失败', 'error');
            }
        }
    });
}
</script>

<!-- 批量兑奖对话框 -->
<div id="batchRedeemDlg" class="easyui-dialog" style="width:420px;max-height:500px;" closed="true"
     data-options="title:'📦 批量兑奖',modal:true,resizable:false,buttons:'#batchRedeemBtns'">
    <div id="batchRedeemBody" style="padding:16px 20px;max-height:380px;overflow-y:auto;"></div>
</div>
<div id="batchRedeemBtns" style="text-align:center;">
    <a href="javascript:void(0)" class="easyui-linkbutton"
       style="background:#e67e22;border-color:#d35400;color:#fff;width:90px;margin-right:10px;"
       onclick="doBatchRedeem()">✅ 确认兑奖</a>
    <a href="javascript:void(0)" class="easyui-linkbutton" style="width:70px;"
       onclick="$('#batchRedeemDlg').dialog('close')">取消</a>
</div>

</body>
</html>
