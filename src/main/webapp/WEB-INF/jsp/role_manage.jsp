<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>角色管理 - 学生打卡系统</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>
    <style>
        body { background: #e6fffa; margin: 0; }
        .header { background: linear-gradient(120deg, #4fd1c5 0%, #38b2ac 100%); color: #fff; padding: 18px 32px; font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
        .main-content { padding: 32px; }
    </style>
</head>
<body>
<div class="header">角色管理</div>
<div class="main-content">
    <div style="margin-bottom:16px;">
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="openAdd()">新增</a>
    </div>
    <table id="roleTable" class="easyui-datagrid" style="width:100%;height:400px;"
           data-options="url:'/role/list',method:'get',pagination:true,rownumbers:true,singleSelect:true,fitColumns:true">
        <thead>
        <tr>
            <th data-options="field:'id',width:40">ID</th>
            <th data-options="field:'roleName',width:100">角色名称</th>
            <th data-options="field:'roleCode',width:100">角色编码</th>
            <th data-options="field:'description',width:180">描述</th>
            <th data-options="field:'operation',width:120,formatter:formatOp">操作</th>
        </tr>
        </thead>
    </table>
</div>

<div id="dlg" class="easyui-dialog" style="width:480px" closed="true" buttons="#dlg-buttons"
     data-options="modal:true,resizable:false,shadow:true,collapsible:false,maximizable:false">
    <div style="text-align:center;margin-bottom:20px;color:#2d3748;font-size:1.1rem;font-weight:500;">
        🎭 角色信息
    </div>
    <form id="fm" method="post" style="padding:0 10px;">
        <input type="hidden" name="id">
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                🏷️ 角色名称 <span style="color:#e53e3e;">*</span>
            </label>
            <input name="roleName" class="easyui-textbox" required="true" 
                   data-options="prompt:'请输入角色名称',iconCls:'icon-man'" 
                   style="width:100%;height:36px;">
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                🔑 角色编码 <span style="color:#e53e3e;">*</span>
            </label>
            <input name="roleCode" class="easyui-textbox" required="true" 
                   data-options="prompt:'请输入角色编码（如：ADMIN、USER）',iconCls:'icon-edit'" 
                   style="width:100%;height:36px;">
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                📝 角色描述
            </label>
            <input name="description" class="easyui-textbox" 
                   data-options="prompt:'请输入角色描述（可选）',iconCls:'icon-tip',multiline:true,height:60" 
                   style="width:100%;">
        </div>
    </form>
</div>
<div id="dlg-buttons" style="text-align:center;padding:10px;">
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-save'" 
       style="width:80px;height:32px;margin-right:10px;background:#38b2ac;border-color:#319795;" 
       onclick="saveRole()">保存</a>
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-cancel'" 
       style="width:80px;height:32px;background:#e2e8f0;border-color:#cbd5e0;color:#4a5568;" 
       onclick="closeDlg()">取消</a>
</div>

<script>
function formatOp(val,row) {
    return '<a href="javascript:void(0)" onclick="openEdit('+row.id+')">编辑</a> '
        + '<a href="javascript:void(0)" onclick="delRole('+row.id+')">删除</a>';
}
function openAdd() {
    $('#fm').form('clear');
    $('#dlg').dialog('open').dialog('setTitle','新增角色');
}
function openEdit(id) {
    var row = $('#roleTable').datagrid('getRows').find(r=>r.id==id);
    if(row){
        $('#fm').form('load', row);
        $('#dlg').dialog('open').dialog('setTitle','编辑角色');
    }
}
function saveRole() {
    var data = $('#fm').serializeArray().reduce(function(obj, item) { obj[item.name] = item.value; return obj; }, {});
    var url = data.id ? '/role/update' : '/role/add';
    $.ajax({
        url: url,
        type: 'post',
        contentType: 'application/json',
        data: JSON.stringify(data),
        success: function(res) {
            $('#dlg').dialog('close');
            $('#roleTable').datagrid('reload');
        }
    });
}
function closeDlg() {
    $('#dlg').dialog('close');
}
function delRole(id) {
    $.post('/role/delete', {id:id}, function(res){
        $('#roleTable').datagrid('reload');
    });
}
</script>
</body>
</html>
