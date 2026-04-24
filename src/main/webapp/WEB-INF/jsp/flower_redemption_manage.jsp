<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>小红花兑换审批</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>
    <style>
        body { background:#fff0f6; margin:0; }
        .header { background:linear-gradient(120deg,#ff758c,#ff7eb3); color:#fff; padding:18px 32px; font-size:1.4rem; font-weight:bold; }
        .main-content { padding:24px 32px; }
        .pending-badge { background:#e53e3e; color:#fff; border-radius:10px; padding:2px 8px; font-size:0.8rem; margin-left:6px; }
    </style>
</head>
<body>
<div class="header">🌸 小红花兑换审批
    <span class="pending-badge" id="pendingBadge" style="display:none;"></span>
</div>
<div class="main-content">
    <div style="margin-bottom:12px;display:flex;gap:8px;align-items:center;">
        <span style="font-size:0.9rem;color:#4a5568;">状态筛选：</span>
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="loadRedemptions(null)">全部</a>
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="loadRedemptions(0)">⏳ 待审批</a>
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="loadRedemptions(1)">✅ 已审批</a>
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="loadRedemptions(2)">❌ 已撤销</a>
    </div>
    <table id="redemptionTable" class="easyui-datagrid" style="width:100%;height:500px;"
           data-options="rownumbers:true,singleSelect:true,fitColumns:true">
        <thead><tr>
            <th data-options="field:'id',width:60">ID</th>
            <th data-options="field:'studentId',width:80,formatter:fmtStudent">孩子</th>
            <th data-options="field:'itemName',width:120">项目</th>
            <th data-options="field:'flowerCost',width:80,formatter:fmtCost">消耗</th>
            <th data-options="field:'timeMinutes',width:90,formatter:fmtTime">时长</th>
            <th data-options="field:'status',width:90,formatter:fmtStatus">状态</th>
            <th data-options="field:'redeemTime',width:140,formatter:fmtTime2">申请时间</th>
            <th data-options="field:'confirmTime',width:140,formatter:fmtTime2">审批时间</th>
            <th data-options="field:'op',width:140,formatter:fmtOp">操作</th>
        </tr></thead>
    </table>
</div>

<script>
var studentNames = {};
// 先加载学生列表
$.get('/user/studentList', function(data) {
    if (data) data.forEach(function(s){ studentNames[s.id] = s.realName || s.username; });
    loadRedemptions(null);
});

function loadRedemptions(status) {
    var url = '/flower/manage/redemptions' + (status != null ? '?status=' + status : '');
    $.get(url, function(data) {
        if (data.success) {
            $('#redemptionTable').datagrid('loadData', data.list || []);
            if (data.pendingCount > 0) {
                $('#pendingBadge').text(data.pendingCount + ' 待审批').show();
            } else {
                $('#pendingBadge').hide();
            }
        }
    });
}
function fmtStudent(val) { return studentNames[val] || ('ID:' + val); }
function fmtCost(val) { return '🌸×' + (val||0); }
function fmtTime(val) { return val ? val + ' 分钟' : '-'; }
function fmtTime2(val) { return val ? new Date(val).toLocaleString('zh-CN',{month:'numeric',day:'numeric',hour:'numeric',minute:'numeric'}) : '-'; }
function fmtStatus(val) {
    if (val == 0) return '<span style="color:#d69e2e;font-weight:bold;">⏳ 待审批</span>';
    if (val == 1) return '<span style="color:#38a169;font-weight:bold;">✅ 已审批</span>';
    if (val == 2) return '<span style="color:#a0aec0;">❌ 已撤销</span>';
    return val;
}
function fmtOp(val, row) {
    var btns = '';
    if (row.status == 0) {
        btns += '<a href="javascript:void(0)" onclick="doApprove(' + row.id + ')" style="color:#38a169;font-weight:bold;">✅ 审批</a> ';
    }
    if (row.status != 2) {
        btns += '<a href="javascript:void(0)" onclick="doRevoke(' + row.id + ')" style="color:#e53e3e;">↩️ 撤销</a>';
    }
    return btns || '-';
}
function doApprove(id) {
    $.messager.confirm('确认审批', '确认审批通过该兑换申请？', function(r) {
        if (!r) return;
        $.post('/flower/manage/redemption/approve', { id: id }, function(res) {
            if (res.success) {
                $.messager.show({ title:'成功', msg: res.message, showType:'slide', timeout:2000 });
                loadRedemptions(null);
            } else { $.messager.alert('失败', res.message || '操作失败', 'error'); }
        }, 'json');
    });
}
function doRevoke(id) {
    $.messager.confirm('确认撤销', '撤销后将退还孩子的小红花，确认吗？', function(r) {
        if (!r) return;
        $.post('/flower/manage/redemption/revoke', { id: id }, function(res) {
            if (res.success) {
                $.messager.show({ title:'成功', msg: res.message, showType:'slide', timeout:2000 });
                loadRedemptions(null);
            } else { $.messager.alert('失败', res.message || '操作失败', 'error'); }
        }, 'json');
    });
}
</script>
</body>
</html>
