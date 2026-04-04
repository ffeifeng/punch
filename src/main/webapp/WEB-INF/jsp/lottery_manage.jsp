<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>抽奖管理 - 学生打卡系统</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>
    <style>
        body { background: #e6fffa; margin: 0; }
        .header { background: linear-gradient(120deg, #4fd1c5 0%, #38b2ac 100%); color: #fff; padding: 18px 32px; font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
        .main-content { padding: 24px 32px; }
        .tip-box { background: #fff; border-left: 4px solid #4fd1c5; padding: 12px 18px; margin-bottom: 16px; border-radius: 4px; color: #4a5568; font-size: 0.9rem; }
    </style>
</head>
<body>
<div class="header">🎰 抽奖管理</div>
<div class="main-content">
    <div class="tip-box">
        💡 在这里配置抽奖转盘的奖品项目。孩子在打卡页面抽奖时，系统将按照各奖品的<strong>概率</strong>进行加权随机抽取。建议各奖品概率之和为 100%。
    </div>
    <div style="margin-bottom:16px;">
        <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-add'" onclick="openAdd()">新增奖品</a>
    </div>
    <table id="itemTable" class="easyui-datagrid" style="width:100%;height:500px;"
           data-options="url:'/lottery/item/list',method:'get',rownumbers:true,singleSelect:true,fitColumns:true,onLoadSuccess:calcTotal">
        <thead>
        <tr>
            <th data-options="field:'id',width:50">ID</th>
            <th data-options="field:'name',width:150">奖品名称</th>
            <th data-options="field:'probability',width:100,formatter:formatProb">概率(%)</th>
            <th data-options="field:'status',width:80,formatter:formatStatus">状态</th>
            <th data-options="field:'createTime',width:130">创建时间</th>
            <th data-options="field:'operation',width:180,formatter:formatOp">操作</th>
        </tr>
        </thead>
    </table>
    <div id="totalTip" style="margin-top:10px;padding:8px 12px;background:#fff;border-radius:4px;font-size:0.9rem;color:#4a5568;display:inline-block;"></div>
</div>

<!-- 新增/编辑对话框 -->
<div id="dlg" class="easyui-dialog" style="width:460px;padding:20px;" closed="true" buttons="#dlg-buttons"
     data-options="modal:true,resizable:false">
    <form id="fm" style="padding:0 10px;">
        <input type="hidden" name="id">
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;">🎁 奖品名称 <span style="color:red">*</span></label>
            <input name="name" class="easyui-textbox" data-options="prompt:'请输入奖品名称，如：文具礼包、零食大礼包'" style="width:100%;height:36px;">
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;">📊 中奖概率(%) <span style="color:red">*</span></label>
            <input name="probability" class="easyui-numberbox" data-options="prompt:'请输入概率，如：30 表示30%',min:0.01,max:100,precision:2" style="width:100%;height:36px;">
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;">🔘 状态</label>
            <select name="status" class="easyui-combobox"
                    data-options="editable:false,valueField:'value',textField:'label',data:[{value:1,label:'启用'},{value:0,label:'禁用'}]"
                    style="width:100%;height:36px;"></select>
        </div>
    </form>
</div>
<div id="dlg-buttons" style="text-align:center;padding:10px;">
    <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-save'"
       style="width:80px;height:32px;margin-right:10px;background:#38b2ac;border-color:#319795;" onclick="saveItem()">保存</a>
    <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-cancel'"
       style="width:80px;height:32px;" onclick="$('#dlg').dialog('close')">取消</a>
</div>

<script>
function calcTotal() {
    var rows = $('#itemTable').datagrid('getRows');
    var total = 0;
    rows.forEach(function(r) { if (r.status == 1) total += parseFloat(r.probability) || 0; });
    var color = (Math.abs(total - 100) < 0.01) ? '#38a169' : (total > 100 ? '#e53e3e' : '#e67e22');
    $('#totalTip').html('已启用奖品概率之和：<strong style="color:' + color + '">' + total.toFixed(2) + '%</strong>'
        + (Math.abs(total - 100) < 0.01 ? ' ✅ 概率合计恰好100%' : (total > 100 ? ' ⚠️ 超过100%，建议调整' : ' ℹ️ 不足100%，剩余概率视为无奖励')));
}
function formatProb(val) {
    return '<span style="color:#319795;font-weight:bold;">' + (parseFloat(val) || 0).toFixed(2) + '%</span>';
}
function formatStatus(val) {
    return val == 1
        ? '<span style="color:#38a169;font-weight:bold;">✅ 启用</span>'
        : '<span style="color:#e53e3e;font-weight:bold;">❌ 禁用</span>';
}
function formatOp(val, row) {
    return '<a href="javascript:void(0)" onclick="openEdit(' + row.id + ')">编辑</a> '
        + '<a href="javascript:void(0)" onclick="toggleStatus(' + row.id + ')">' + (row.status == 1 ? '禁用' : '启用') + '</a> '
        + '<a href="javascript:void(0)" onclick="delItem(' + row.id + ')" style="color:#e53e3e;">删除</a>';
}
function openAdd() {
    $('#fm').form('clear');
    $('select[name="status"]').combobox('setValue', 1);
    $('#dlg').dialog('open').dialog('setTitle', '新增奖品');
}
function openEdit(id) {
    var row = $('#itemTable').datagrid('getRows').find(function(r) { return r.id == id; });
    if (row) {
        $('#fm').form('clear');
        $('#fm').form('load', row);
        $('select[name="status"]').combobox('setValue', row.status);
        $('#dlg').dialog('open').dialog('setTitle', '编辑奖品');
    }
}
function saveItem() {
    var data = {};
    $('#fm').serializeArray().forEach(function(item) { data[item.name] = item.value; });
    if (!data.name) { $.messager.alert('提示', '请输入奖品名称', 'warning'); return; }
    if (!data.probability) { $.messager.alert('提示', '请输入概率', 'warning'); return; }
    var url = data.id ? '/lottery/item/update' : '/lottery/item/add';
    $.ajax({
        url: url, type: 'POST', contentType: 'application/json',
        data: JSON.stringify(data),
        success: function(res) {
            if (res.success) {
                $('#dlg').dialog('close');
                $('#itemTable').datagrid('reload');
            } else {
                $.messager.alert('错误', res.message || '保存失败', 'error');
            }
        }
    });
}
function toggleStatus(id) {
    $.post('/lottery/item/toggleStatus', { id: id }, function(res) {
        if (res.success) $('#itemTable').datagrid('reload');
    });
}
function delItem(id) {
    $.messager.confirm('确认', '确定要删除这个奖品吗？', function(r) {
        if (r) {
            $.post('/lottery/item/delete', { id: id }, function(res) {
                if (res.success) $('#itemTable').datagrid('reload');
            });
        }
    });
}
</script>
</body>
</html>
