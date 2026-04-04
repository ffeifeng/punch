<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.punch.entity.User" %>
<%
    User student = (User) request.getAttribute("student");
    Integer totalPoints = (Integer) request.getAttribute("totalPoints");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>今日打卡 - <%= student != null ? student.getRealName() : "学生" %></title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #4fd1c5 0%, #38b2ac 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .header {
            background: white;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .student-info {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 15px;
        }
        
        .student-name {
            font-size: 1.5rem;
            font-weight: 600;
            color: #2d3748;
        }
        
        .header-buttons {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .refresh-btn {
            background: linear-gradient(135deg, #4fd1c5 0%, #38b2ac 100%);
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 50%;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(79, 209, 197, 0.3);
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .refresh-btn:hover {
            background: linear-gradient(135deg, #38b2ac 0%, #319795 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(79, 209, 197, 0.4);
        }
        
        .refresh-btn:active {
            transform: translateY(0);
        }
        
        .refresh-icon {
            font-size: 18px;
            transition: transform 0.6s;
        }
        
        .refresh-btn.spinning .refresh-icon {
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        
        /* 自定义确认对话框样式 */
        .custom-dialog-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10000;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }
        
        .custom-dialog-overlay.show {
            opacity: 1;
            visibility: visible;
        }
        
        .custom-dialog {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin: 20px;
            max-width: 350px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            transform: scale(0.8);
            transition: transform 0.3s ease;
        }
        
        .custom-dialog-overlay.show .custom-dialog {
            transform: scale(1);
        }
        
        .dialog-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 15px;
            text-align: center;
        }
        
        .dialog-message {
            color: #4a5568;
            line-height: 1.5;
            margin-bottom: 25px;
            text-align: center;
            white-space: pre-line;
        }
        
        .dialog-buttons {
            display: flex;
            gap: 10px;
        }
        
        .dialog-btn {
            flex: 1;
            padding: 12px 20px;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .dialog-btn.confirm {
            background: linear-gradient(135deg, #ff6b6b, #feca57);
            color: white;
        }
        
        .dialog-btn.confirm:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 107, 107, 0.4);
        }
        
        .dialog-btn.cancel {
            background: #e2e8f0;
            color: #4a5568;
        }
        
        .dialog-btn.cancel:hover {
            background: #cbd5e0;
        }
        
        .logout-btn {
            background: #e53e3e;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .logout-btn:hover {
            background: #c53030;
        }
        
        .points-display {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            border-radius: 10px;
            text-align: center;
        }
        
        .points-label {
            font-size: 14px;
            opacity: 0.9;
            margin-bottom: 5px;
        }
        
        .points-value {
            font-size: 2rem;
            font-weight: bold;
        }
        
        .checkin-container {
            background: white;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .section-header {
            margin-bottom: 20px;
        }
        
        .section-title {
            font-size: 1.3rem;
            font-weight: 600;
            color: #2d3748;
            text-align: center;
            margin-bottom: 10px;
        }
        
        .date-info {
            text-align: center;
            font-size: 1rem;
            color: #4a5568;
            margin-bottom: 10px;
            font-weight: 500;
        }
        
        .stats-info {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-bottom: 10px;
        }
        
        .stat-item {
            background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            border: 2px solid transparent;
        }
        
        .stat-item.completed {
            color: #38a169;
            border-color: #38a169;
            background: linear-gradient(135deg, #f0fff4 0%, #c6f6d5 100%);
        }
        
        .stat-item.pending {
            color: #e53e3e;
            border-color: #e53e3e;
            background: linear-gradient(135deg, #fff5f5 0%, #fed7d7 100%);
        }
        
        .checkin-item {
            background: #f7fafc;
            border-radius: 12px;
            padding: 15px;
            margin-bottom: 15px;
            border-left: 4px solid #4fd1c5;
            transition: transform 0.2s;
        }
        
        .checkin-item:hover {
            transform: translateY(-2px);
        }
        
        .checkin-item.checked {
            background: #f0fff4;
            border-left-color: #38a169;
        }
        
        .checkin-item.overdue {
            background: #fed7d7;
            border-left-color: #e53e3e;
        }
        
        .item-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .item-name {
            font-size: 1.1rem;
            font-weight: 600;
            color: #2d3748;
            flex: 1;
        }
        
        .item-points {
            background: #4fd1c5;
            color: white;
            padding: 4px 12px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .item-details {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .item-time {
            color: #718096;
            font-size: 14px;
        }
        
        .item-status {
            font-size: 14px;
            font-weight: 600;
        }
        
        .status-unchecked {
            color: #e53e3e;
        }
        
        .status-checked {
            color: #38a169;
        }
        
        .status-overdue {
            color: #ed8936;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
        }
        
        .checkin-btn {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .checkin-btn.primary {
            background: linear-gradient(135deg, #4fd1c5 0%, #38b2ac 100%);
            color: white;
        }
        
        .checkin-btn.primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(79, 209, 197, 0.4);
        }
        
        .checkin-btn.secondary {
            background: linear-gradient(135deg, #ffa726, #ff7043);
            color: white;
        }
        
        .checkin-btn.secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 167, 38, 0.4);
        }
        
        .checkin-btn:disabled {
            background: #e2e8f0;
            color: #a0aec0;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #718096;
        }
        
        .empty-icon {
            font-size: 3rem;
            margin-bottom: 15px;
        }
        
        .loading {
            display: none;
            text-align: center;
            padding: 20px;
        }
        
        .loading-spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #4fd1c5;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 10px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .message {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            padding: 15px 25px;
            border-radius: 25px;
            color: white;
            font-weight: 600;
            z-index: 1000;
            display: none;
        }
        
        .message.success {
            background: #38a169;
        }
        
        .message.error {
            background: #e53e3e;
        }
        
        .message.info {
            background: #3182ce;
        }
        
        .refresh-hint {
            text-align: center;
            padding: 10px;
            color: #718096;
            font-size: 12px;
            background: #f7fafc;
            border-radius: 8px;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <div class="message" id="message"></div>
    
    <div class="header">
        <div class="student-info">
            <div class="student-name">👋 <%= student.getRealName() %></div>
            <div class="header-buttons">
                <button class="refresh-btn" onclick="refreshData()" title="刷新数据">
                    <span class="refresh-icon">🔄</span>
                </button>
                <button class="logout-btn" onclick="logout()">退出</button>
            </div>
        </div>
        
        <div class="points-display">
            <div class="points-label">我的总积分</div>
            <div class="points-value" id="totalPoints"><%= totalPoints != null ? totalPoints : 0 %></div>
        </div>
    </div>
    
    <div class="checkin-container">
        <div class="section-header">
            <div class="section-title">📋 今日打卡事项</div>
            <div class="date-info" id="dateInfo">
                <!-- 日期信息将通过JavaScript动态加载 -->
            </div>
            <div class="stats-info" id="statsInfo">
                <!-- 统计信息将通过JavaScript动态加载 -->
            </div>
        </div>
        
        <div class="refresh-hint">
            💡 点击右上角 🔄 按钮可刷新最新的积分和打卡项信息
        </div>
        
        <div class="loading" id="loading">
            <div class="loading-spinner"></div>
            <p>加载中...</p>
        </div>
        
        <div id="checkinList">
            <!-- 打卡事项将通过JavaScript动态加载 -->
        </div>
    </div>
    
    <!-- 自定义确认对话框 -->
    <div id="customDialog" class="custom-dialog-overlay">
        <div class="custom-dialog">
            <div id="dialogTitle" class="dialog-title"></div>
            <div id="dialogMessage" class="dialog-message"></div>
            <div class="dialog-buttons">
                <button id="dialogCancel" class="dialog-btn cancel">取消</button>
                <button id="dialogConfirm" class="dialog-btn confirm">确定</button>
            </div>
        </div>
    </div>

    <script>
        let studentId = <%= student.getId() %>;
        
        // 页面加载完成后获取打卡事项
        window.addEventListener('load', function() {
            updateDateInfo();
            loadCheckinItems();
        });
        
        // 更新日期信息
        function updateDateInfo() {
            const now = new Date();
            const year = now.getFullYear();
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const day = String(now.getDate()).padStart(2, '0');
            const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
            const weekday = weekdays[now.getDay()];
            
            const dateStr = year + '年' + month + '月' + day + '日 ' + weekday;
            document.getElementById('dateInfo').textContent = dateStr;
        }
        
        // 更新统计信息
        function updateStatsInfo(completedCount, pendingCount) {
            const statsContainer = document.getElementById('statsInfo');
            statsContainer.innerHTML = 
                '<div class="stat-item completed">✅ 已打卡 ' + completedCount + ' 项</div>' +
                '<div class="stat-item pending">⏰ 未打卡 ' + pendingCount + ' 项</div>';
        }
        
        // 局部更新单个事项的状态（避免整页刷新）
        function updateItemStatus(itemId, newStatus) {
            // 找到对应的事项元素 - 使用更精确的选择器
            const checkinItems = document.querySelectorAll('.checkin-item');
            let targetItem = null;
            
            checkinItems.forEach(item => {
                // 使用更精确的匹配方式
                const checkinButton = item.querySelector('button[onclick="doCheckin(' + itemId + ')"]');
                const revokeButton = item.querySelector('button[onclick="revokeCheckin(' + itemId + ')"]');
                if (checkinButton || revokeButton) {
                    targetItem = item;
                }
            });
            
            if (!targetItem) {
                console.log('未找到itemId为 ' + itemId + ' 的事项元素');
                return;
            }
            
            // 更新事项的视觉状态
            if (newStatus === 1) {
                // 已打卡状态
                targetItem.classList.add('checked');
                targetItem.classList.remove('overdue');
                
                // 更新状态文本
                const statusElement = targetItem.querySelector('.item-status');
                if (statusElement) {
                    statusElement.textContent = '已打卡';
                    statusElement.className = 'item-status status-checked';
                }
                
                // 更新操作按钮
                const actionButtons = targetItem.querySelector('.action-buttons');
                if (actionButtons) {
                    actionButtons.innerHTML = 
                        '<button class="checkin-btn secondary" onclick="revokeCheckin(' + itemId + ')">' +
                            '🔄 撤销打卡' +
                        '</button>' +
                        '<button class="checkin-btn" disabled>' +
                            '✅ 已完成' +
                        '</button>';
                }
            } else {
                // 未打卡状态
                targetItem.classList.remove('checked');
                
                // 检查是否超时，如果超时则添加overdue样式
                const itemData = getItemDataById(itemId);
                if (itemData && isItemOverdue(itemData)) {
                    targetItem.classList.add('overdue');
                } else {
                    targetItem.classList.remove('overdue');
                }
                
                // 更新状态文本
                const statusElement = targetItem.querySelector('.item-status');
                if (statusElement) {
                    statusElement.textContent = '未打卡';
                    statusElement.className = 'item-status status-unchecked';
                }
                
                // 更新操作按钮
                const actionButtons = targetItem.querySelector('.action-buttons');
                if (actionButtons) {
                    actionButtons.innerHTML = 
                        '<button class="checkin-btn primary" onclick="doCheckin(' + itemId + ')">' +
                            '✅ 立即打卡' +
                        '</button>';
                }
            }
            
            // 重新计算并更新统计信息
            const allItems = document.querySelectorAll('.checkin-item');
            let completedCount = 0;
            let pendingCount = 0;
            
            allItems.forEach(item => {
                if (item.classList.contains('checked')) {
                    completedCount++;
                } else {
                    pendingCount++;
                }
            });
            
            updateStatsInfo(completedCount, pendingCount);
        }
        
        // 加载打卡事项
        function loadCheckinItems() {
            document.getElementById('loading').style.display = 'block';
            
            return fetch('/dailyCheckin/todayItems?studentId=' + studentId)
                .then(response => response.json())
                .then(data => {
                    renderCheckinItems(data);
                })
                .catch(error => {
                    console.error('加载打卡事项失败:', error);
                    showMessage('加载失败，请刷新页面重试', 'error');
                    throw error;
                })
                .finally(() => {
                    document.getElementById('loading').style.display = 'none';
                });
        }
        
        // 渲染打卡事项
        function renderCheckinItems(items) {
            const container = document.getElementById('checkinList');
            
            // 存储事项数据到全局变量，供其他函数使用
            window.todayItems = items;
            
            if (!items || items.length === 0) {
                updateStatsInfo(0, 0);
                container.innerHTML = '<div class="empty-state">' +
                    '<div class="empty-icon">😴</div>' +
                    '<p>今日暂无打卡事项</p>' +
                    '<small>好好休息吧～</small>' +
                '</div>';
                return;
            }
            
            // 统计已打卡和未打卡数量
            let completedCount = 0;
            let pendingCount = 0;
            items.forEach(item => {
                if (item.status == 1) {
                    completedCount++;
                } else {
                    pendingCount++;
                }
            });
            
            // 更新统计信息
            updateStatsInfo(completedCount, pendingCount);
            
            let html = '';
            items.forEach(item => {
                const statusClass = getStatusClass(item.status);
                const statusText = getStatusText(item.status);
                const isOverdue = isItemOverdue(item);
                
                html += '<div class="checkin-item ' + (item.status == 1 ? 'checked' : '') + ' ' + (isOverdue ? 'overdue' : '') + '">' +
                    '<div class="item-header">' +
                        '<div class="item-name">' + item.itemName + '</div>' +
                        '<div class="item-points">+' + (item.itemPoints || item.points || 0) + '分</div>' +
                    '</div>' +
                    '<div class="item-details">' +
                        '<div class="item-time">⏰ ' + (item.checkinStartTime || '00:00') + ' - ' + (item.checkinEndTime || '23:59') + '</div>' +
                        '<div class="item-status ' + statusClass + '">' + statusText + '</div>' +
                    '</div>' +
                    '<div class="action-buttons">' + renderActionButtons(item) + '</div>' +
                '</div>';
            });
            
            container.innerHTML = html;
        }
        
        // 渲染操作按钮
        function renderActionButtons(item) {
            if (item.status === 0) { // 未打卡
                return '<button class="checkin-btn primary" onclick="doCheckin(' + item.itemId + ')">' +
                    '✅ 立即打卡' +
                '</button>';
            } else if (item.status === 1) { // 已打卡
                return '<button class="checkin-btn secondary" onclick="revokeCheckin(' + item.itemId + ')">' +
                        '🔄 撤销打卡' +
                    '</button>' +
                    '<button class="checkin-btn" disabled>' +
                        '✅ 已完成' +
                    '</button>';
            } else {
                return '<button class="checkin-btn" disabled>' +
                    '🚫 暂不可打卡' +
                '</button>';
            }
        }
        
        // 获取状态样式类
        function getStatusClass(status) {
            switch(status) {
                case 0: return 'status-unchecked';
                case 1: return 'status-checked';
                default: return 'status-overdue';
            }
        }
        
        // 获取状态文本
        function getStatusText(status) {
            switch(status) {
                case 0: return '未打卡';
                case 1: return '已打卡';
                default: return '不可打卡';
            }
        }
        
        // 根据itemId获取事项数据
        function getItemDataById(itemId) {
            if (window.todayItems) {
                return window.todayItems.find(item => item.id == itemId || item.itemId == itemId);
            }
            return null;
        }
        
        // 判断是否超时
        function isItemOverdue(item) {
            if (!item.checkinEndTime) return false;
            
            const now = new Date();
            const endTime = new Date();
            const [hours, minutes] = item.checkinEndTime.split(':');
            endTime.setHours(parseInt(hours), parseInt(minutes), 0, 0);
            
            // 使用统一的状态字段判断：未打卡且超过结束时间
            const status = item.todayStatus !== undefined ? item.todayStatus : item.status;
            return now > endTime && status === 0;
        }
        
        // 执行打卡
        function doCheckin(itemId) {
            const formData = new FormData();
            formData.append('itemId', itemId);
            formData.append('studentId', studentId);
            
            fetch('/checkinRecord/doCheckin', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(result => {
                if (result === 'success') {
                    showMessage('打卡成功！🎉', 'success');
                    updateItemStatus(itemId, 1); // 局部更新状态
                    updateTotalPoints(); // 更新总积分
                } else if (result === 'already_checked') {
                    showMessage('今日已打卡过此事项', 'info');
                } else if (result === 'no_permission') {
                    showMessage('没有权限进行此操作', 'error');
                } else {
                    showMessage('打卡失败：' + result, 'error');
                }
            })
            .catch(error => {
                console.error('打卡失败:', error);
                showMessage('网络错误，请稍后重试', 'error');
            });
        }
        
        // 撤销打卡
        function revokeCheckin(itemId) {
            showConfirmDialog(
                '确认撤销打卡',
                '确定要撤销今日的打卡记录吗？\n撤销后将扣除相应积分。',
                function() {
                    // 确认撤销
                    performRevokeCheckin(itemId);
                }
            );
        }
        
        // 执行撤销打卡操作
        function performRevokeCheckin(itemId) {
            
            const formData = new FormData();
            formData.append('itemId', itemId);
            formData.append('studentId', studentId);
            
            fetch('/checkinRecord/revokeToday', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(result => {
                if (result === 'success') {
                    showMessage('撤销成功', 'success');
                    updateItemStatus(itemId, 0); // 局部更新状态
                    updateTotalPoints(); // 更新总积分
                } else if (result === 'not_found') {
                    showMessage('未找到今日的打卡记录', 'info');
                } else if (result === 'no_permission') {
                    showMessage('没有权限进行此操作', 'error');
                } else {
                    showMessage('撤销失败：' + result, 'error');
                }
            })
            .catch(error => {
                console.error('撤销失败:', error);
                showMessage('网络错误，请稍后重试', 'error');
            });
        }
        
        // 更新总积分显示
        function updateTotalPoints() {
            return fetch('/user/currentUser')
                .then(response => response.json())
                .then(user => {
                    if (user && user.totalPoints !== undefined) {
                        document.getElementById('totalPoints').textContent = user.totalPoints;
                    }
                })
                .catch(error => {
                    console.error('更新积分失败:', error);
                    throw error;
                });
        }
        
        // 刷新所有数据
        function refreshData() {
            const refreshBtn = document.querySelector('.refresh-btn');
            const refreshIcon = document.querySelector('.refresh-icon');
            
            // 添加旋转动画
            refreshBtn.classList.add('spinning');
            refreshBtn.disabled = true;
            
            // 显示刷新提示
            showMessage('正在刷新数据...', 'info');
            
            // 同时更新日期、积分和打卡事项
            Promise.all([
                updateDateInfo(),
                updateTotalPoints(),
                loadCheckinItems()
            ]).then(() => {
                showMessage('数据刷新成功！✨', 'success');
            }).catch(error => {
                console.error('刷新数据失败:', error);
                showMessage('刷新失败，请稍后重试', 'error');
            }).finally(() => {
                // 移除旋转动画
                setTimeout(() => {
                    refreshBtn.classList.remove('spinning');
                    refreshBtn.disabled = false;
                }, 500);
            });
        }
        
        // 修改updateDateInfo函数，使其返回Promise
        function updateDateInfo() {
            return new Promise((resolve) => {
                const now = new Date();
                const year = now.getFullYear();
                const month = String(now.getMonth() + 1).padStart(2, '0');
                const day = String(now.getDate()).padStart(2, '0');
                const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
                const weekday = weekdays[now.getDay()];
                
                const dateStr = year + '年' + month + '月' + day + '日 ' + weekday;
                document.getElementById('dateInfo').textContent = dateStr;
                resolve();
            });
        }
        
        // 退出登录
        function logout() {
            if (!confirm('确定要退出登录吗？')) {
                return;
            }
            
            fetch('/mobile/logout', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showMessage('退出成功', 'success');
                    setTimeout(() => {
                        window.location.href = '/mobile/login';
                    }, 1000);
                }
            })
            .catch(error => {
                console.error('退出失败:', error);
                window.location.href = '/mobile/login';
            });
        }
        
        // 显示自定义确认对话框
        function showConfirmDialog(title, message, onConfirm, onCancel) {
            const dialog = document.getElementById('customDialog');
            const titleEl = document.getElementById('dialogTitle');
            const messageEl = document.getElementById('dialogMessage');
            const confirmBtn = document.getElementById('dialogConfirm');
            const cancelBtn = document.getElementById('dialogCancel');
            
            titleEl.textContent = title;
            messageEl.textContent = message;
            
            // 移除之前的事件监听器
            const newConfirmBtn = confirmBtn.cloneNode(true);
            const newCancelBtn = cancelBtn.cloneNode(true);
            confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
            cancelBtn.parentNode.replaceChild(newCancelBtn, cancelBtn);
            
            // 添加新的事件监听器
            newConfirmBtn.addEventListener('click', function() {
                hideConfirmDialog();
                if (onConfirm) onConfirm();
            });
            
            newCancelBtn.addEventListener('click', function() {
                hideConfirmDialog();
                if (onCancel) onCancel();
            });
            
            // 点击对话框外部关闭
            dialog.addEventListener('click', function(e) {
                if (e.target === dialog) {
                    hideConfirmDialog();
                    if (onCancel) onCancel();
                }
            });
            
            // 显示对话框
            dialog.classList.add('show');
        }
        
        // 隐藏确认对话框
        function hideConfirmDialog() {
            const dialog = document.getElementById('customDialog');
            dialog.classList.remove('show');
        }
        
        // 显示消息
        function showMessage(text, type) {
            const message = document.getElementById('message');
            message.textContent = text;
            message.className = 'message ' + type;
            message.style.display = 'block';
            
            setTimeout(() => {
                message.style.display = 'none';
            }, 3000);
        }
        
        // 移除自动刷新功能，改为手动操作后局部更新
        // 如果需要刷新数据，用户可以下拉刷新或重新进入页面
    </script>
</body>
</html>
