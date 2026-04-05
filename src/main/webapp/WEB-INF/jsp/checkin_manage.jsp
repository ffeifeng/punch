<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.punch.entity.User" %>
<%
    User user = (User) session.getAttribute("user");
    String role = "";
    if (user != null) {
        if (user.getParentId() == null && "admin".equals(user.getUsername())) {
            role = "admin";
        } else if (user.getParentId() == null && !"admin".equals(user.getUsername())) {
            role = "parent";
        } else if (user.getParentId() != null) {
            role = "student";
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>打卡管理 - 学生打卡系统</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>
    <style>
        /* 优化多选组件的显示效果 */
        .combobox-f .textbox-text {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        
        /* 多选项目的样式 */
        .combobox-item-selected {
            background-color: #e6f7ff !important;
            border-left: 3px solid #1890ff !important;
        }
        
        /* 学生选择器的特殊样式 */
        #templateStudents + .combo .textbox-text {
            color: #4a5568;
            font-weight: 500;
        }
        
        /* 优化下拉面板的样式 */
        .combo-panel .combobox-item {
            padding: 8px 12px;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .combo-panel .combobox-item:hover {
            background-color: #f8f9fa;
        }
    </style>
    <style>
        body { background: #e6fffa; margin: 0; }
        .header { background: linear-gradient(120deg, #4fd1c5 0%, #38b2ac 100%); color: #fff; padding: 18px 32px; font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
        .main-content { padding: 32px; }
        .template-panel { float:left; width:45%; margin-right:4%; }
        .item-panel { float:left; width:50%; }
        .clearfix:after { content:""; display:block; clear:both; }
        
        /* 动画效果 */
        @keyframes slideUp {
            0% {
                transform: translateY(0);
                background-color: #fff;
            }
            50% {
                transform: translateY(-10px);
                background-color: #e6f7ff;
            }
            100% {
                transform: translateY(0);
                background-color: #fff;
            }
        }
        
        @keyframes slideDown {
            0% {
                transform: translateY(0);
                background-color: #fff;
            }
            50% {
                transform: translateY(10px);
                background-color: #e6f7ff;
            }
            100% {
                transform: translateY(0);
                background-color: #fff;
            }
        }
        
        @keyframes highlight {
            0%, 100% {
                background-color: #fff;
            }
            50% {
                background-color: #d4edda;
            }
        }
        
        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
        }
        
        /* 应用动画的类 */
        .row-moving-up {
            animation: slideUp 0.5s ease-in-out;
        }
        
        .row-moving-down {
            animation: slideDown 0.5s ease-in-out;
        }
        
        .row-highlight {
            animation: highlight 0.8s ease-in-out;
        }
        
        /* 按钮悬停效果 */
        .datagrid-body a[title="上移"], 
        .datagrid-body a[title="下移"] {
            display: inline-block;
            transition: all 0.2s ease;
            margin: 0 2px;
            font-size: 16px;
        }
        
        .datagrid-body a[title="上移"]:hover {
            transform: translateY(-2px);
            filter: brightness(1.2);
        }
        
        .datagrid-body a[title="下移"]:hover {
            transform: translateY(2px);
            filter: brightness(1.2);
        }
        
        /* 表格行过渡效果 */
        .datagrid-row {
            transition: background-color 0.3s ease;
        }
    </style>
</head>
<body>
<div class="header">
    打卡管理
    <% if ("student".equals(role)) { %>
    <span style="float:right;color:#e53e3e;font-size:14px;margin-top:5px;">
        👀 学生只读模式 - 您只能查看打卡模板和事项
    </span>
    <% } %>
</div>
<div class="main-content clearfix">
    <div class="template-panel">
        <div style="margin-bottom:12px;">
            <% if ("admin".equals(role) || "parent".equals(role)) { %>
            <a href="javascript:void(0)" class="easyui-linkbutton" onclick="openAddTemplate()">新增模板</a>
            <% } %>
            <% if ("parent".equals(role)) { %>
            <a href="javascript:void(0)" class="easyui-linkbutton" onclick="refreshStudentItems()" 
               style="margin-left:10px;background:#28a745;border-color:#228b3d;">
               🔄 同步学生打卡事项
            </a>
            <% } %>
        </div>
        <table id="templateTable" class="easyui-datagrid" style="width:100%;height:350px;"
               data-options="url:'/checkin/template/list',method:'get',pagination:true,rownumbers:true,singleSelect:true,fitColumns:true,onClickRow:loadItems,queryParams:{}">
            <thead>
            <tr>
                <th data-options="field:'id',width:40">ID</th>
                <th data-options="field:'templateName',width:100">模板名称</th>
                <th data-options="field:'description',width:120">描述</th>
                <th data-options="field:'studentNames',width:150">分配学生</th>
                <th data-options="field:'lotteryReward',width:80,align:'center'">完成赠抽奖次</th>
                <th data-options="field:'status',width:60,formatter:formatTemplateStatus">状态</th>
                <th data-options="field:'operation',width:120,formatter:formatTemplateOp">操作</th>
            </tr>
            </thead>
        </table>
    </div>
    <div class="item-panel">
        <div style="margin-bottom:12px;">
            <% if ("admin".equals(role) || "parent".equals(role)) { %>
            <a href="javascript:void(0)" class="easyui-linkbutton" onclick="openAddItem()">新增事项</a>
            <% } %>
            <% if ("admin".equals(role) || "parent".equals(role)) { %>
            <a href="javascript:void(0)" class="easyui-linkbutton" onclick="showDailyItemsDialog()" 
               style="margin-left:10px;background:#007bff;border-color:#0056b3;">
               📋 查看当日事项
            </a>
            <% } %>
        </div>
        <table id="itemTable" class="easyui-datagrid" style="width:100%;height:350px;"
               data-options="url:'/checkin/item/list',method:'get',pagination:true,rownumbers:true,singleSelect:true,fitColumns:true,queryParams:{}">
            <thead>
            <tr>
                <th data-options="field:'id',width:40">ID</th>
                <th data-options="field:'templateName',width:100">所属模板</th>
                <th data-options="field:'itemName',width:100">事项名称</th>
                <th data-options="field:'description',width:120">描述</th>
                <th data-options="field:'points',width:60">积分</th>
                <th data-options="field:'status',width:70,formatter:formatItemStatus">状态</th>
                <th data-options="field:'timeRange',width:120,formatter:formatTimeRange">打卡时间</th>
                <th data-options="field:'sortOrder',width:60">排序</th>
                <th data-options="field:'operation',width:120,formatter:formatItemOp">操作</th>
            </tr>
            </thead>
        </table>
    </div>
</div>

<!-- 模板弹窗 -->
<div id="dlgTemplate" class="easyui-dialog" style="width:500px;padding:20px;" 
     data-options="modal:true,resizable:false,shadow:true,collapsible:false,maximizable:false" 
     closed="true" buttons="#dlg-template-btns">
    <div style="text-align:center;margin-bottom:20px;color:#2d3748;font-size:1.1rem;font-weight:500;">
        📝 打卡模板信息
    </div>
    <form id="fmTemplate" method="post" style="padding:0 10px;">
        <input type="hidden" name="id">
        <div style="margin-bottom:20px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                🏷️ 模板名称 <span style="color:#e53e3e;">*</span>
            </label>
            <input name="templateName" class="easyui-textbox" required="true" 
                   data-options="prompt:'请输入模板名称',iconCls:'icon-edit'" 
                   style="width:100%;height:36px;">
        </div>
        <div style="margin-bottom:20px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                📄 模板描述
            </label>
            <input name="description" class="easyui-textbox" 
                   data-options="prompt:'请输入模板描述信息（可选）',iconCls:'icon-tip',multiline:true,height:80" 
                   style="width:100%;">
        </div>
        <div style="margin-bottom:20px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                ⚡ 模板状态 <span style="color:#e53e3e;">*</span>
            </label>
            <select name="status" class="easyui-combobox" required="true" 
                    data-options="prompt:'请选择模板状态',iconCls:'icon-ok',editable:false,panelHeight:'auto'" 
                    style="width:100%;height:36px;">
                <option value="1">启用</option>
                <option value="0">禁用</option>
            </select>
        </div>
        <div style="margin-bottom:20px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                🎰 全部打卡完成赠送抽奖次数
            </label>
            <input name="lotteryReward" type="number" min="0" max="99" value="0"
                   style="width:100%;height:36px;padding:0 8px;border:1px solid #ddd;border-radius:4px;font-size:14px;box-sizing:border-box;">
            <div style="font-size:0.78rem;color:#718096;margin-top:4px;">孩子完成当天全部打卡事项后，自动赠送指定次数的抽奖机会（每天仅赠送一次）</div>
        </div>
        <div style="margin-bottom:20px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                👥 分配学生 <span style="color:#e53e3e;">*</span>
            </label>
            <input id="templateStudents" class="easyui-combobox" 
                   data-options="
                   prompt:'请选择要分配的学生（支持多选）',
                   iconCls:'icon-man',
                   editable:false,
                   multiple:true,
                   valueField:'id',
                   textField:'realName',
                   url:'/user/studentList',
                   method:'get',
                   panelHeight:'200',
                   separator:',',
                   hasDownArrow:true
                   " 
                   style="width:100%;height:40px;" required="true">
            <div style="font-size:0.8rem;color:#718096;margin-top:5px;">
                💡 提示：可以选择多个学生，该模板下的打卡事项将对选中的学生可见
            </div>
        </div>
    </form>
</div>
<div id="dlg-template-btns" style="text-align:center;padding:10px;">
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-save'" 
       style="width:80px;height:32px;margin-right:10px;background:#38b2ac;border-color:#319795;" 
       onclick="saveTemplate()">保存</a>
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-cancel'" 
       style="width:80px;height:32px;background:#e2e8f0;border-color:#cbd5e0;color:#4a5568;" 
       onclick="closeDlgTemplate()">取消</a>
</div>
<!-- 事项弹窗 -->
<div id="dlgItem" class="easyui-dialog" style="width:520px;padding:20px;" 
     data-options="modal:true,resizable:false,shadow:true,collapsible:false,maximizable:false" 
     closed="true" buttons="#dlg-item-btns">
    <div style="text-align:center;margin-bottom:20px;color:#2d3748;font-size:1.1rem;font-weight:500;">
        ⚡ 打卡事项信息
    </div>
    <form id="fmItem" method="post" style="padding:0 10px;">
        <input type="hidden" name="id">
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                📋 所属模板 <span style="color:#e53e3e;">*</span>
            </label>
            <select name="templateId" class="easyui-combobox" required="true" 
                    data-options="prompt:'请选择模板',iconCls:'icon-list',editable:false,valueField:'id',textField:'templateName',url:'/checkin/template/list',method:'get'" 
                    style="width:100%;height:36px;">
            </select>
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                🎯 事项名称 <span style="color:#e53e3e;">*</span>
            </label>
            <input name="itemName" class="easyui-textbox" required="true" 
                   data-options="prompt:'请输入事项名称',iconCls:'icon-edit'" 
                   style="width:100%;height:36px;">
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                📝 事项描述
            </label>
            <input name="description" class="easyui-textbox" 
                   data-options="prompt:'请输入事项描述信息（可选）',iconCls:'icon-tip',multiline:true,height:60" 
                   style="width:100%;">
        </div>
        <div style="display:flex;gap:15px;margin-bottom:18px;">
            <div style="flex:1;">
                <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                    💎 奖励积分 <span style="color:#e53e3e;">*</span>
                </label>
                <input name="points" class="easyui-numberbox" required="true" 
                       data-options="prompt:'积分',iconCls:'icon-tip',min:0,max:999" 
                       style="width:140px;height:36px;">
            </div>
            <div style="flex:1;">
                <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                    🔢 排序号 <span style="color:#e53e3e;">*</span>
                </label>
                <input name="sortOrder" class="easyui-numberbox" required="true" 
                       data-options="prompt:'排序',iconCls:'icon-sort',min:1,max:999" 
                       style="width:140px;height:36px;">
            </div>
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                ⚡ 事项状态 <span style="color:#e53e3e;">*</span>
            </label>
            <select name="status" class="easyui-combobox" required="true" 
                    data-options="prompt:'请选择事项状态',iconCls:'icon-ok',editable:false,panelHeight:'auto'" 
                    style="width:100%;height:36px;">
                <option value="0">未打卡</option>
                <option value="1">已打卡</option>
                <option value="2">禁用</option>
            </select>
        </div>
        <div style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                ⏰ 打卡时间范围
            </label>
            <div style="display:flex;gap:10px;align-items:center;">
                <input name="checkinStartTime" class="easyui-timespinner" 
                       data-options="prompt:'开始时间',iconCls:'icon-time',showSeconds:false" 
                       style="width:140px;height:36px;">
                <span style="color:#4a5568;font-weight:500;">至</span>
                <input name="checkinEndTime" class="easyui-timespinner" 
                       data-options="prompt:'结束时间',iconCls:'icon-time',showSeconds:false" 
                       style="width:140px;height:36px;">
            </div>
            <div style="font-size:0.8rem;color:#718096;margin-top:5px;">
                💡 提示：超出打卡时间范围，积分奖励将减半（留空表示全天有效）
            </div>
        </div>
    </form>
</div>
<div id="dlg-item-btns" style="text-align:center;padding:10px;">
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-save'" 
       style="width:80px;height:32px;margin-right:10px;background:#38b2ac;border-color:#319795;" 
       onclick="saveItem()">保存</a>
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-cancel'" 
       style="width:80px;height:32px;background:#e2e8f0;border-color:#cbd5e0;color:#4a5568;" 
       onclick="closeDlgItem()">取消</a>
</div>

<!-- 当日事项列表对话框 -->
<div id="dlgDailyItems" class="easyui-dialog" style="width:800px;padding:20px;" 
     data-options="modal:true,resizable:true,shadow:true,collapsible:false,maximizable:true" 
     closed="true">
    <div style="text-align:center;margin-bottom:20px;color:#2d3748;font-size:1.1rem;font-weight:500;">
        📋 当日打卡事项列表
    </div>
    
    <!-- 搜索条件 -->
    <div style="margin-bottom:15px;padding:15px;background:#f7fafc;border-radius:8px;">
        <div style="display:flex;gap:15px;align-items:center;flex-wrap:wrap;">
            <div>
                <label style="color:#4a5568;font-weight:500;margin-right:8px;">🔍 学生姓名：</label>
                <input id="searchStudentName" class="easyui-textbox" 
                       data-options="prompt:'输入学生姓名进行搜索',iconCls:'icon-search'" 
                       style="width:150px;height:32px;">
            </div>
            <div>
                <label style="color:#4a5568;font-weight:500;margin-right:8px;">📝 模板名称：</label>
                <input id="searchTemplateName" class="easyui-textbox" 
                       data-options="prompt:'输入模板名称进行搜索',iconCls:'icon-search'" 
                       style="width:150px;height:32px;">
            </div>
            <div>
                <label style="color:#4a5568;font-weight:500;margin-right:8px;">📅 日期：</label>
                <input id="searchCheckinDate" class="easyui-datebox" 
                       data-options="editable:false,formatter:formatDate,parser:parseDate" 
                       style="width:120px;height:32px;">
            </div>
            <div>
                <label style="color:#4a5568;font-weight:500;margin-right:8px;">🎯 状态：</label>
                <select id="searchStatus" class="easyui-combobox" 
                        data-options="editable:false,panelHeight:'auto'" 
                        style="width:100px;height:32px;">
                    <option value="">全部</option>
                    <option value="0">未打卡</option>
                    <option value="1">已打卡</option>
                    <option value="2">已过期</option>
                </select>
            </div>
            <div>
                <a href="javascript:void(0)" class="easyui-linkbutton" onclick="searchDailyItems()" 
                   style="background:#38b2ac;border-color:#319795;height:32px;">
                   🔍 搜索
                </a>
                <a href="javascript:void(0)" class="easyui-linkbutton" onclick="resetSearch()" 
                   style="margin-left:8px;background:#e2e8f0;border-color:#cbd5e0;color:#4a5568;height:32px;">
                   🔄 重置
                </a>
            </div>
        </div>
    </div>
    
    <!-- 数据表格 -->
    <table id="dailyItemsTable" class="easyui-datagrid" style="width:100%;height:400px;"
           data-options="url:'/dailyCheckinItem/list',method:'get',pagination:true,rownumbers:true,singleSelect:true,fitColumns:true">
        <thead>
        <tr>
            <th data-options="field:'id',width:50">ID</th>
            <th data-options="field:'studentName',width:80">学生姓名</th>
            <th data-options="field:'templateName',width:100">模板名称</th>
            <th data-options="field:'itemName',width:120">事项名称</th>
            <th data-options="field:'checkinTimeRange',width:100">打卡时间</th>
            <th data-options="field:'points',width:60">积分</th>
            <th data-options="field:'statusText',width:70,formatter:formatDailyItemStatus">状态</th>
            <th data-options="field:'checkinTime',width:130,formatter:formatCheckinTime">打卡时间</th>
        </tr>
        </thead>
    </table>
</div>

<script>
var currentTemplateId = null;
function loadItems(index, row) {
    currentTemplateId = row.id;
    $('#itemTable').datagrid({
        url: '/checkin/item/list',
        method: 'get',
        pagination: true,
        queryParams: {
            templateId: row.id
        }
    });
}
function formatTemplateStatus(val) {
    if(val == 1) return '<span style="color:green;font-weight:bold;">启用</span>';
    if(val == 0) return '<span style="color:red;font-weight:bold;">禁用</span>';
    return val;
}
function formatItemStatus(val) {
    if(val == 0) return '<span style="color:#f6ad55;font-weight:bold;">⏳ 未打卡</span>';
    if(val == 1) return '<span style="color:#38b2ac;font-weight:bold;">✅ 已打卡</span>';
    if(val == 2) return '<span style="color:#e53e3e;font-weight:bold;">🚫 禁用</span>';
    return val;
}
function formatTimeRange(val, row) {
    var start = row.checkinStartTime;
    var end = row.checkinEndTime;
    if (!start && !end) {
        return '<span style="color:#718096;">全天有效</span>';
    }
    var startStr = start ? start.substring(0, 5) : '00:00';
    var endStr = end ? end.substring(0, 5) : '23:59';
    return '<span style="color:#319795;font-weight:500;">' + startStr + ' - ' + endStr + '</span>';
}
function formatTemplateOp(val,row) {
    var userRole = '<%= role %>';
    if (userRole === 'admin' || userRole === 'parent') {
        return '<a href="javascript:void(0)" onclick="openEditTemplate('+row.id+')">编辑</a> '
            + '<a href="javascript:void(0)" onclick="delTemplate('+row.id+')">删除</a>';
    } else {
        return '<span style="color:#999;">无权限</span>';
    }
}
function formatItemOp(val,row) {
    var userRole = '<%= role %>';
    if (userRole === 'admin' || userRole === 'parent') {
        return '<a href="javascript:void(0)" onclick="moveItemUp('+row.id+')" title="上移">⬆️</a> '
            + '<a href="javascript:void(0)" onclick="moveItemDown('+row.id+')" title="下移">⬇️</a> '
            + '<a href="javascript:void(0)" onclick="openEditItem('+row.id+')">编辑</a> '
            + '<a href="javascript:void(0)" onclick="delItem('+row.id+')">删除</a>';
    } else {
        return '<span style="color:#999;">无权限</span>';
    }
}
function openAddTemplate() {
    $('#fmTemplate').form('clear');
    // 设置状态默认值为启用
    $('select[name="status"]').combobox('setValue', '1');
    // 清空学生选择
    $('#templateStudents').combobox('clear');
    $('#templateStudents').combobox('reload'); // 重新加载学生数据
    $('#dlgTemplate').dialog('open').dialog('setTitle','新增模板');
}
function openEditTemplate(id) {
    var row = $('#templateTable').datagrid('getRows').find(r=>r.id==id);
    if(row){
        $('#fmTemplate').form('load', row);

        $('input[name="lotteryReward"]').val(row.lotteryReward || 0);
        $('#dlgTemplate').dialog('open').dialog('setTitle','编辑模板');

        // 获取模板分配的学生并回显
        $.get('/checkin/template/' + id + '/students', function(studentIds) {
            $('#templateStudents').combobox('setValues', studentIds);
        });
    }
}
function saveTemplate() {
    var data = $('#fmTemplate').serializeArray().reduce(function(obj, item) { obj[item.name] = item.value; return obj; }, {});

    data.lotteryReward = parseInt($('input[name="lotteryReward"]').val()) || 0;

    // 获取选中的学生ID列表
    var studentIds = $('#templateStudents').combobox('getValues');
    if (!studentIds || studentIds.length === 0) {
        $.messager.alert('提示', '请至少选择一个学生！', 'warning');
        return;
    }
    
    // 确保studentIds是数组格式
    if (typeof studentIds === 'string') {
        studentIds = studentIds.split(',').map(function(id) { return parseInt(id.trim()); });
    }
    data.studentIds = studentIds;
    
    var url = data.id ? '/checkin/template/update' : '/checkin/template/add';
    var actionText = data.id ? '编辑' : '新增';
    
    $.ajax({
        url: url,
        type: 'post',
        contentType: 'application/json',
        data: JSON.stringify(data),
        success: function(res) {
            if(res==='limit'){
                $.messager.alert('提示', '家长最多只能有3个模板！', 'warning');
                return;
            }
            if(res==='success'){
                $.messager.show({
                    title: '成功',
                    msg: actionText + '模板成功！',
                    timeout: 2000,
                    showType: 'slide'
                });
                $('#dlgTemplate').dialog('close');
                $('#templateTable').datagrid('reload');
            } else {
                $.messager.alert('错误', actionText + '失败：' + res, 'error');
            }
        },
        error: function(xhr, status, error) {
            $.messager.alert('错误', actionText + '失败：' + error, 'error');
        }
    });
}
function closeDlgTemplate() {
    $('#dlgTemplate').dialog('close');
}
function delTemplate(id) {
    $.post('/checkin/template/delete', {id:id}, function(res){
        $('#templateTable').datagrid('reload');
        $('#itemTable').datagrid('loadData',[]);
    });
}
function openAddItem() {
    $('#fmItem').form('clear');
    // 如果有选中的模板，设为默认值
    if(currentTemplateId) {
        $('select[name=templateId]').combobox('setValue', currentTemplateId);
    }
    // 设置状态默认值为未打卡
    setTimeout(function() {
        $('select[name=status]').combobox('setValue', 0);
    }, 100);
    $('#dlgItem').dialog('open').dialog('setTitle','新增事项');
}
function openEditItem(id) {
    var row = $('#itemTable').datagrid('getRows').find(r=>r.id==id);
    if(row){
        $('#fmItem').form('load', row);
        $('#dlgItem').dialog('open').dialog('setTitle','编辑事项');
    }
}
function saveItem() {
    var data = $('#fmItem').serializeArray().reduce(function(obj, item) { obj[item.name] = item.value; return obj; }, {});
    
    // 处理时间字段格式
    if (data.checkinStartTime && data.checkinStartTime.length > 5) {
        data.checkinStartTime = data.checkinStartTime.substring(0, 5); // 只保留HH:mm格式
    }
    if (data.checkinEndTime && data.checkinEndTime.length > 5) {
        data.checkinEndTime = data.checkinEndTime.substring(0, 5); // 只保留HH:mm格式
    }
    
    // 如果时间字段为空，则删除该字段
    if (!data.checkinStartTime || data.checkinStartTime.trim() === '') {
        delete data.checkinStartTime;
    }
    if (!data.checkinEndTime || data.checkinEndTime.trim() === '') {
        delete data.checkinEndTime;
    }
    
    var url = data.id ? '/checkin/item/update' : '/checkin/item/add';
    $.ajax({
        url: url,
        type: 'post',
        contentType: 'application/json',
        data: JSON.stringify(data),
        success: function(res) {
            if(res==='limit'){alert('每个模板最多只能有30项！');return;}
            $('#dlgItem').dialog('close');
            $('#itemTable').datagrid('reload');
        },
        error: function(xhr, status, error) {
            alert('保存失败：' + error);
            console.log('Error details:', xhr.responseText);
        }
    });
}
function closeDlgItem() {
    $('#dlgItem').dialog('close');
}
function delItem(id) {
    $.post('/checkin/item/delete', {id:id}, function(res){
        $('#itemTable').datagrid('reload');
    });
}

// 上移事项
function moveItemUp(id) {
    // 找到当前行并添加动画效果
    var rows = $('#itemTable').datagrid('getRows');
    var rowIndex = -1;
    for (var i = 0; i < rows.length; i++) {
        if (rows[i].id == id) {
            rowIndex = i;
            break;
        }
    }
    
    if (rowIndex >= 0) {
        // 给当前行添加动画class
        var currentRow = $('#itemTable').datagrid('getPanel').find('.datagrid-body tr[datagrid-row-index="' + rowIndex + '"]');
        currentRow.addClass('row-moving-up');
        
        // 如果不是第一行，给上一行也添加动画
        if (rowIndex > 0) {
            var prevRow = $('#itemTable').datagrid('getPanel').find('.datagrid-body tr[datagrid-row-index="' + (rowIndex - 1) + '"]');
            prevRow.addClass('row-moving-down');
        }
    }
    
    $.ajax({
        url: '/checkin/item/moveUp',
        type: 'post',
        data: {id: id},
        success: function(res) {
            if (res === 'success') {
                // 延迟重载以显示动画
                setTimeout(function() {
                    $('#itemTable').datagrid('reload');
                    
                    // 重载后高亮新位置的行
                    setTimeout(function() {
                        var newIndex = rowIndex - 1;
                        if (newIndex >= 0) {
                            var newRow = $('#itemTable').datagrid('getPanel').find('.datagrid-body tr[datagrid-row-index="' + newIndex + '"]');
                            newRow.addClass('row-highlight');
                            
                            // 清除高亮效果
                            setTimeout(function() {
                                newRow.removeClass('row-highlight');
                            }, 800);
                        }
                    }, 100);
                }, 300);
                
                $.messager.show({
                    title: '✅ 成功',
                    msg: '事项已上移',
                    timeout: 1500,
                    showType: 'slide',
                    style: {
                        right: '',
                        top: document.body.scrollTop + document.documentElement.scrollTop + 100,
                        bottom: ''
                    }
                });
            } else if (res === 'first') {
                // 移除动画class
                if (rowIndex >= 0) {
                    var currentRow = $('#itemTable').datagrid('getPanel').find('.datagrid-body tr[datagrid-row-index="' + rowIndex + '"]');
                    currentRow.removeClass('row-moving-up');
                }
                $.messager.alert('提示', '⚠️ 已经是第一个事项了', 'info');
            } else {
                $.messager.alert('错误', '上移失败：' + res, 'error');
            }
        },
        error: function() {
            $.messager.alert('错误', '上移失败', 'error');
        }
    });
}

// 下移事项
function moveItemDown(id) {
    // 找到当前行并添加动画效果
    var rows = $('#itemTable').datagrid('getRows');
    var rowIndex = -1;
    for (var i = 0; i < rows.length; i++) {
        if (rows[i].id == id) {
            rowIndex = i;
            break;
        }
    }
    
    if (rowIndex >= 0) {
        // 给当前行添加动画class
        var currentRow = $('#itemTable').datagrid('getPanel').find('.datagrid-body tr[datagrid-row-index="' + rowIndex + '"]');
        currentRow.addClass('row-moving-down');
        
        // 如果不是最后一行，给下一行也添加动画
        if (rowIndex < rows.length - 1) {
            var nextRow = $('#itemTable').datagrid('getPanel').find('.datagrid-body tr[datagrid-row-index="' + (rowIndex + 1) + '"]');
            nextRow.addClass('row-moving-up');
        }
    }
    
    $.ajax({
        url: '/checkin/item/moveDown',
        type: 'post',
        data: {id: id},
        success: function(res) {
            if (res === 'success') {
                // 延迟重载以显示动画
                setTimeout(function() {
                    $('#itemTable').datagrid('reload');
                    
                    // 重载后高亮新位置的行
                    setTimeout(function() {
                        var newIndex = rowIndex + 1;
                        if (newIndex < rows.length) {
                            var newRow = $('#itemTable').datagrid('getPanel').find('.datagrid-body tr[datagrid-row-index="' + newIndex + '"]');
                            newRow.addClass('row-highlight');
                            
                            // 清除高亮效果
                            setTimeout(function() {
                                newRow.removeClass('row-highlight');
                            }, 800);
                        }
                    }, 100);
                }, 300);
                
                $.messager.show({
                    title: '✅ 成功',
                    msg: '事项已下移',
                    timeout: 1500,
                    showType: 'slide',
                    style: {
                        right: '',
                        top: document.body.scrollTop + document.documentElement.scrollTop + 100,
                        bottom: ''
                    }
                });
            } else if (res === 'last') {
                // 移除动画class
                if (rowIndex >= 0) {
                    var currentRow = $('#itemTable').datagrid('getPanel').find('.datagrid-body tr[datagrid-row-index="' + rowIndex + '"]');
                    currentRow.removeClass('row-moving-down');
                }
                $.messager.alert('提示', '⚠️ 已经是最后一个事项了', 'info');
            } else {
                $.messager.alert('错误', '下移失败：' + res, 'error');
            }
        },
        error: function() {
            $.messager.alert('错误', '下移失败', 'error');
        }
    });
}


// 刷新学生打卡事项
function refreshStudentItems() {
    // 显示确认对话框
    $.messager.confirm('确认同步', '🔄 确定要同步您孩子今日的打卡事项吗？<br/><br/>📋 系统将智能同步您的打卡模板：<br/>✅ 新增缺失的事项<br/>🔄 更新已有事项信息<br/>🗑️ 移除多余的事项<br/>⚠️ 不会重复生成已存在的事项。', function(r){
        if (r) {
            // 显示加载提示
            $.messager.progress({
                title: '正在同步...',
                msg: '正在智能同步您孩子的打卡事项，请稍候...'
            });
            
            // 调用后端接口
            $.ajax({
                url: '/dailyCheckin/refreshStudentItems',
                type: 'POST',
                dataType: 'json',
                success: function(result) {
                    $.messager.progress('close');
                    
                    if (result.success) {
                        $.messager.show({
                            title: '同步成功 ✅',
                            msg: result.message + '<br/>🎉 您的孩子现在可以开始打卡了！',
                            timeout: 6000,
                            showType: 'slide'
                        });
                    } else {
                        $.messager.alert('同步失败 ❌', result.message, 'error');
                    }
                },
                error: function(xhr, status, error) {
                    $.messager.progress('close');
                    console.error('同步失败:', error);
                    console.log('Error details:', xhr.responseText);
                    $.messager.alert('同步失败 ❌', '网络请求失败，请检查网络连接后重试。<br/>错误信息：' + error, 'error');
                }
            });
        }
    });
}

// 显示当日事项列表对话框
function showDailyItemsDialog() {
    $('#dlgDailyItems').dialog('open').dialog('setTitle', '📋 当日打卡事项列表');
    
    // 设置默认日期为今天
    var today = new Date();
    var dateStr = today.getFullYear() + '-' + 
                  String(today.getMonth() + 1).padStart(2, '0') + '-' + 
                  String(today.getDate()).padStart(2, '0');
    $('#searchCheckinDate').datebox('setValue', dateStr);
    
    // 触发搜索
    searchDailyItems();
}

// 搜索当日事项
function searchDailyItems() {
    var studentName = $('#searchStudentName').textbox('getValue');
    var templateName = $('#searchTemplateName').textbox('getValue');
    var status = $('#searchStatus').combobox('getValue');
    var checkinDate = $('#searchCheckinDate').datebox('getValue');
    
    console.log('=== 前端搜索参数 ===');
    console.log('原始日期值:', checkinDate);
    console.log('学生姓名:', studentName);
    console.log('模板名称:', templateName);
    console.log('状态:', status);
    console.log('==================');
    
    $('#dailyItemsTable').datagrid('load', {
        studentName: studentName,
        templateName: templateName,
        status: status,
        checkinDate: checkinDate
    });
}

// 重置搜索条件
function resetSearch() {
    $('#searchStudentName').textbox('setValue', '');
    $('#searchTemplateName').textbox('setValue', '');
    $('#searchStatus').combobox('setValue', '');
    
    // 重置日期为今天
    var today = new Date();
    var dateStr = today.getFullYear() + '-' + 
                  String(today.getMonth() + 1).padStart(2, '0') + '-' + 
                  String(today.getDate()).padStart(2, '0');
    $('#searchCheckinDate').datebox('setValue', dateStr);
    
    searchDailyItems();
}

// 格式化当日事项状态
function formatDailyItemStatus(value, row, index) {
    if (row.status == 0) {
        return '<span style="color:#e53e3e;">未打卡</span>';
    } else if (row.status == 1) {
        return '<span style="color:#38a169;">已打卡</span>';
    } else if (row.status == 2) {
        return '<span style="color:#a0aec0;">已过期</span>';
    }
    return '<span style="color:#718096;">未知</span>';
}

// 格式化打卡时间
function formatCheckinTime(value, row, index) {
    if (value) {
        var date = new Date(value);
        return date.getFullYear() + '-' + 
               String(date.getMonth() + 1).padStart(2, '0') + '-' + 
               String(date.getDate()).padStart(2, '0') + ' ' +
               String(date.getHours()).padStart(2, '0') + ':' + 
               String(date.getMinutes()).padStart(2, '0');
    }
    return '';
}

// 日期格式化函数，确保统一的日期格式
function formatDate(date) {
    var y = date.getFullYear();
    var m = date.getMonth() + 1;
    var d = date.getDate();
    return y + '-' + (m < 10 ? '0' + m : m) + '-' + (d < 10 ? '0' + d : d);
}

// 日期解析函数
function parseDate(s) {
    if (!s) return new Date();
    var ss = (s.split('-'));
    var y = parseInt(ss[0], 10);
    var m = parseInt(ss[1], 10);
    var d = parseInt(ss[2], 10);
    if (!isNaN(y) && !isNaN(m) && !isNaN(d)) {
        return new Date(y, m - 1, d);
    } else {
        return new Date();
    }
}
</script>
</body>
</html>
