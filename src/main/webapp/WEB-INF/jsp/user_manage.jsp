<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>用户管理 - 学生打卡系统</title>
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
<div class="header">用户管理</div>
<div class="main-content">
    <div style="margin-bottom:16px;">
        <input id="search_username" class="easyui-textbox" prompt="用户�? style="width:120px;">
        <input id="search_status" class="easyui-combobox" prompt="状�? style="width:100px;"
               data-options="valueField:'value',textField:'label',data:[{value:'',label:'全部'},{value:1,label:'启用'},{value:0,label:'禁用'},{value:2,label:'待注�?}]">
        <span id="admin_time_filters" style="display:none;">
            <input id="search_start" class="easyui-datebox" prompt="注册起始" style="width:120px;">
            <input id="search_end" class="easyui-datebox" prompt="注册结束" style="width:120px;">
        </span>
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="doSearch()">查询</a>
        <a href="javascript:void(0)" class="easyui-linkbutton" onclick="openAdd()">新增</a>
    </div>
    <table id="userTable" class="easyui-datagrid" style="width:100%;height:480px;"
           data-options="url:'/user/list',method:'get',pagination:true,rownumbers:true,singleSelect:true,fitColumns:true">
        <thead>
        <tr>
            <th data-options="field:'id',width:40">ID</th>
            <th data-options="field:'username',width:80">用户�?/th>
            <th data-options="field:'realName',width:80">真实姓名</th>
            <th data-options="field:'userType',width:70,formatter:formatUserType">类型</th>
            <th data-options="field:'phone',width:100">手机�?/th>
            <th data-options="field:'email',width:120">邮箱</th>
            <th data-options="field:'authCode',width:80">注册�?/th>
            <th data-options="field:'status',width:60,formatter:formatStatus">状�?/th>
            <th data-options="field:'registerTime',width:120">注册时间</th>
            <th data-options="field:'lotteryCount',width:80,formatter:formatLotteryCount">抽奖次数</th>
            <th data-options="field:'flowerCount',width:90,formatter:formatFlowerCount">小红�?/th>
            <th data-options="field:'operation',width:230,formatter:formatOp">操作</th>
        </tr>
        </thead>
    </table>
</div>

<div id="dlg" class="easyui-dialog" style="width:580px;height:650px" closed="true" buttons="#dlg-buttons"
     data-options="modal:true,resizable:false,shadow:true,collapsible:false,maximizable:false,top:30,left:'center'">
    <div style="text-align:center;margin-bottom:20px;color:#2d3748;font-size:1.1rem;font-weight:500;">
        👤 用户信息
    </div>
    <form id="fm" method="post" style="padding:0 10px;">
        <input type="hidden" name="id">
        <div id="userTypeField" style="margin-bottom:18px;">
            <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                👥 用户类型 <span style="color:#e53e3e;">*</span>
            </label>
            <select id="userType" name="userType" class="easyui-combobox" required="true" 
                    data-options="prompt:'请选择用户类型',iconCls:'icon-man',editable:false,valueField:'value',textField:'label',data:[{value:'parent',label:'家长用户'},{value:'student',label:'学生用户'}],onSelect:function(record){handleUserTypeChange(record.value);}" 
                    style="width:100%;height:36px;">
            </select>
        </div>
        
        <!-- 家长用户：只显示注册�?-->
        <div id="parentFields" style="display:none;">
            <div style="margin-bottom:18px;">
                <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                    🎟�?注册�?
                    <button type="button" onclick="generateAuthCode()" style="margin-left:10px;padding:2px 8px;background:#38b2ac;color:white;border:none;border-radius:3px;cursor:pointer;">生成随机�?/button>
                </label>
                <input name="authCode" type="text" readonly 
                       placeholder="点击生成随机码按�? 
                       style="width:200px;height:36px;padding:8px;border:1px solid #ddd;border-radius:3px;background:#f9f9f9;" 
                       id="authCodeInput">
            </div>
            <div style="margin-bottom:18px;padding:10px;background:#f7fafc;border-left:4px solid #38b2ac;color:#4a5568;font-size:0.9rem;word-wrap:break-word;">
                💡 <strong>家长用户说明�?/strong><br/>
                �?只需要生成注册码，家长使用此码自行注�?br/>
                �?家长注册时会填写自己的用户名、姓名等信息
            </div>
        </div>
        
        <!-- 学生用户：显示完整信�?-->
        <div id="studentFields" style="display:none;">
            <div id="parentSelectField" style="margin-bottom:18px;">
                <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                    👨‍👩‍👧‍�?所属家�?<span style="color:#e53e3e;">*</span>
                </label>
                <select id="parentIdSelect" name="parentId" class="easyui-combobox" 
                        data-options="prompt:'请选择家长',iconCls:'icon-man',editable:false,valueField:'id',textField:'realName',url:'/user/parentList',method:'get'" 
                        style="width:100%;height:36px;">
                </select>
            </div>
            <div style="margin-bottom:18px;">
                <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                    🏷�?用户�?<span style="color:#e53e3e;">*</span>
                </label>
                <input name="username" class="easyui-textbox" 
                       data-options="prompt:'请输入学生用户名',iconCls:'icon-man'" 
                       style="width:100%;height:36px;">
            </div>
            <div style="margin-bottom:18px;">
                <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                    📝 真实姓名 <span style="color:#e53e3e;">*</span>
                </label>
                <input name="realName" class="easyui-textbox" 
                       data-options="prompt:'请输入学生真实姓�?,iconCls:'icon-edit'" 
                       style="width:100%;height:36px;">
            </div>
            <div style="margin-bottom:18px;">
                <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                    📱 手机�?
                </label>
                <input name="phone" class="easyui-textbox" 
                       data-options="prompt:'请输入手机号（可选）',iconCls:'icon-tip'" 
                       style="width:100%;height:36px;">
            </div>
            <div style="margin-bottom:18px;">
                <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                    📧 邮箱
                </label>
                <input name="email" class="easyui-textbox" 
                       data-options="prompt:'请输入邮箱（可选）',iconCls:'icon-tip'" 
                       style="width:100%;height:36px;">
            </div>
            <div style="margin-bottom:18px;">
                <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                    🔐 初始密码 <span style="color:#e53e3e;">*</span>
                </label>
                <input name="password" class="easyui-textbox" 
                       data-options="prompt:'请输入学生初始密�?,iconCls:'icon-lock'" 
                       style="width:100%;height:36px;">
            </div>
            <div style="margin-bottom:18px;">
                <label style="display:block;margin-bottom:8px;color:#4a5568;font-weight:500;font-size:0.9rem;">
                    🔘 用户状�?<span style="color:#e53e3e;">*</span>
                </label>
                <select name="status" class="easyui-combobox" required="true"
                        data-options="prompt:'请选择用户状�?,iconCls:'icon-ok',editable:false,valueField:'value',textField:'label',data:[{value:1,label:'启用'},{value:0,label:'禁用'}]" 
                        style="width:100%;height:36px;">
                </select>
            </div>
        </div>
    </form>
</div>
<div id="dlg-buttons" style="text-align:center;padding:10px;">
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-save'" 
       style="width:80px;height:32px;margin-right:10px;background:#38b2ac;border-color:#319795;" 
       onclick="saveUser()">保存</a>
    <a href="javascript:void(0)" class="easyui-linkbutton" 
       data-options="iconCls:'icon-cancel'" 
       style="width:80px;height:32px;background:#e2e8f0;border-color:#cbd5e0;color:#4a5568;" 
       onclick="closeDlg()">取消</a>
</div>

<script>
var ctx = '${pageContext.request.contextPath}';
// 页面加载完成后检查用户权�?
$(document).ready(function() {
    // 获取当前用户信息
    $.get(ctx + '/user/currentUser', function(user) {
        // 存储当前用户信息到全局变量
        window.currentUser = user;
        
        if (user && user.username === 'admin') {
            // 管理员用户显示时间筛选条�?
            $('#admin_time_filters').show();
            window.isAdminUser = true;
        } else {
            // 家长用户隐藏时间筛选条件和注册码列
            $('#admin_time_filters').hide();
            // 隐藏注册码列（家长不需要看到注册码�?
            $('#userTable').datagrid('hideColumn', 'authCode');
            // 家长用户直接添加学生，不需要选择用户类型
            window.isParentUser = true;
        }
    });
});

function doSearch() {
    $('#userTable').datagrid('load', {
        username: $('#search_username').val(),
        status: $('#search_status').combobox('getValue'),
        startTime: $('#search_start').datebox('getValue'),
        endTime: $('#search_end').datebox('getValue')
    });
}
function formatLotteryCount(val, row) {
    if (row.parentId == null) return '<span style="color:#ccc;">-</span>';
    var count = val || 0;
    var color = count > 0 ? '#319795' : '#a0aec0';
    return '<span style="color:' + color + ';font-weight:bold;">🎰 ' + count + ' �?/span>';
}
function setLotteryCount(studentId, current) {
    // 动态创建调整弹�?
    var dlgId = 'lotteryAdjustDlg';
    if ($('#' + dlgId).length === 0) {
        $('body').append(
            '<div id="' + dlgId + '" style="padding:20px 24px;">' +
            '  <p style="margin:0 0 14px;font-size:0.95rem;color:#4a5568;">当前抽奖次数�?strong id="lotteryCurrentVal" style="color:#319795;font-size:1.15em;"></strong> �?/p>' +
            '  <div style="display:flex;gap:10px;align-items:center;margin-bottom:12px;">' +
            '    <label style="color:#4a5568;font-size:0.9rem;white-space:nowrap;">操作�?/label>' +
            '    <select id="lotteryOp" style="padding:5px 10px;border:1px solid #cbd5e0;border-radius:6px;font-size:0.9rem;">' +
            '      <option value="add">�?增加</option>' +
            '      <option value="reduce">�?减少</option>' +
            '    </select>' +
            '  </div>' +
            '  <div style="display:flex;gap:10px;align-items:center;margin-bottom:6px;">' +
            '    <label style="color:#4a5568;font-size:0.9rem;white-space:nowrap;">次数�?/label>' +
            '    <input type="number" id="lotteryDelta" min="1" value="1" style="width:80px;padding:5px 8px;border:1px solid #cbd5e0;border-radius:6px;font-size:0.95rem;">' +
            '  </div>' +
            '  <p id="lotteryPreview" style="margin:10px 0 0;font-size:0.85rem;color:#718096;"></p>' +
            '</div>'
        );
        // 监听实时预览
        $(document).on('change input', '#lotteryOp, #lotteryDelta', function() { updateLotteryPreview(); });
    }

    var curCount = current || 0;
    $('#lotteryCurrentVal').text(curCount);
    $('#lotteryOp').val('add');
    $('#lotteryDelta').val(1);
    updateLotteryPreview(curCount);

    function updateLotteryPreview(base) {
        var cur = (base !== undefined) ? base : curCount;
        var op = $('#lotteryOp').val();
        var delta = parseInt($('#lotteryDelta').val()) || 0;
        var result = op === 'add' ? cur + delta : cur - delta;
        var color = result < 0 ? '#e53e3e' : '#319795';
        $('#lotteryPreview').html('调整后次数：<strong style="color:' + color + ';">' + result + ' �?/strong>' + (result < 0 ? ' <span style="color:#e53e3e;">（不足，无法操作�?/span>' : ''));
    }

    $('<div/>').dialog({
        title: '🎰 调整抽奖次数',
        width: 320,
        height: 260,
        modal: true,
        content: $('#' + dlgId).show(),
        buttons: [{
            text: '确认',
            iconCls: 'icon-ok',
            handler: function() {
                var op = $('#lotteryOp').val();
                var delta = parseInt($('#lotteryDelta').val());
                if (isNaN(delta) || delta <= 0) {
                    $.messager.alert('提示', '请输入有效的正整数次�?, 'warning'); return;
                }
                var finalDelta = op === 'add' ? delta : -delta;
                $.post(ctx + '/user/setLotteryCount', { studentId: studentId, delta: finalDelta }, function(res) {
                    if (res.success) {
                        $.messager.show({ title: '成功', msg: '抽奖次数已调整为 ' + res.newCount + ' �?, showType: 'slide', timeout: 2000 });
                        $('#userTable').datagrid('reload');
                        $(this).closest('.window-body').parent().window('close');
                    } else {
                        $.messager.alert('失败', res.message || '操作失败', 'error');
                    }
                }, 'json');
            }
        },{
            text: '取消',
            handler: function() {
                $(this).closest('.window-body').parent().window('close');
            }
        }]
    });
}
function formatFlowerCount(val) {
    if (val == null || val === '') return '<span style="color:#a0aec0;">-</span>';
    return '<span style="color:#ff758c;font-weight:bold;">🌸 ' + val + ' �?/span>';
}
function adjustFlower(studentId, studentName, current) {
    $('#flowerStudentId').val(studentId);
    $('#flowerCurrentVal').val(current);
    $('#flowerCurrentDisplay').text(current);
    $('#flowerStudentNameDisplay').text(studentName);
    $('#flowerDelta').val(1);
    $('#flowerOp').val('add');
    $('#flowerRemark').val('');
    $('#flowerPreview').html('');
    $('#flowerDlg').dialog('open').dialog('setTitle', '🌸 小红花管�?- ' + studentName);
}
function calcFlowerPreview() {
    var op = $('#flowerOp').val();
    var current = parseInt($('#flowerCurrentVal').val()) || 0;
    var delta = parseInt($('#flowerDelta').val()) || 0;
    var result = op === 'add' ? current + delta : current - delta;
    var color = result < 0 ? '#e53e3e' : '#38a169';
    $('#flowerPreview').html('调整后余量：<strong style="color:' + color + ';">' + result + ' �?/strong>'
        + (result < 0 ? '&nbsp;<span style="color:#e53e3e;">（余量不足）</span>' : ''));
}
function confirmFlowerAdjust() {
    var studentId = $('#flowerStudentId').val();
    var op = $('#flowerOp').val();
    var delta = parseInt($('#flowerDelta').val()) || 0;
    var remark = $.trim($('#flowerRemark').val());
    if (delta <= 0) { $.messager.alert('提示', '请输入大�?的数�?, 'warning'); return; }
    var finalDelta = op === 'add' ? delta : -delta;
    $.post(ctx + '/flower/manage/adjust', { studentId: studentId, delta: finalDelta, remark: remark }, function(res) {
        if (res.success) {
            $('#flowerDlg').dialog('close');
            $.messager.show({ title: '成功', msg: res.message, showType: 'slide', timeout: 2000 });
            $('#userTable').datagrid('reload');
        } else {
            $.messager.alert('失败', res.message || '操作失败', 'error');
        }
    }, 'json');
}
function formatStatus(val) {
    if(val==1) return '<span style="color:green">启用</span>';
    if(val==0) return '<span style="color:red">禁用</span>';
    if(val==2) return '<span style="color:orange">待注�?/span>';
    return val;
}
function formatUserType(val, row) {
    if (row.parentId == null) {
        if (row.username === 'admin') {
            return '<span style="color:#e53e3e;font-weight:bold;">👑 管理�?/span>';
        } else if (row.username && row.username.startsWith('TEMP_')) {
            return '<span style="color:#f6ad55;font-weight:bold;">�?待注册家�?/span>';
        } else {
            return '<span style="color:#38b2ac;font-weight:bold;">👨‍👩‍👧‍�?家长</span>';
        }
    } else {
        return '<span style="color:#319795;font-weight:bold;">👦 学生</span>';
    }
}
function formatOp(val,row) {
    var ops = '';
    
    // 待注册用户只能删�?
    if (row.status == 2) {
        ops = '<span style="color:#999;">待用户注�?/span> '
            + '<a href="javascript:void(0)" onclick="delUser('+row.id+')">删除</a>';
    } else {
        // 正常用户的操�?
        ops = '<a href="javascript:void(0)" onclick="openEdit('+row.id+')">编辑</a> '
            + '<a href="javascript:void(0)" onclick="resetPwd('+row.id+')">重置密码</a> '
            + (row.status==1 ? '<a href="javascript:void(0)" onclick="changeStatus('+row.id+',0)">禁用</a>' : '<a href="javascript:void(0)" onclick="changeStatus('+row.id+',1)">启用</a>')
            + ' <a href="javascript:void(0)" onclick="delUser('+row.id+')">删除</a>';
        
        // 如果是学生用户，添加二维码管理功�?
        if (row.parentId != null) {
            ops += ' <a href="javascript:void(0)" onclick="showQrCode('+row.id+')">二维�?/a>';
            ops += ' <a href="javascript:void(0)" onclick="setLotteryCount('+row.id+','+(row.lotteryCount||0)+')" style="color:#319795;">🎰抽奖次数</a>';
            ops += ' <a href="javascript:void(0)" onclick="adjustFlower('+row.id+',\''+(row.realName||row.username)+'\','+(row.flowerCount||0)+')" style="color:#ff758c;">🌸小红�?/a>';
        }
    }
    
    return ops;
}
function openAdd() {
    $('#fm').form('clear');
    
    if (window.isParentUser) {
        // 家长用户直接添加学生
        $('#parentFields').hide();
        $('#studentFields').show();
        // 隐藏用户类型选择
        $('#userTypeField').hide();
        // 隐藏所属家长选择（家长添加的学生默认属于自己�?
        $('#parentSelectField').hide();
        // 设置默认用户类型为学�?
        $('#userType').combobox('setValue', 'student');
        // 设置默认状态为启用
        $('select[name="status"]').combobox('setValue', 1);
        $('#dlg').dialog('open').dialog('setTitle','新增学生');
    } else {
        // 管理员用户显示完整界�?
        $('#parentFields').hide();
        $('#studentFields').hide();
        $('#userTypeField').show();
        // 清空注册码输入框
        $('#authCodeInput').val('');
        $('#dlg').dialog('open').dialog('setTitle','新增用户');
    }
}

// 处理用户类型切换
function handleUserTypeChange(userType) {
    console.log('User type changed to: ' + userType); // 添加调试信息
    
    if (userType === 'parent') {
        $('#parentFields').show();
        $('#studentFields').hide();
    } else if (userType === 'student') {
        $('#parentFields').hide();
        $('#studentFields').show();
    } else {
        $('#parentFields').hide();
        $('#studentFields').hide();
    }
}

// 生成随机注册�?
function generateAuthCode() {
    console.log('generateAuthCode called');
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    var authCode = '';
    for (var i = 0; i < 8; i++) {
        authCode += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    console.log('Generated auth code: ' + authCode);
    
    // 直接设置input的�?
    $('#authCodeInput').val(authCode);
    console.log('Set auth code to input: ' + authCode);
    
    // 验证是否设置成功
    var value = $('#authCodeInput').val();
    console.log('Current input value: ' + value);
}
function openEdit(id) {
    var row = $('#userTable').datagrid('getRows').find(r=>r.id==id);
    if(row){
        $('#fm').form('clear');
        $('#fm').form('load', row);
        
        // 根据用户类型显示对应的界�?
        if (row.parentId == null) {
            // 家长用户（包括admin和普通家长）
            if (row.username === 'admin') {
                // admin用户特殊处理
                $('#userTypeField').hide();
                $('#parentFields').hide();
                $('#studentFields').show();
                $('#parentSelectField').hide(); // admin不需要选择家长
                $('#dlg').dialog('open').dialog('setTitle','编辑管理�?);
            } else {
                // 普通家长用�?
                $('#userTypeField').hide();
                $('#parentFields').show();
                $('#studentFields').hide();
                $('#userType').combobox('setValue', 'parent');
                $('#dlg').dialog('open').dialog('setTitle','编辑家长');
            }
        } else {
            // 学生用户
            $('#userTypeField').hide();
            $('#parentFields').hide();
            $('#studentFields').show();
            $('#userType').combobox('setValue', 'student');
            
            // 只有admin用户编辑学生时才显示所属家长字�?
            if (window.isAdminUser) {
                // admin用户编辑学生：显示所属家长选择
                $('#parentSelectField').show();
            } else {
                // 家长用户编辑学生：隐藏所属家长选择（默认就是自己）
                $('#parentSelectField').hide();
            }
            
            $('#dlg').dialog('open').dialog('setTitle','编辑学生');
        }
    }
}
function saveUser() {
    var data = $('#fm').serializeArray().reduce(function(obj, item) { obj[item.name] = item.value; return obj; }, {});
    var userType = data.userType;
    
    // 验证必填字段（编辑时用户类型可能为空，需要从界面状态判断）
    if (!userType) {
        // 如果userType为空，根据当前显示的界面判断用户类型
        if ($('#parentFields').is(':visible')) {
            userType = 'parent';
            data.userType = 'parent';
        } else if ($('#studentFields').is(':visible')) {
            userType = 'student';
            data.userType = 'student';
        } else {
            $.messager.alert('提示', '无法确定用户类型', 'warning');
            return;
        }
    }
    
    var originalAuthCode = data.authCode; // 保存原始注册码用于显�?
    
    if (userType === 'parent') {
        // 家长用户：只需要注册码
        if (!data.authCode) {
            $.messager.alert('提示', '请生成注册码', 'warning');
            return;
        }
        // 家长用户创建时只保留注册码，其他字段家长注册时自己填�?
        // 只保留必要的字段
        data = {
            userType: 'parent',
            authCode: data.authCode,
            status: 2  // 状�?表示待注�?
        };
    } else if (userType === 'student') {
        // 学生用户：需要完整信�?
        if (window.isParentUser) {
            // 家长用户添加学生：不需要选择parentId，自动设置为当前用户
            if (!data.username || !data.realName || !data.password || !data.status) {
                $.messager.alert('提示', '请填写学生的必填信息', 'warning');
                return;
            }
            // parentId会在后端自动设置为当前用户ID
            delete data.parentId;
        } else {
            // 管理员添加学生：需要选择parentId
            if (!data.parentId || !data.username || !data.realName || !data.password || !data.status) {
                $.messager.alert('提示', '请填写学生的必填信息', 'warning');
                return;
            }
        }
        // 清除注册码字�?
        delete data.authCode;
    }
    
    var url = data.id ? '/user/update' : '/user/add';
    $.ajax({
        url: url,
        type: 'post',
        contentType: 'application/json',
        data: JSON.stringify(data),
        success: function(res) {
            if (res === 'success') {
                if (userType === 'parent') {
                    $.messager.show({
                        title: '成功',
                        msg: '家长注册码已生成�? + originalAuthCode + '，请告知家长使用此码注册',
                        timeout: 5000,
                        showType: 'slide'
                    });
                } else {
                    $.messager.show({
                        title: '成功', 
                        msg: '学生用户创建成功',
                        timeout: 3000,
                        showType: 'slide'
                    });
                }
                $('#dlg').dialog('close');
                $('#userTable').datagrid('reload');
            } else {
                $.messager.alert('错误', '保存失败�? + res, 'error');
            }
        },
        error: function(xhr, status, error) {
            $.messager.alert('错误', '保存失败�? + error, 'error');
        }
    });
}
function closeDlg() {
    $('#dlg').dialog('close');
}
function delUser(id) {
    $.post(ctx + '/user/delete', {id:id}, function(res){
        $('#userTable').datagrid('reload');
    });
}
function resetPwd(id) {
    var newPwd = prompt('请输入新密码');
    if(newPwd){
        $.post(ctx + '/user/resetPassword', {id:id, newPassword:newPwd}, function(res){
            alert('密码已重�?);
        });
    }
}
function changeStatus(id, status) {
    $.post(ctx + '/user/changeStatus', {id:id, status:status}, function(res){
        $('#userTable').datagrid('reload');
    });
}

// 显示学生二维�?
function showQrCode(studentId) {
    // 先获取二维码信息
    $.get(ctx + '/user/getQrCode', {studentId: studentId}, function(data) {
        if (data.success) {
            if (data.hasQrCode) {
                // 显示现有二维�?
                $('#qrCodeValue').text(data.qrCode);
                $('#qrCodeUrl').text(data.qrUrl);
                $('#qrCodeLink').attr('href', data.qrPreviewUrl || data.qrUrl);
                $('#qrCodeInfo').show();
                $('#noQrCodeInfo').hide();
            } else {
                // 显示无二维码状�?
                $('#qrCodeInfo').hide();
                $('#noQrCodeInfo').show();
            }
            
            // 设置当前学生ID
            $('#currentStudentId').val(studentId);
            
            // 打开对话�?
            $('#qrCodeDialog').dialog('open').dialog('setTitle', '学生二维码管�?);
        } else {
            $.messager.alert('错误', data.message, 'error');
        }
    });
}

// 生成新二维码
function generateNewQrCode() {
    var studentId = $('#currentStudentId').val();
    if (!studentId) return;
    
    $.messager.confirm('确认', '确定要为该学生生成新的二维码吗？<br/>原有二维码将失效�?, function(r) {
        if (r) {
            $.messager.progress({title: '生成�?..', msg: '正在生成二维码，请稍�?..'});
            
            $.post(ctx + '/user/generateQrCode', {studentId: studentId}, function(data) {
                $.messager.progress('close');
                
                if (data.success) {
                    // 更新显示
                    $('#qrCodeValue').text(data.qrCode);
                    $('#qrCodeUrl').text(data.qrUrl);
                    $('#qrCodeLink').attr('href', data.qrPreviewUrl || data.qrUrl);
                    $('#qrCodeInfo').show();
                    $('#noQrCodeInfo').hide();
                    
                    $.messager.show({
                        title: '成功',
                        msg: '二维码生成成功！',
                        showType: 'slide',
                        timeout: 3000
                    });
                } else {
                    $.messager.alert('错误', data.message, 'error');
                }
            });
        }
    });
}

// 复制二维码URL
function copyQrCodeUrl() {
    var url = $('#qrCodeUrl').text();
    if (navigator.clipboard) {
        navigator.clipboard.writeText(url).then(function() {
            $.messager.show({
                title: '成功',
                msg: '二维码链接已复制到剪贴板',
                showType: 'slide',
                timeout: 2000
            });
        });
    } else {
        // 降级方案
        var textArea = document.createElement("textarea");
        textArea.value = url;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        
        $.messager.show({
            title: '成功',
            msg: '二维码链接已复制到剪贴板',
            showType: 'slide',
            timeout: 2000
        });
    }
}
</script>

<!-- 二维码管理对话框 -->
<div id="qrCodeDialog" class="easyui-dialog" style="width:500px;height:400px" closed="true"
     data-options="modal:true,resizable:false,shadow:true,collapsible:false,maximizable:false">
    <div style="text-align:center;margin-bottom:20px;color:#2d3748;font-size:1.1rem;font-weight:500;">
        📱 学生二维码管�?
    </div>
    
    <input type="hidden" id="currentStudentId">
    
    <!-- 有二维码时显�?-->
    <div id="qrCodeInfo" style="display:none;">
        <div style="background:#f7fafc;border-radius:8px;padding:20px;margin-bottom:20px;">
            <div style="margin-bottom:15px;">
                <label style="display:block;margin-bottom:5px;color:#4a5568;font-weight:500;">
                    🔗 二维码标识：
                </label>
                <div style="background:white;padding:10px;border-radius:4px;border:1px solid #e2e8f0;font-family:monospace;word-break:break-all;">
                    <span id="qrCodeValue"></span>
                </div>
            </div>
            
            <div style="margin-bottom:15px;">
                <label style="display:block;margin-bottom:5px;color:#4a5568;font-weight:500;">
                    🌐 二维码链接：
                </label>
                <div style="background:white;padding:10px;border-radius:4px;border:1px solid #e2e8f0;font-size:12px;word-break:break-all;">
                    <span id="qrCodeUrl"></span>
                </div>
            </div>
            
            <div style="text-align:center;margin-top:20px;">
                <a id="qrCodeLink" href="#" target="_blank" class="easyui-linkbutton" 
                   data-options="iconCls:'icon-search'" 
                   style="margin-right:10px;">查看二维�?/a>
                <a href="javascript:void(0)" class="easyui-linkbutton" 
                   data-options="iconCls:'icon-edit'" 
                   onclick="copyQrCodeUrl()" 
                   style="margin-right:10px;">复制链接</a>
                <a href="javascript:void(0)" class="easyui-linkbutton" 
                   data-options="iconCls:'icon-reload'" 
                   onclick="generateNewQrCode()">重新生成</a>
            </div>
        </div>
    </div>
    
    <!-- 无二维码时显�?-->
    <div id="noQrCodeInfo" style="display:none;">
        <div style="text-align:center;padding:40px 20px;">
            <div style="font-size:3rem;margin-bottom:15px;">📱</div>
            <p style="color:#718096;margin-bottom:20px;">该学生还没有二维�?/p>
            <a href="javascript:void(0)" class="easyui-linkbutton" 
               data-options="iconCls:'icon-add'" 
               onclick="generateNewQrCode()" 
               style="background:#4fd1c5;border-color:#38b2ac;">立即生成</a>
        </div>
    </div>
    
    <div style="margin-top:20px;padding:15px;background:#e6fffa;border-radius:8px;border-left:4px solid #4fd1c5;">
        <h4 style="margin:0 0 10px 0;color:#2d3748;">💡 使用说明�?/h4>
        <ul style="margin:0;padding-left:20px;color:#4a5568;font-size:14px;">
            <li>学生可以扫描二维码进入移动端登录页面</li>
            <li>输入用户名和密码后可直接进行打卡操作</li>
            <li>每个学生的二维码都是唯一�?/li>
            <li>重新生成会使原二维码失效</li>
        </ul>
    </div>
</div>

<!-- 小红花调整对话框 -->
<div id="flowerDlg" class="easyui-dialog" style="width:400px;" closed="true"
     data-options="modal:true,resizable:false,buttons:'#flowerDlgBtns'">
    <div style="padding:16px 20px;">
        <input type="hidden" id="flowerStudentId">
        <input type="hidden" id="flowerCurrentVal">
        <div style="margin-bottom:14px;color:#4a5568;">
            当前�?strong id="flowerStudentNameDisplay"></strong>」小红花余量�?
            <strong style="color:#ff758c;" id="flowerCurrentDisplay">0</strong> �?
        </div>
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px;">
            <label style="color:#4a5568;font-size:0.9rem;white-space:nowrap;">操作�?/label>
            <select id="flowerOp" onchange="calcFlowerPreview()"
                    style="height:32px;padding:0 8px;border:1px solid #d2d6dc;border-radius:4px;">
                <option value="add">增加 🌸</option>
                <option value="sub">减少</option>
            </select>
            <input id="flowerDelta" type="number" min="1" value="1" oninput="calcFlowerPreview()"
                   style="width:80px;height:32px;padding:0 8px;border:1px solid #d2d6dc;border-radius:4px;">
            <span style="color:#4a5568;font-size:0.9rem;">�?/span>
        </div>
        <div style="margin-bottom:14px;">
            <label style="display:block;margin-bottom:6px;color:#4a5568;font-size:0.9rem;">备注（可选）�?/label>
            <input id="flowerRemark" type="text" placeholder="如：奖励认真学习"
                   style="width:100%;height:32px;padding:0 8px;border:1px solid #d2d6dc;border-radius:4px;box-sizing:border-box;">
        </div>
        <div id="flowerPreview" style="font-size:0.88rem;color:#718096;min-height:20px;"></div>
    </div>
</div>
<div id="flowerDlgBtns" style="text-align:center;">
    <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-save'"
       style="width:70px;margin-right:8px;" onclick="confirmFlowerAdjust()">确认</a>
    <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-cancel'"
       style="width:70px;" onclick="$('#flowerDlg').dialog('close')">取消</a>
</div>

</body>
</html>
