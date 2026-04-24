<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>小红花兑换项管理</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>
    <style>
        body { background:#fff0f6; margin:0; }
        .header { background:linear-gradient(120deg,#ff758c,#ff7eb3); color:#fff; padding:18px 32px; font-size:1.4rem; font-weight:bold; }
        .main-content { padding:24px 32px; }
        .tip-box { background:#fff; border-left:4px solid #ff758c; padding:12px 18px; margin-bottom:16px; border-radius:4px; color:#4a5568; font-size:0.9rem; }
    </style>
</head>
<body>
<div class="header">🌸 小红花兑换项目管理</div>
<div class="main-content">
    <div class="tip-box">
        💡 在这里配置孩子可以兑换的奖励项目，如：看电视（每次1朵花=15分钟，每天最多4次）、零食（每次2朵花，不限次数）等。
        配置后孩子在打卡页面的「小红花」入口即可申请兑换，需家长审批后生效。
    </div>
    <div style="margin-bottom:16px;">
        <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-add'" onclick="openAdd()">新增项目</a>
    </div>
    <table id="itemTable" class="easyui-datagrid" style="width:100%;height:480px;"
           data-options="url:'/flower/manage/items',method:'get',rownumbers:true,singleSelect:true,fitColumns:true">
        <thead><tr>
            <th data-options="field:'id',width:50">ID</th>
            <th data-options="field:'name',width:120">项目名称</th>
            <th data-options="field:'flowerCost',width:90,formatter:fmtCost">消耗(朵)</th>
            <th data-options="field:'timeMinutes',width:100,formatter:fmtTime">时长(分钟)</th>
            <th data-options="field:'dailyLimit',width:100,formatter:fmtLimit">每日上限</th>
            <th data-options="field:'description',width:200">说明</th>
            <th data-options="field:'status',width:70,formatter:fmtStatus">状态</th>
            <th data-options="field:'sortOrder',width:70">排序</th>
            <th data-options="field:'op',width:160,formatter:fmtOp">操作</th>
        </tr></thead>
    </table>
</div>

<!-- 新增/编辑对话框 -->
<div id="dlg" class="easyui-dialog" style="width:480px;padding:20px;" closed="true" buttons="#dlg-buttons"
     data-options="modal:true,resizable:false">
    <form id="fm" style="padding:0 10px;">
        <input type="hidden" id="fm_id" name="id">
        <div style="margin-bottom:14px;">
            <label style="display:block;margin-bottom:6px;font-weight:500;">🌸 项目名称 <span style="color:red">*</span></label>
            <input id="fm_name" name="name" type="text" placeholder="如：看电视、玩游戏、零食"
                   style="width:100%;height:34px;padding:0 10px;border:1px solid #d2d6dc;border-radius:4px;box-sizing:border-box;font-size:0.95rem;">
        </div>
        <div style="display:flex;gap:12px;margin-bottom:14px;">
            <div style="flex:1;">
                <label style="display:block;margin-bottom:6px;font-weight:500;">消耗小红花(朵) <span style="color:red">*</span></label>
                <input id="fm_flowerCost" name="flowerCost" type="number" min="1" placeholder="如：1"
                       style="width:100%;height:34px;padding:0 10px;border:1px solid #d2d6dc;border-radius:4px;box-sizing:border-box;font-size:0.95rem;">
            </div>
            <div style="flex:1;">
                <label style="display:block;margin-bottom:6px;font-weight:500;">时长(分钟，非时间类留空)</label>
                <input id="fm_timeMinutes" name="timeMinutes" type="number" min="1" placeholder="如：15，非时间类留空"
                       style="width:100%;height:34px;padding:0 10px;border:1px solid #d2d6dc;border-radius:4px;box-sizing:border-box;font-size:0.95rem;">
            </div>
        </div>
        <div style="display:flex;gap:12px;margin-bottom:14px;">
            <div style="flex:1;">
                <label style="display:block;margin-bottom:6px;font-weight:500;">每日上限(朵，留空=不限)</label>
                <input id="fm_dailyLimit" name="dailyLimit" type="number" min="1" placeholder="留空=不限制"
                       style="width:100%;height:34px;padding:0 10px;border:1px solid #d2d6dc;border-radius:4px;box-sizing:border-box;font-size:0.95rem;">
            </div>
            <div style="flex:1;">
                <label style="display:block;margin-bottom:6px;font-weight:500;">排序(越小越靠前)</label>
                <input id="fm_sortOrder" name="sortOrder" type="number" min="0" value="0"
                       style="width:100%;height:34px;padding:0 10px;border:1px solid #d2d6dc;border-radius:4px;box-sizing:border-box;font-size:0.95rem;">
            </div>
        </div>
        <div style="margin-bottom:14px;">
            <label style="display:block;margin-bottom:6px;font-weight:500;">说明（可选）</label>
            <input id="fm_description" name="description" type="text" placeholder="备注说明"
                   style="width:100%;height:34px;padding:0 10px;border:1px solid #d2d6dc;border-radius:4px;box-sizing:border-box;font-size:0.95rem;">
        </div>
        <div style="margin-bottom:6px;">
            <label style="display:block;margin-bottom:6px;font-weight:500;">状态</label>
            <select id="fm_status" name="status"
                    style="width:100%;height:36px;padding:0 10px;border:1px solid #d2d6dc;border-radius:4px;font-size:0.95rem;">
                <option value="1">✅ 启用</option>
                <option value="0">❌ 禁用</option>
            </select>
        </div>
    </form>
</div>
<div id="dlg-buttons" style="text-align:center;padding:10px;">
    <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-save'"
       style="width:80px;height:32px;margin-right:10px;" onclick="saveItem()">保存</a>
    <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-cancel'"
       style="width:80px;height:32px;" onclick="$('#dlg').dialog('close')">取消</a>
</div>

<script>
function fmtCost(val) { return '<span style="color:#ff758c;font-weight:bold;">🌸×' + (val||0) + '</span>'; }
function fmtTime(val) { return val ? val + ' 分钟' : '<span style="color:#a0aec0;">-</span>'; }
function fmtLimit(val) { return val ? '每日 ' + val + ' 次' : '<span style="color:#a0aec0;">不限</span>'; }
function fmtStatus(val) {
    return val == 1 ? '<span style="color:#38a169;font-weight:bold;">✅ 启用</span>'
                    : '<span style="color:#e53e3e;font-weight:bold;">❌ 禁用</span>';
}
function fmtOp(val, row) {
    return '<a href="javascript:void(0)" onclick="openEdit(' + row.id + ')">编辑</a> '
        + '<a href="javascript:void(0)" onclick="toggleStatus(' + row.id + ')">' + (row.status == 1 ? '禁用' : '启用') + '</a> '
        + '<a href="javascript:void(0)" onclick="delItem(' + row.id + ')" style="color:#e53e3e;">删除</a>';
}
function openAdd() {
    $('#fm_id').val('');
    $('#fm_name').val('');
    $('#fm_flowerCost').val('');
    $('#fm_timeMinutes').val('');
    $('#fm_dailyLimit').val('');
    $('#fm_sortOrder').val(0);
    $('#fm_description').val('');
    $('#fm_status').val(1);
    $('#dlg').dialog('open').dialog('setTitle', '新增兑换项目');
}
function openEdit(id) {
    var row = $('#itemTable').datagrid('getRows').find(function(r){ return r.id == id; });
    if (!row) return;
    $('#fm_id').val(row.id || '');
    $('#fm_name').val(row.name || '');
    $('#fm_flowerCost').val(row.flowerCost || '');
    $('#fm_timeMinutes').val(row.timeMinutes || '');
    $('#fm_dailyLimit').val(row.dailyLimit || '');
    $('#fm_sortOrder').val(row.sortOrder != null ? row.sortOrder : 0);
    $('#fm_description').val(row.description || '');
    $('#fm_status').val(row.status != null ? row.status : 1);
    $('#dlg').dialog('open').dialog('setTitle', '编辑兑换项目');
}
function saveItem() {
    var data = {
        id:          $('#fm_id').val() || null,
        name:        $.trim($('#fm_name').val()),
        flowerCost:  $('#fm_flowerCost').val() || null,
        timeMinutes: $('#fm_timeMinutes').val() || null,
        dailyLimit:  $('#fm_dailyLimit').val() || null,
        sortOrder:   $('#fm_sortOrder').val() || 0,
        description: $('#fm_description').val() || null,
        status:      $('#fm_status').val()
    };
    if (!data.name) { $.messager.alert('提示','请输入项目名称','warning'); return; }
    if (!data.flowerCost) { $.messager.alert('提示','请输入消耗小红花数量','warning'); return; }
    var url = data.id ? '/flower/manage/item/update' : '/flower/manage/item/add';
    $.ajax({ url:url, type:'POST', contentType:'application/json',
        data: JSON.stringify(data),
        success: function(res) {
            if (res.success) { $('#dlg').dialog('close'); $('#itemTable').datagrid('reload'); }
            else { $.messager.alert('错误', res.message || '保存失败', 'error'); }
        }
    });
}
function toggleStatus(id) {
    $.post('/flower/manage/item/toggleStatus', { id: id }, function(res) {
        if (res.success) $('#itemTable').datagrid('reload');
    });
}
function delItem(id) {
    $.messager.confirm('确认', '确定删除该兑换项目吗？', function(r) {
        if (r) $.post('/flower/manage/item/delete', { id: id }, function(res) {
            if (res.success) $('#itemTable').datagrid('reload');
        });
    });
}
</script>
</body>
</html>
