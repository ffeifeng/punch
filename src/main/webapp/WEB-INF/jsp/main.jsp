<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.punch.entity.User" %>
<%
    User user = (User) session.getAttribute("user");
    String displayName = user != null ? (user.getRealName() != null ? user.getRealName() : user.getUsername()) : "未登录";
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
    <title>学生打卡系统 - 后台管理</title>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 本地jQuery和EasyUI资源 -->
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/themes/icon.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>
    

    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: "Microsoft YaHei", Arial, sans-serif;
        }
        
        /* 顶部区域样式 */
        .north-panel {
            background: linear-gradient(135deg, #4fd1c5 0%, #38b2ac 100%);
            color: white;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .logo-area {
            display: flex;
            align-items: center;
            font-size: 1.5rem;
            font-weight: bold;
        }
        
        .logo-icon {
            width: 40px;
            height: 40px;
            margin-right: 12px;
            background: rgba(255,255,255,0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        
        .user-area {
            display: flex;
            align-items: center;
            font-size: 0.9rem;
        }
        
        .user-area .username {
            margin-right: 15px;
            color: rgba(255,255,255,0.9);
        }
        
        .logout-btn {
            background: rgba(255,255,255,0.2);
            border: 1px solid rgba(255,255,255,0.3);
            color: white;
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .logout-btn:hover {
            background: rgba(255,255,255,0.3);
        }
        
        /* 左侧菜单样式 */
        .west-panel {
            background: #f8f9fa;
        }
        
        /* 手风琴面板样式优化 */
        .easyui-accordion {
            background: transparent !important;
        }
        
        .accordion-header {
            height: 40px !important;
            line-height: 40px !important;
            padding: 0 !important;
        }
        
        /* 手风琴标题统一对齐样式 */
        .easyui-accordion .panel-header {
            display: flex !important;
            align-items: center !important;
            padding: 0 12px !important;
        }
        
        /* 手风琴标题文字样式 */
        .accordion-header .panel-title {
            font-size: 0.95rem !important;
            font-weight: 500 !important;
            letter-spacing: 1px !important;
            display: flex !important;
            align-items: center !important;
            width: 100% !important;
        }
        
        /* 通过CSS调整emoji和文字间距 */
        .easyui-accordion .panel-header .panel-title {
            word-spacing: 3px !important;
        }
        
        /* 手风琴标题图标对齐优化 */
        .easyui-accordion .panel-header .panel-icon {
            display: inline-flex !important;
            align-items: center !important;
            vertical-align: middle !important;
        }
        
        /* 确保所有手风琴面板头部样式一致 */
        .easyui-accordion .accordion-header,
        .easyui-accordion .panel-header-collapsed,
        .easyui-accordion .panel-header-expanded {
            height: 40px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: flex-start !important;
        }
        
        .accordion-body {
            padding: 0 !important;
        }
        
        .menu-item {
            display: block;
            width: 100%;
            padding: 8px 15px;
            color: #2d3748;
            text-decoration: none;
            border-bottom: 1px solid #e2e8f0;
            transition: all 0.3s;
            font-size: 0.9rem;
            margin: 0;
        }
        
        .menu-item:hover {
            background: #e6fffa;
            color: #319795;
            text-decoration: none;
        }
        
        .menu-item.active {
            background: #4fd1c5;
            color: white;
        }
        
        /* 手风琴内容区域自适应高度 */
        .menu-panel {
            padding: 0px !important;
            background: #f8f9fa;
        }
        
        /* 手风琴面板容器样式 */
        .accordion-body {
            height: auto !important;
        }
        
        /* 左侧面板内容自适应 */
        .west-panel .panel-body {
            overflow: visible !important;
            height: auto !important;
        }
        
        /* 中心区域样式 */
        .center-panel {
            background: #ffffff;
        }
        
        .welcome-content {
            padding: 40px;
            text-align: center;
            background: linear-gradient(135deg, #f0fff4 0%, #e6fffa 100%);
            min-height: 400px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        
        .welcome-title {
            font-size: 2.5rem;
            color: #2d3748;
            margin-bottom: 20px;
            font-weight: bold;
        }
        
        .welcome-subtitle {
            font-size: 1.2rem;
            color: #4a5568;
            margin-bottom: 30px;
        }
        
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
            width: 100%;
            max-width: 800px;
        }
        
        .feature-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s;
        }
        
        .feature-card:hover {
            transform: translateY(-5px);
        }
        
        .feature-icon {
            font-size: 2rem;
            color: #4fd1c5;
            margin-bottom: 10px;
        }
        
        .feature-title {
            font-size: 1.1rem;
            color: #2d3748;
            font-weight: bold;
            margin-bottom: 8px;
        }
        
        .feature-desc {
            font-size: 0.9rem;
            color: #718096;
        }

    </style>
</head>
<body>
    <!-- 使用EasyUI Layout布局 -->
    <div id="layout" class="easyui-layout" style="width:100%;height:100%;">
        
        <!-- 顶部区域 -->
        <div data-options="region:'north',border:false" class="north-panel">
            <div class="logo-area">
                <div class="logo-icon">📚</div>
                学生打卡系统
            </div>
            <div class="user-area">
                <span class="username">
                    <%=displayName%> (<%=role.equals("admin") ? "管理员" : role.equals("parent") ? "家长" : "学生"%>)
                </span>
                <div class="logout-btn" onclick="logout()">退出</div>
            </div>
        </div>
        
        <!-- 左侧菜单区域 -->
        <div data-options="region:'west',split:true,title:'功能菜单'" style="width:220px;" class="west-panel">
            <div id="accordion" class="easyui-accordion" data-options="border:false,animate:true,multiple:true,fillSpace:false">
                
                <%-- 打卡管理模块 --%>
                <% if ("admin".equals(role) || "parent".equals(role)) { %>
                <div title="📝  打卡管理" data-options="iconCls:'icon-edit'">
                    <div class="menu-panel">
                        <a href="javascript:void(0)" class="menu-item" onclick="openTab('打卡模板/事项','/checkin_manage')">
                            📋 打卡模板/事项
                        </a>
                    </div>
                </div>
                <% } %>
                
                <%-- 打卡记录模块 --%>
                <div title="📊  打卡记录" data-options="iconCls:'icon-sum'">
                    <div class="menu-panel">
                        <a href="javascript:void(0)" class="menu-item" onclick="openTab('我的打卡记录','/checkin_record')">
                            📈 我的打卡记录
                        </a>
                    </div>
                </div>
                
                <%-- 用户管理模块 --%>
                <% if ("admin".equals(role) || "parent".equals(role)) { %>
                <div title="👥  用户管理" data-options="iconCls:'icon-man'">
                    <div class="menu-panel">
                        <% if ("admin".equals(role)) { %>
                        <a href="javascript:void(0)" class="menu-item" onclick="openTab('用户管理','/user_manage')">
                            👤 用户管理
                        </a>
                        <a href="javascript:void(0)" class="menu-item" onclick="openTab('角色管理','/role_manage')">
                            🔐 角色管理
                        </a>
                        <% } else if ("parent".equals(role)) { %>
                        <a href="javascript:void(0)" class="menu-item" onclick="openTab('我的孩子','/user_manage')">
                            👶 我的孩子
                        </a>
                        <% } %>
                    </div>
                </div>
                <% } %>
                
                <%-- 积分系统模块 --%>
                <div title="💰  积分系统" data-options="iconCls:'icon-tip'">
                    <div class="menu-panel">
                        <a href="javascript:void(0)" class="menu-item" onclick="openTab('积分管理','/points_manage')">
                            💎 积分管理
                        </a>
                        <% if ("admin".equals(role) || "parent".equals(role)) { %>
                        <a href="javascript:void(0)" class="menu-item" onclick="openTab('抽奖管理','/lottery_manage')">
                            🎰 抽奖管理
                        </a>
                        <a href="javascript:void(0)" class="menu-item" onclick="openTab('抽奖记录','/lottery_record')">
                            🏆 抽奖记录
                        </a>
                        <% } %>
                        <% if ("admin".equals(role)) { %>
                        <a href="javascript:void(0)" class="menu-item" onclick="openTab('操作日志','/operation_log')">
                            📋 操作日志
                        </a>
                        <% } %>
                    </div>
                </div>
                
            </div>
        </div>
        
        <!-- 中心内容区域 -->
        <div data-options="region:'center'" class="center-panel">
            <div id="tabs" class="easyui-tabs" data-options="fit:true,border:false">
                <div title="🏠 首页" data-options="iconCls:'icon-home'">
                    <div class="welcome-content">
                        <div class="welcome-title">🎉 欢迎使用学生打卡系统</div>
                        <div class="welcome-subtitle">让学习更有趣，让成长更有迹可循</div>
                        
                        <div class="feature-grid">
                            <% if ("student".equals(role)) { %>
                            <div class="feature-card">
                                <div class="feature-icon">📝</div>
                                <div class="feature-title">每日打卡</div>
                                <div class="feature-desc">记录学习进度，养成良好习惯</div>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">💎</div>
                                <div class="feature-title">积分奖励</div>
                                <div class="feature-desc">完成任务获得积分，激励学习</div>
                            </div>
                            <% } else if ("parent".equals(role)) { %>
                            <div class="feature-card">
                                <div class="feature-icon">👶</div>
                                <div class="feature-title">孩子管理</div>
                                <div class="feature-desc">关注孩子学习进度</div>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">📊</div>
                                <div class="feature-title">学习报告</div>
                                <div class="feature-desc">查看详细学习数据</div>
                            </div>
                            <% } else { %>
                            <div class="feature-card">
                                <div class="feature-icon">👥</div>
                                <div class="feature-title">用户管理</div>
                                <div class="feature-desc">管理系统用户</div>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">📈</div>
                                <div class="feature-title">数据统计</div>
                                <div class="feature-desc">查看系统使用情况</div>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">⚙️</div>
                                <div class="feature-title">系统设置</div>
                                <div class="feature-desc">配置系统参数</div>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
    </div>

    <script type="text/javascript">
        $(function(){
            // 等待DOM完全加载后初始化EasyUI组件
            setTimeout(function(){
                // 初始化layout
                $('#layout').layout({
                    fit: true
                });
                
                // 初始化tabs
                $('#tabs').tabs({
                    fit: true,
                    border: false,
                    plain: true
                });
                
                // 初始化accordion
                $('#accordion').accordion({
                    border: false,
                    animate: true,
                    multiple: true,
                    fillSpace: false
                });
                
                console.log('EasyUI组件初始化完成');
            }, 100);
        });
        
        // 打开新标签页
        function openTab(title, url) {
            try {
                // 检查tabs是否已初始化
                if (!$('#tabs').hasClass('tabs-container')) {
                    console.log('tabs未初始化，重新初始化...');
                    $('#tabs').tabs({
                        fit: true,
                        border: false,
                        plain: true
                    });
                }
                
                if ($('#tabs').tabs('exists', title)) {
                    $('#tabs').tabs('select', title);
                } else {
                    $('#tabs').tabs('add', {
                        title: title,
                        content: '<iframe src="' + url + '" frameborder="0" style="width:100%;height:100%;border:none;" scrolling="auto"></iframe>',
                        closable: true,
                        iconCls: 'icon-application'
                    });
                }
            } catch(e) {
                console.error('打开标签页失败:', e);
                alert('打开页面失败，请刷新后重试');
            }
        }
        
        // 退出登录
        function logout() {
            try {
                if (typeof $.messager !== 'undefined') {
                    $.messager.confirm('确认', '确定要退出登录吗？', function(r){
                        if (r) {
                            window.location.href = '/logout';
                        }
                    });
                } else {
                    if (confirm('确定要退出登录吗？')) {
                        window.location.href = '/logout';
                    }
                }
            } catch(e) {
                console.error('退出登录失败:', e);
                if (confirm('确定要退出登录吗？')) {
                    window.location.href = '/logout';
                }
            }
        }

    </script>
</body>
</html>
