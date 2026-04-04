<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>打卡记录 - 学生打卡系统</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>
    <style>
        body { background: #e6fffa; margin: 0; }
        .header { background: linear-gradient(120deg, #4fd1c5 0%, #38b2ac 100%); color: #fff; padding: 18px 32px; font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
        .main-content { padding: 20px; max-height: calc(100vh - 120px); overflow-y: auto; width: 100%; box-sizing: border-box; }
        
        /* 积分动画效果 */
        @keyframes pointsUpdate {
            0% { transform: scale(1); }
            50% { transform: scale(1.2); color: #feca57; }
            100% { transform: scale(1); }
        }
        
        .points-update {
            animation: pointsUpdate 0.6s ease-in-out;
        }
        
        /* 积分面板悬停效果 */
        #studentPointsPanel .panel-body > div > div {
            transition: all 0.3s ease;
        }
        
        #studentPointsPanel:hover .panel-body > div > div {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(102, 126, 234, 0.4);
        }
        
        /* 面板自适应宽度 */
        #todayItemsPanel, #studentPointsPanel {
            width: 100% !important;
            max-width: 100% !important;
            box-sizing: border-box;
        }
        
        #todayItemsPanel .panel-body, #studentPointsPanel .panel-body {
            overflow-x: hidden;
            box-sizing: border-box;
        }
        
        /* 确保表格完全自适应面板宽度 */
        #checkinItemTable {
            width: 100% !important;
        }
        
        #checkinItemTable .datagrid-view {
            width: 100% !important;
            overflow-x: hidden !important;
        }
        
        #checkinItemTable .datagrid-view table {
            width: 100% !important;
            table-layout: fixed !important;
        }
        
        #checkinItemTable .datagrid-view .datagrid-header {
            overflow-x: hidden !important;
        }
        
        #checkinItemTable .datagrid-view .datagrid-body {
            overflow-x: hidden !important;
        }
        
        /* 强制列按百分比分配，不允许超出 */
        #checkinItemTable .datagrid-view .datagrid-header-inner table,
        #checkinItemTable .datagrid-view .datagrid-body table {
            width: 100% !important;
            min-width: 100% !important;
            max-width: 100% !important;
        }
        
        /* 完全隐藏所有滚动条 */
        #checkinItemTable .datagrid-view .datagrid-body .datagrid-body-inner {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }
        
        #checkinItemTable .datagrid-view .datagrid-header .datagrid-header-inner {
            overflow: hidden !important;
        }
        
        /* 隐藏EasyUI自动生成的滚动条容器 */
        #checkinItemTable .datagrid-view .datagrid-body .datagrid-body-inner::-webkit-scrollbar {
            width: 0px !important;
            height: 0px !important;
        }
        
        #checkinItemTable .datagrid-view .datagrid-body .datagrid-body-inner {
            scrollbar-width: none !important;
            -ms-overflow-style: none !important;
        }
        
        /* 强制隐藏所有可能的滚动条元素 */
        #checkinItemTable .datagrid-view,
        #checkinItemTable .datagrid-view2,
        #checkinItemTable .datagrid-view1 {
            overflow: hidden !important;
        }
        
        #checkinItemTable .datagrid-view .datagrid-body,
        #checkinItemTable .datagrid-view2 .datagrid-body,
        #checkinItemTable .datagrid-view1 .datagrid-body {
            overflow: hidden !important;
        }
        
        /* 隐藏底部可能出现的滚动条区域 */
        #checkinItemTable .datagrid-view .datagrid-body .datagrid-body-inner,
        #checkinItemTable .datagrid-view2 .datagrid-body .datagrid-body-inner,
        #checkinItemTable .datagrid-view1 .datagrid-body .datagrid-body-inner {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }
        
        /* 完全隐藏滚动条 */
        #checkinItemTable * {
            scrollbar-width: none !important;
            -ms-overflow-style: none !important;
        }
        
        #checkinItemTable *::-webkit-scrollbar {
            width: 0px !important;
            height: 0px !important;
            display: none !important;
        }
        
        /* 确保表格内容自动换行 */
        #checkinItemTable .datagrid-cell {
            white-space: normal !important;
            word-wrap: break-word !important;
            word-break: break-all !important;
            line-height: 1.4 !important;
            padding: 4px 6px !important;
        }
        
        /* 调整行高以适应多行内容 */
        #checkinItemTable .datagrid-row {
            height: auto !important;
            min-height: 32px !important;
        }
        
        /* 响应式设计 */
        @media (max-height: 800px) {
            .main-content { padding: 15px; }
            #checkinItemTable { height: 150px !important; }
            #recordTable { height: 200px !important; }
        }
        
        @media (max-height: 600px) {
            .main-content { padding: 10px; }
            #checkinItemTable { height: 120px !important; }
            #recordTable { height: 150px !important; }
            #studentPointsPanel .panel-body > div > div { padding: 15px 20px; }
        }
    </style>
</head>
<body>
<div class="header">打卡记录</div>
<div class="main-content">
    <!-- 学生积分展示区域 -->
    <div id="studentPointsPanel" class="easyui-panel" title="🏆 我的积分" style="margin-bottom:20px;padding:15px;display:none;">
        <div style="text-align:center;">
            <div style="display:inline-block;background:linear-gradient(135deg, #667eea 0%, #764ba2 100%);color:white;padding:20px 30px;border-radius:20px;box-shadow:0 8px 25px rgba(102, 126, 234, 0.3);">
                <div style="font-size:16px;margin-bottom:8px;opacity:0.9;">当前总积分</div>
                <div id="totalPoints" style="font-size:36px;font-weight:bold;">0</div>
                <div style="font-size:14px;margin-top:8px;opacity:0.8;">🎉 继续加油哦！</div>
            </div>
        </div>
    </div>
    <!-- 可打卡事项列表 -->
    <div id="todayItemsPanel" class="easyui-panel" title="📝 今日可打卡事项" style="margin-bottom:20px;padding:10px;display:none;">
        <div id="adminStudentSelector" style="margin-bottom:15px;display:none;">
            <label style="color:#4a5568;font-weight:500;margin-right:10px;">👨‍🎓 选择学生：</label>
            <select id="selectedStudentId" class="easyui-combobox" 
                    data-options="prompt:'选择要打卡的学生',iconCls:'icon-man',editable:false,valueField:'id',textField:'realName',url:'/user/studentList',method:'get',onSelect:onStudentChange" 
                    style="width:200px;height:32px;">
            </select>
            <span style="color:#718096;font-size:0.9rem;margin-left:10px;">💡 管理员可以为任何学生打卡</span>
        </div>
        <table id="checkinItemTable" class="easyui-datagrid" style="width:95%;height:200px;margin:0 auto;"
               data-options="url:'/checkin/item/todayList',method:'get',rownumbers:true,singleSelect:true,fitColumns:true,scrollbarSize:0,rowStyler:checkinItemRowStyler,onLoadSuccess:hideTableScrollbars,nowrap:false">
            <thead>
            <tr>
                <th data-options="field:'id',width:40,hidden:true">ID</th>
                <th data-options="field:'itemName',width:'15%'">📝 事项名称</th>
                <th data-options="field:'description',width:'20%'">📋 描述</th>
                <th data-options="field:'points',width:'8%'">🏆 积分</th>
                <th data-options="field:'todayStatus',width:'15%',formatter:formatTodayStatus">📊 今日状态</th>
                <th data-options="field:'timeRange',width:'15%',formatter:formatTimeRange">⏰ 时间</th>
                <th data-options="field:'operation',width:'27%',formatter:formatCheckinOp">操作</th>
            </tr>
            </thead>
        </table>
    </div>

    <!-- 打卡记录查询 -->
    <div class="easyui-panel" title="📊 打卡记录" style="margin-bottom:20px;padding:10px;">
        <div style="margin-bottom:16px;">
            <input id="search_date" class="easyui-datebox" prompt="日期" style="width:120px;">
            <input id="search_status" class="easyui-combobox" prompt="状态" style="width:100px;"
                   data-options="valueField:'value',textField:'label',data:[{value:'',label:'全部'},{value:1,label:'已打卡'},{value:2,label:'已撤销'}]">
            <a href="javascript:void(0)" class="easyui-linkbutton" onclick="doSearch()">查询</a>
        </div>
        <table id="recordTable" class="easyui-datagrid" style="width:97%;height:250px;margin:0 auto;"
               data-options="url:'/checkinRecord/list',method:'get',pagination:true,rownumbers:true,singleSelect:true,fitColumns:true">
        <thead>
        <tr>
            <th data-options="field:'id',width:40">ID</th>
            <th data-options="field:'itemName',width:120">📝 事项名称</th>
            <th data-options="field:'checkinDate',width:100">打卡日期</th>
            <th data-options="field:'status',width:80,formatter:formatStatus">状态</th>
            <th data-options="field:'checkinTime',width:120">打卡时间</th>
            <th data-options="field:'cancelTime',width:120">撤销时间</th>
            <th data-options="field:'remark',width:120">备注</th>
            <th data-options="field:'operation',width:180,formatter:formatOp">操作</th>
        </tr>
        </thead>
    </table>
</div>

<script>
// 页面加载完成后检查用户角色
// 强制隐藏表格滚动条的函数
function hideTableScrollbars() {
    setTimeout(function() {
        // 隐藏所有可能的滚动条元素
        $('#checkinItemTable').find('.datagrid-view, .datagrid-view1, .datagrid-view2').each(function() {
            $(this).css({
                'overflow': 'hidden',
                'overflow-x': 'hidden',
                'overflow-y': 'hidden'
            });
        });
        
        $('#checkinItemTable').find('.datagrid-body').each(function() {
            $(this).css({
                'overflow': 'hidden',
                'overflow-x': 'hidden'
            });
        });
        
        $('#checkinItemTable').find('.datagrid-body-inner').each(function() {
            $(this).css({
                'overflow-x': 'hidden',
                'overflow-y': 'auto'
            });
        });
        
        // 确保单元格内容可以换行
        $('#checkinItemTable').find('.datagrid-cell').each(function() {
            $(this).css({
                'white-space': 'normal',
                'word-wrap': 'break-word',
                'word-break': 'break-all',
                'line-height': '1.4',
                'padding': '4px 6px'
            });
        });
        
        // 调整行高
        $('#checkinItemTable').find('.datagrid-row').each(function() {
            $(this).css({
                'height': 'auto',
                'min-height': '32px'
            });
        });
        
        // 隐藏滚动条样式
        $('<style>')
            .prop('type', 'text/css')
            .html('#checkinItemTable .datagrid-view ::-webkit-scrollbar { width: 0px !important; height: 0px !important; display: none !important; }')
            .appendTo('head');
    }, 100);
}

$(document).ready(function() {
    // 通过Ajax获取当前用户信息
    $.get('/user/currentUser', function(user) {
        // 存储用户信息到全局变量
        window.currentUser = user;
        
        if (user && user.parentId == null && user.username === 'admin') {
            // admin用户：只显示学生选择器，不显示积分和今日可打卡事项
            $('#adminStudentSelector').show();
        } else if (user && user.parentId == null && user.username !== 'admin') {
            // 家长用户：不显示积分和今日可打卡事项
            // 家长主要查看历史记录和进行管理操作
        } else if (user && user.parentId != null) {
            // 学生用户：显示积分面板和今日可打卡事项区域
            $('#studentPointsPanel').show();
            $('#todayItemsPanel').show();
            updateStudentPoints(user.totalPoints || 0, false); // 初始化时不使用动画
        }
        
        // 重新加载表格以应用权限控制
        $('#recordTable').datagrid('reload');
        $('#checkinItemTable').datagrid('reload');
        
        // 强制隐藏滚动条
        hideTableScrollbars();
    });
});

// 学生选择改变时的回调
function onStudentChange(record) {
    // 当管理员选择不同学生时，刷新今日可打卡事项表格
    var studentId = record.id;
    $('#checkinItemTable').datagrid('reload', {
        studentId: studentId
    });
}

// 更新学生积分显示
function updateStudentPoints(points, withAnimation) {
    var $pointsElement = $('#totalPoints');
    
    if (withAnimation !== false) {
        // 添加动画效果
        $pointsElement.addClass('points-update');
        setTimeout(function() {
            $pointsElement.removeClass('points-update');
        }, 600);
    }
    
    $pointsElement.text(points);
    
    // 根据积分数量显示不同的鼓励语
    var encourageMsg = '';
    if (points >= 100) {
        encourageMsg = '🌟 积分达人！';
    } else if (points >= 50) {
        encourageMsg = '🎯 表现优秀！';
    } else if (points >= 20) {
        encourageMsg = '💪 继续努力！';
    } else {
        encourageMsg = '🎉 继续加油哦！';
    }
    
    $pointsElement.next().text(encourageMsg);
}

function doSearch() {
    $('#recordTable').datagrid('load', {
        date: $('#search_date').datebox('getValue'),
        status: $('#search_status').combobox('getValue')
    });
}

// 时间范围格式化（复用打卡管理页面的函数）
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

// 事项状态格式化
function formatItemStatus(val) {
    if(val == 0) return '<span style="color:#f6ad55;font-weight:bold;">⏳ 未打卡</span>';
    if(val == 1) return '<span style="color:#38b2ac;font-weight:bold;">✅ 已打卡</span>';
    if(val == 2) return '<span style="color:#e53e3e;font-weight:bold;">🚫 禁用</span>';
    return val;
}

// 今日状态格式化
function formatTodayStatus(val) {
    if(val == 0) return '<span style="color:#f6ad55;font-weight:bold;">⏳ 未打卡</span>';
    if(val == 1) return '<span style="color:#38b2ac;font-weight:bold;">✅ 已打卡</span>';
    return val;
}

// 打卡事项行样式函数
function checkinItemRowStyler(index, row) {
    // 如果已打卡，背景为绿色
    if (row.todayStatus == 1) {
        return 'background-color: #e6ffed; color: #2d5a2d;'; // 浅绿色背景
    }
    
    // 如果未打卡，需要判断是否超时
    if (row.todayStatus == 0) {
        // 获取当前时间
        var now = new Date();
        var currentTime = now.getHours() * 60 + now.getMinutes(); // 转换为分钟
        
        // 如果有结束时间，判断是否超时
        if (row.checkinEndTime) {
            var endTimeParts = row.checkinEndTime.split(':');
            var endTimeMinutes = parseInt(endTimeParts[0]) * 60 + parseInt(endTimeParts[1]);
            
            // 如果当前时间超过结束时间，显示红色（超时）
            if (currentTime > endTimeMinutes) {
                return 'background-color: #ffe6e6; color: #8b0000;'; // 浅红色背景
            }
        }
        
        // 未打卡且未超时，显示黄色
        return 'background-color: #fff9e6; color: #8b6914;'; // 浅黄色背景
    }
    
    return ''; // 默认样式
}

// 打卡操作按钮
function formatCheckinOp(val, row) {
    // 使用todayStatus来判断今日打卡状态
    if (row.todayStatus == 0) {
        return '<button onclick="doCheckinAction(' + row.id + ')" style="' +
               'background: linear-gradient(135deg, #ff6b6b, #feca57);' +
               'color: white;' +
               'border: none;' +
               'border-radius: 25px;' +
               'padding: 8px 20px;' +
               'font-size: 14px;' +
               'font-weight: bold;' +
               'cursor: pointer;' +
               'box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);' +
               'transition: all 0.3s ease;' +
               'transform: scale(1);' +
               '" onmouseover="this.style.transform=\'scale(1.05)\';this.style.boxShadow=\'0 6px 20px rgba(255, 107, 107, 0.4)\';" ' +
               'onmouseout="this.style.transform=\'scale(1)\';this.style.boxShadow=\'0 4px 15px rgba(255, 107, 107, 0.3)\';" ' +
               'onmousedown="this.style.transform=\'scale(0.95)\';" ' +
               'onmouseup="this.style.transform=\'scale(1.05)\';">' +
               '🎯 立即打卡 ✨</button>';
    } else if (row.todayStatus == 1) {
        return '<button onclick="doRevokeAction(' + row.id + ')" style="' +
               'background: linear-gradient(135deg, #ffa726, #ff7043);' +
               'color: white;' +
               'border: none;' +
               'border-radius: 20px;' +
               'padding: 6px 16px;' +
               'font-size: 12px;' +
               'font-weight: bold;' +
               'cursor: pointer;' +
               'box-shadow: 0 3px 10px rgba(255, 167, 38, 0.3);' +
               'transition: all 0.3s ease;' +
               'margin-right: 8px;' +
               '" onmouseover="this.style.transform=\'scale(1.05)\';" ' +
               'onmouseout="this.style.transform=\'scale(1)\';">' +
               '🔄 撤销</button>' +
               '<span style="color:#38b2ac;font-size:12px;font-weight:bold;">✅ 已完成</span>';
    } else {
        return '<span style="color:#999;padding:8px 20px;font-size:14px;">🚫 暂不可打卡</span>';
    }
}

// 执行打卡
function doCheckinAction(itemId) {
    var selectedStudentId = $('#selectedStudentId').combobox('getValue');
    var params = {itemId: itemId};
    
    if (selectedStudentId && $('#adminStudentSelector').is(':visible')) {
        params.studentId = selectedStudentId;
    }
    
    // 显示打卡进行中的提示
    $.messager.progress({
        title: '正在打卡...',
        msg: '打卡进行中，请稍候...'
    });
    
    $.post('/checkinRecord/doCheckin', params, function(res){
        $.messager.progress('close');
        
        if (res === 'success') {
            // 播放成功动画效果
            $.messager.show({
                title: '🎉 打卡成功！',
                msg: '恭喜你完成了今日打卡任务！🎊',
                timeout: 3000,
                showType: 'slide',
                style: {
                    right: '',
                    bottom: ''
                }
            });
            $('#recordTable').datagrid('reload');
            $('#checkinItemTable').datagrid('reload');
            
            // 重新获取用户信息以更新积分显示
            if (window.currentUser && window.currentUser.parentId != null) {
                $.get('/user/currentUser', function(user) {
                    if (user) {
                        window.currentUser = user;
                        updateStudentPoints(user.totalPoints || 0, true); // 打卡后使用动画
                        
                        // 显示积分增加的提示
                        setTimeout(function() {
                            $.messager.show({
                                title: '✨ 积分更新',
                                msg: '当前总积分：' + (user.totalPoints || 0) + ' 分！',
                                timeout: 2000,
                                showType: 'fade'
                            });
                        }, 1000);
                    }
                });
            }
        } else if (res === 'already_checked') {
            $.messager.show({
                title: '💡 提示',
                msg: '今日已经打过卡啦！😊',
                timeout: 2000,
                showType: 'slide'
            });
        } else if (res === 'no_permission') {
            $.messager.alert('❌ 错误', '没有权限进行打卡操作！', 'error');
        } else {
            $.messager.alert('❌ 错误', '打卡失败：' + res, 'error');
        }
    }).fail(function(){
        $.messager.progress('close');
        $.messager.alert('❌ 错误', '网络错误，请重试！', 'error');
    });
}

// 撤销打卡
function doRevokeAction(itemId) {
    $.messager.confirm('确认撤销', '确定要撤销今日的打卡记录吗？<br/>撤销后将扣除相应积分。', function(r) {
        if (r) {
            var selectedStudentId = $('#selectedStudentId').combobox('getValue');
            var params = {itemId: itemId};
            
            // 如果是管理员选择了学生，添加学生ID参数
            if (selectedStudentId) {
                params.studentId = selectedStudentId;
            }
            
            $.messager.progress({
                title: '撤销中...',
                msg: '正在撤销打卡记录，请稍候...'
            });
            
            $.post('/checkinRecord/revokeToday', params, function(res) {
                $.messager.progress('close');
                
                if (res === 'success') {
                    $.messager.show({
                        title: '✅ 撤销成功',
                        msg: '打卡记录已成功撤销！',
                        timeout: 2000,
                        showType: 'slide'
                    });
                    
                    // 刷新表格
                    $('#recordTable').datagrid('reload');
                    $('#checkinItemTable').datagrid('reload');
                    
                    // 重新获取用户信息以更新积分显示
                    if (window.currentUser && window.currentUser.parentId != null) {
                        $.get('/user/currentUser', function(user) {
                            if (user) {
                                window.currentUser = user;
                                updateStudentPoints(user.totalPoints || 0, true);
                                
                                // 显示积分扣除的提示
                                setTimeout(function() {
                                    $.messager.show({
                                        title: '💰 积分更新',
                                        msg: '当前总积分：' + (user.totalPoints || 0) + ' 分',
                                        timeout: 2000,
                                        showType: 'fade'
                                    });
                                }, 1000);
                            }
                        });
                    }
                } else if (res === 'not_found') {
                    $.messager.alert('💡 提示', '未找到今日的打卡记录！', 'info');
                } else if (res === 'no_permission') {
                    $.messager.alert('❌ 错误', '没有权限进行撤销操作！', 'error');
                } else {
                    $.messager.alert('❌ 错误', '撤销失败：' + res, 'error');
                }
            }).fail(function(){
                $.messager.progress('close');
                $.messager.alert('❌ 错误', '网络错误，请重试！', 'error');
            });
        }
    });
}

function formatStatus(val) {
    if(val==1) return '<span style="color:green">已打卡</span>';
    if(val==2) return '<span style="color:red">已撤销</span>';
    return val;
}

function formatOp(val,row) {
    var btns = '';
    var currentDate = new Date().toISOString().split('T')[0]; // 获取今日日期 YYYY-MM-DD
    var recordDate = row.checkinDate;
    
    // 当日记录且状态为已打卡，所有人都可以撤销
    if(row.status==1 && recordDate === currentDate) {
        btns += '<button onclick="cancel('+row.id+')" style="' +
               'background: linear-gradient(135deg, #ff9a9e, #fad0c4);' +
               'color: white; border: none; border-radius: 15px; padding: 4px 12px;' +
               'font-size: 12px; cursor: pointer; margin-right: 5px;' +
               'box-shadow: 0 2px 8px rgba(255, 154, 158, 0.3);">' +
               '🚫 撤销</button>';
    }
    
    // 补打按钮：只有家长/admin才能看到，且只能对历史记录中未打卡的事项补打
    // 条件：1. 用户是家长/admin  2. 是历史记录  3. 状态不是已打卡
    if (window.currentUser && window.currentUser.parentId == null && recordDate !== currentDate && row.status != 1) {
        btns += '<button onclick="supplement('+row.studentId+','+row.itemId+',\''+recordDate+'\')" style="' +
               'background: linear-gradient(135deg, #a8edea, #fed6e3);' +
               'color: #333; border: none; border-radius: 15px; padding: 4px 12px;' +
               'font-size: 12px; cursor: pointer;' +
               'box-shadow: 0 2px 8px rgba(168, 237, 234, 0.3);">' +
               '🔄 补打</button>';
    }
    
    return btns || '<span style="color:#999;">无操作</span>';
}

function cancel(id) {
    $.messager.confirm('确认撤销', '🤔 确定要撤销这次打卡记录吗？', function(r){
        if (r) {
            $.post('/checkinRecord/cancel', {recordId:id}, function(res){
                if (res === 'success') {
                    $.messager.show({
                        title: '✅ 撤销成功', 
                        msg: '打卡记录已撤销！',
                        timeout: 2000,
                        showType: 'slide'
                    });
                    $('#recordTable').datagrid('reload');
                } else {
                    $.messager.alert('❌ 错误', '撤销失败：' + res, 'error');
                }
            }).fail(function(){
                $.messager.alert('❌ 错误', '网络错误，请重试！', 'error');
            });
        }
    });
}

function supplement(studentId, itemId, date) {
    $.messager.confirm('确认补打', '📝 确定要为该学生补打这天的记录吗？', function(r){
        if (r) {
            $.post('/checkinRecord/supplement', {studentId:studentId, itemId:itemId, date:date}, function(res){
                if (res === 'success') {
                    $.messager.show({
                        title: '✅ 补打成功', 
                        msg: '历史打卡记录已补录！',
                        timeout: 2000,
                        showType: 'slide'
                    });
                    $('#recordTable').datagrid('reload');
                } else {
                    $.messager.alert('❌ 错误', '补打失败：' + res, 'error');
                }
            }).fail(function(){
                $.messager.alert('❌ 错误', '网络错误，请重试！', 'error');
            });
        }
    });
}
</script>
</body>
</html>
