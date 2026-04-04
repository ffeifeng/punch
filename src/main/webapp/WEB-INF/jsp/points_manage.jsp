<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.punch.entity.User" %>
<%
    User user = (User) session.getAttribute("user");
    boolean isStudent = user != null && user.getParentId() != null;
    boolean isAdmin = user != null && "admin".equals(user.getUsername());
%>
<!DOCTYPE html>
<html>
<head>
    <title>积分管理 - 学生打卡系统</title>
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
<div class="header">积分管理</div>
<div class="main-content">
    <div style="margin-bottom:16px;">
        <% if (!isStudent) { %>
        <input id="search_type" class="easyui-combobox" prompt="类型" style="width:100px;"
               data-options="valueField:'value',textField:'label',data:[{value:'',label:'全部'},{value:1,label:'打卡获得'},{value:2,label:'撤销扣除'},{value:3,label:'手动调整'}]">
        <% } %>
        <input id="search_date" class="easyui-datebox" prompt="日期" style="width:120px;" data-options="formatter:formatDate,parser:parseDate">
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="doSearch()">查询</a>
        <% if (!isStudent) { %>
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="openAdd()">增加积分</a>
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="openReduce()">扣减积分</a>
        <% } %>
    </div>
    <table id="pointsTable" class="easyui-datagrid" style="width:100%;height:480px;"
           data-options="url:'/points/list',method:'get',pagination:true,rownumbers:true,singleSelect:true,fitColumns:true">
        <thead>
        <tr>
            <th data-options="field:'id',width:40">ID</th>
            <th data-options="field:'studentName',width:80">学生姓名</th>
            <th data-options="field:'operatorName',width:80">操作人</th>
            <th data-options="field:'points',width:80">积分变动</th>
            <th data-options="field:'type',width:80,formatter:formatType">类型</th>
            <th data-options="field:'balance',width:80">变动后余额</th>
            <th data-options="field:'operateTime',width:120">操作时间</th>
            <th data-options="field:'remark',width:120">备注</th>
            <th data-options="field:'operation',width:80,formatter:formatOp">操作</th>
        </tr>
        </thead>
    </table>
</div>

<div id="dlgAdd" class="easyui-dialog" style="width:480px" closed="true" buttons="#dlg-add-btns"
     data-options="modal:true,resizable:false,shadow:true,collapsible:false,maximizable:false">
    <div style="text-align:center;margin-bottom:20px;color:#2d3748;font-size:1.1rem;font-weight:500;">
        ➕ 增加积分
    </div>
    <form id="fmAdd" method="post" style="padding:0 10px;">
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                👨‍🎓 选择学生 <span style="color:#e53e3e;">*</span>
            </label>
            <select name="studentId" class="easyui-combobox" required="true" 
                    data-options="prompt:'请选择学生',iconCls:'icon-man',valueField:'id',textField:'text',editable:false" 
                    style="width:100%;height:36px;" id="studentComboAdd">
            </select>
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                🎯 增加积分 <span style="color:#e53e3e;">*</span>
            </label>
            <input name="points" class="easyui-numberbox" required="true" 
                   data-options="prompt:'请输入积分数量',iconCls:'icon-tip',min:1,max:9999" 
                   style="width:100%;height:36px;">
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                📝 操作备注
            </label>
            <input name="remark" class="easyui-textbox" 
                   data-options="prompt:'请输入备注信息（可选）',iconCls:'icon-tip',multiline:true,height:60" 
                   style="width:100%;">
        </div>
    </form>
</div>
<div id="dlg-add-btns" style="text-align:center;padding:10px;">
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-save'" 
       style="width:80px;height:32px;margin-right:10px;background:#38b2ac;border-color:#319795;" 
       onclick="saveAdd()">保存</a>
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-cancel'" 
       style="width:80px;height:32px;background:#e2e8f0;border-color:#cbd5e0;color:#4a5568;" 
       onclick="closeDlgAdd()">取消</a>
</div>

<div id="dlgReduce" class="easyui-dialog" style="width:480px" closed="true" buttons="#dlg-reduce-btns"
     data-options="modal:true,resizable:false,shadow:true,collapsible:false,maximizable:false">
    <div style="text-align:center;margin-bottom:20px;color:#2d3748;font-size:1.1rem;font-weight:500;">
        ➖ 扣除积分
    </div>
    <form id="fmReduce" method="post" style="padding:0 10px;">
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                👨‍🎓 选择学生 <span style="color:#e53e3e;">*</span>
            </label>
            <select name="studentId" class="easyui-combobox" required="true" 
                    data-options="prompt:'请选择学生',iconCls:'icon-man',valueField:'id',textField:'text',editable:false" 
                    style="width:100%;height:36px;" id="studentComboReduce">
            </select>
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                🎯 扣除积分 <span style="color:#e53e3e;">*</span>
            </label>
            <input name="points" class="easyui-numberbox" required="true" 
                   data-options="prompt:'请输入积分数量',iconCls:'icon-tip',min:1,max:9999" 
                   style="width:100%;height:36px;">
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                📝 操作备注
            </label>
            <input name="remark" class="easyui-textbox" 
                   data-options="prompt:'请输入备注信息（可选）',iconCls:'icon-tip',multiline:true,height:60" 
                   style="width:100%;">
        </div>
    </form>
</div>
<div id="dlg-reduce-btns" style="text-align:center;padding:10px;">
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-save'" 
       style="width:80px;height:32px;margin-right:10px;background:#e53e3e;border-color:#c53030;" 
       onclick="saveReduce()">保存</a>
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-cancel'" 
       style="width:80px;height:32px;background:#e2e8f0;border-color:#cbd5e0;color:#4a5568;" 
       onclick="closeDlgReduce()">取消</a>
</div>

<script>
// 用户角色变量
var isStudent = <%= isStudent %>;
var isAdmin = <%= isAdmin %>;

// 日期格式化函数
function formatDate(date) {
    var y = date.getFullYear();
    var m = date.getMonth() + 1;
    var d = date.getDate();
    return (m < 10 ? ('0' + m) : m) + '/' + (d < 10 ? ('0' + d) : d) + '/' + y;
}

function parseDate(s) {
    if (!s) return new Date();
    var ss = s.split('/');
    var m = parseInt(ss[0], 10);
    var d = parseInt(ss[1], 10);
    var y = parseInt(ss[2], 10);
    if (!isNaN(y) && !isNaN(m) && !isNaN(d)) {
        return new Date(y, m - 1, d);
    } else {
        return new Date();
    }
}

function doSearch() {
    var params = {};
    
    // 学生只能按日期查询，管理员和家长可以按类型和日期查询
    if (!isStudent && $('#search_type').length > 0) {
        params.type = $('#search_type').combobox('getValue');
    }
    
    // 添加日期查询参数
    var searchDate = $('#search_date').datebox('getValue');
    if (searchDate) {
        // 将日期格式从 mm/dd/yyyy 转换为 yyyy-mm-dd
        var date = new Date(searchDate);
        if (!isNaN(date.getTime())) {
            var year = date.getFullYear();
            var month = String(date.getMonth() + 1).padStart(2, '0');
            var day = String(date.getDate()).padStart(2, '0');
            params.date = year + '-' + month + '-' + day;
        }
    }
    
    $('#pointsTable').datagrid('load', params);
}
function formatType(val) {
    if(val==1) return '打卡获得';
    if(val==2) return '撤销扣除';
    if(val==3) return '手动调整';
    return val;
}
function formatOp(val,row) {
    // 学生用户不显示删除按钮
    if (isStudent) {
        return '<span style="color:#999;">无操作</span>';
    }
    return '<a href="javascript:void(0)" onclick="delPoints('+row.id+')">删除</a>';
}
function openAdd() {
    $('#fmAdd').form('clear');
    loadStudentList('studentComboAdd');
    $('#dlgAdd').dialog('open').dialog('setTitle','增加积分');
}
function saveAdd() {
    var data = $('#fmAdd').serializeArray().reduce(function(obj, item) { obj[item.name] = item.value; return obj; }, {});
    $.post('/points/add', data, function(res){
        $('#dlgAdd').dialog('close');
        $('#pointsTable').datagrid('reload');
    });
}
function closeDlgAdd() {
    $('#dlgAdd').dialog('close');
}
function openReduce() {
    $('#fmReduce').form('clear');
    loadStudentList('studentComboReduce');
    $('#dlgReduce').dialog('open').dialog('setTitle','扣减积分');
}
function saveReduce() {
    var data = $('#fmReduce').serializeArray().reduce(function(obj, item) { obj[item.name] = item.value; return obj; }, {});
    $.post('/points/reduce', data, function(res){
        $('#dlgReduce').dialog('close');
        $('#pointsTable').datagrid('reload');
    });
}
function closeDlgReduce() {
    $('#dlgReduce').dialog('close');
}
function delPoints(id) {
    $.post('/points/delete', {id:id}, function(res){
        $('#pointsTable').datagrid('reload');
    });
}

// 加载学生列表到下拉框
function loadStudentList(comboId) {
    $.get('/user/getStudentList', function(data) {
        var studentData = [];
        if (data && data.length > 0) {
            for (var i = 0; i < data.length; i++) {
                studentData.push({
                    id: data[i].id,
                    text: data[i].realName + ' (' + data[i].username + ')'
                });
            }
        }
        $('#' + comboId).combobox('loadData', studentData);
    }).fail(function() {
        $.messager.alert('错误', '加载学生列表失败', 'error');
    });
}
</script>
</body>
</html>
