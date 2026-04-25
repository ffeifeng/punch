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
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            align-items: center;
            justify-content: center;
            z-index: 10000;
        }
        
        .custom-dialog-overlay.show {
            display: flex;
            animation: modalFadeIn 0.25s ease;
        }
        
        .custom-dialog {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin: 20px;
            max-width: 350px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            animation: cardSlideIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
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
        
        .points-actions {
            display: flex;
            gap: 10px;
            margin-top: 14px;
        }
        .points-action-btn {
            flex: 1;
            padding: 10px 8px;
            border: none;
            border-radius: 12px;
            font-size: 0.88rem;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 3px;
            transition: transform 0.15s, box-shadow 0.15s;
        }
        .points-action-btn:active { transform: scale(0.96); }
        .points-action-btn .btn-icon { font-size: 1.3rem; }
        .points-action-btn.lottery {
            background: rgba(255,255,255,0.22);
            color: white;
            border: 1px solid rgba(255,255,255,0.35);
        }
        .points-action-btn.lottery:hover { background: rgba(255,255,255,0.32); }
        .points-action-btn.lottery.disabled-btn {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .points-action-btn.records {
            background: rgba(255,255,255,0.18);
            color: white;
            border: 1px solid rgba(255,255,255,0.3);
        }
        .points-action-btn.records:hover { background: rgba(255,255,255,0.28); }
        
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

        /* 抽奖区域 - 弹窗样式 */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.55);
            align-items: center;
            justify-content: center;
            z-index: 15000;
            padding: 20px;
            box-sizing: border-box;
        }
        .modal-overlay.show {
            display: flex;
            animation: modalFadeIn 0.25s ease;
        }
        @keyframes modalFadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .modal-card {
            background: white;
            border-radius: 20px;
            width: 100%;
            max-width: 360px;
            max-height: 90vh;
            overflow: visible;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 24px 20px 20px;
            animation: cardSlideIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        @keyframes cardSlideIn {
            from { transform: scale(0.85) translateY(20px); opacity: 0; }
            to { transform: scale(1) translateY(0); opacity: 1; }
        }

        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 18px;
        }
        .modal-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #2d3748;
        }
        .modal-close {
            background: #f0f0f0;
            border: none;
            border-radius: 50%;
            width: 32px; height: 32px;
            font-size: 16px;
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            color: #4a5568;
            transition: background 0.2s;
        }
        .modal-close:hover { background: #e2e8f0; }

        .lottery-title {
            font-size: 1.3rem;
            font-weight: 600;
            color: #2d3748;
            text-align: center;
            margin-bottom: 15px;
        }

        .wheel-container {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .wheel-wrapper {
            position: relative;
            display: inline-block;
        }

        .wheel-pointer {
            position: absolute;
            top: -18px;
            left: 50%;
            transform: translateX(-50%);
            width: 0;
            height: 0;
            border-left: 12px solid transparent;
            border-right: 12px solid transparent;
            border-top: 24px solid #e53e3e;
            z-index: 10;
            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));
        }

        #wheelCanvas {
            border-radius: 50%;
            box-shadow: 0 8px 30px rgba(0,0,0,0.2);
            display: block;
        }

        .lottery-spin-btn {
            margin-top: 18px;
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            background: linear-gradient(135deg, #f6d365 0%, #fda085 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(253, 160, 133, 0.4);
            transition: all 0.3s;
        }
        .lottery-spin-btn:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(253, 160, 133, 0.5);
        }
        .lottery-spin-btn:disabled {
            background: #e2e8f0;
            color: #a0aec0;
            cursor: not-allowed;
            box-shadow: none;
            transform: none;
        }

        .lottery-count-info {
            text-align: center;
            margin-top: 10px;
            font-size: 0.9rem;
            color: #718096;
        }

        /* 页面上的入口按钮 */


        /* 抽奖记录列表 */
        .records-tabs {
            display: flex;
            border-bottom: 2px solid #edf2f7;
            margin-bottom: 8px;
        }
        .records-tab {
            flex: 1;
            padding: 10px 0;
            border: none;
            background: none;
            font-size: 0.9rem;
            font-weight: 600;
            color: #718096;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            margin-bottom: -2px;
            transition: all 0.2s;
        }
        .records-tab.active {
            color: #553c9a;
            border-bottom-color: #667eea;
        }
        /* 记录列表固定高度，内容超出时滚动 */
        #lotteryRecordList {
            height: 300px;
            overflow-y: auto;
            padding-right: 4px;
        }
        #lotteryRecordList::-webkit-scrollbar { width: 4px; }
        #lotteryRecordList::-webkit-scrollbar-track { background: #f7fafc; border-radius: 4px; }
        #lotteryRecordList::-webkit-scrollbar-thumb { background: #cbd5e0; border-radius: 4px; }
        .record-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #e2e8f0;
        }
        .record-item:last-child { border-bottom: none; }
        .record-prize {
            font-weight: 600;
            color: #2d3748;
            font-size: 1rem;
        }
        .record-time { color: #718096; font-size: 12px; margin-top: 3px; }
        .record-status-redeemed {
            background: #c6f6d5; color: #276749;
            padding: 4px 10px; border-radius: 12px;
            font-size: 12px; font-weight: 600; white-space: nowrap;
        }
        .record-status-pending {
            background: #feebc8; color: #7b341e;
            padding: 4px 10px; border-radius: 12px;
            font-size: 12px; font-weight: 600; white-space: nowrap;
        }

        .record-item:last-child { border-bottom: none; }

        .record-prize {
            font-weight: 600;
            color: #2d3748;
            font-size: 1rem;
        }

        .record-time {
            color: #718096;
            font-size: 12px;
            margin-top: 3px;
        }

        .record-status-redeemed {
            background: #c6f6d5;
            color: #276749;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            white-space: nowrap;
        }

        .record-status-pending {
            background: #feebc8;
            color: #7b341e;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            white-space: nowrap;
        }

        .prize-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.6);
            align-items: center;
            justify-content: center;
            z-index: 20000;
        }
        .prize-overlay.show {
            display: flex;
            animation: modalFadeIn 0.25s ease;
        }
        .prize-card {
            background: white;
            border-radius: 20px;
            padding: 40px 30px;
            text-align: center;
            max-width: 300px;
            width: 85%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            animation: cardSlideIn 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        .prize-emoji { font-size: 4rem; margin-bottom: 10px; }
        .prize-label { font-size: 1rem; color: #718096; margin-bottom: 8px; }
        .prize-name { font-size: 1.6rem; font-weight: 800; color: #2d3748; margin-bottom: 20px; }
        .prize-close-btn {
            background: linear-gradient(135deg, #4fd1c5, #38b2ac);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
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
            <div class="points-actions" id="quickActions" style="display:none;">
                <button class="points-action-btn lottery" id="lotteryEntryBtn" onclick="openLotteryModal()">
                    <span class="btn-icon">🎰</span>
                    <span>幸运转盘</span>
                    <span style="font-size:0.72rem;opacity:0.85;" id="lotteryCountBadge">剩余 0 次</span>
                </button>
                <button class="points-action-btn records" onclick="openRecordsModal()">
                    <span class="btn-icon">🏆</span>
                    <span>我的奖品</span>
                </button>
                <!-- 小红花入口 -->
                <button class="points-action-btn" id="flowerEntryBtn" onclick="openFlowerModal()"
                        style="background:linear-gradient(135deg,#ff758c,#ff7eb3);border:none;">
                    <span class="btn-icon">🌸</span>
                    <span>小红花</span>
                    <span style="font-size:0.72rem;opacity:0.9;" id="flowerCountBadge">0 朵</span>
                </button>
            </div>
            <!-- 积分兑换按钮（有兑换配置才显示） -->
            <div id="exchangeEntry" style="display:none;margin-top:10px;">
                <button class="points-action-btn" id="exchangeEntryBtn"
                        onclick="openExchangeModal()"
                        style="width:100%;background:rgba(255,255,255,0.18);color:white;border:1px solid rgba(255,255,255,0.3);flex-direction:row;justify-content:center;gap:8px;padding:10px;">
                    <span>💱</span>
                    <span>积分兑换抽奖</span>
                    <span id="exchangeRatioHint" style="font-size:0.75rem;opacity:0.8;"></span>
                </button>
            </div>
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
            💡 点击右上角 🔄 按钮可刷新最新的积分、打卡项及抽奖信息
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
    <div id="customDialog" class="custom-dialog-overlay">        <div class="custom-dialog">
            <div id="dialogTitle" class="dialog-title"></div>
            <div id="dialogMessage" class="dialog-message"></div>
            <div class="dialog-buttons">
                <button id="dialogCancel" class="dialog-btn cancel">取消</button>
                <button id="dialogConfirm" class="dialog-btn confirm">确定</button>
            </div>
        </div>
    </div>

    <!-- 抽奖转盘弹窗 -->
    <div class="modal-overlay" id="lotteryModal" onclick="closeLotteryModal(event)">
        <div class="modal-card">
            <div class="modal-header">
                <div class="modal-title">🎰 幸运转盘</div>
                <button class="modal-close" onclick="closeLotteryModal()">✕</button>
            </div>
            <div class="wheel-container">
                <div class="wheel-wrapper">
                    <div class="wheel-pointer"></div>
                    <canvas id="wheelCanvas" width="280" height="280"></canvas>
                </div>
            </div>
            <div class="lottery-count-info">剩余抽奖次数：<strong id="lotteryCountDisplay">0</strong> 次</div>
            <button class="lottery-spin-btn" id="lotteryBtn" onclick="doLottery()">🎉 点击抽奖</button>
        </div>
    </div>

    <!-- 我的抽奖记录弹窗 -->
    <div class="modal-overlay" id="recordsModal" onclick="closeRecordsModal(event)">
        <div class="modal-card">
            <div class="modal-header">
                <div class="modal-title">🏆 我的奖品记录</div>
                <button class="modal-close" onclick="closeRecordsModal()">✕</button>
            </div>
            <!-- Tab 切换 -->
            <div class="records-tabs">
                <button class="records-tab active" id="tabPending" onclick="switchRecordsTab(0)">⏳ 未兑奖</button>
                <button class="records-tab" id="tabRedeemed" onclick="switchRecordsTab(1)">✅ 已兑奖</button>
            </div>
            <div id="lotteryRecordList">
                <div style="text-align:center;padding:30px;color:#718096;">加载中...</div>
            </div>
        </div>
    </div>

    <!-- 抽奖结果弹窗 -->
    <div class="prize-overlay" id="prizeOverlay">
        <div class="prize-card">
            <div class="prize-emoji">🎁</div>
            <div class="prize-label">恭喜你抽到了</div>
            <div class="prize-name" id="prizeName"></div>
            <button class="prize-close-btn" onclick="closePrizeOverlay()">太棒了！</button>
        </div>
    </div>

    <!-- 积分兑换抽奖弹窗 -->
    <div class="modal-overlay" id="exchangeModal" onclick="closeExchangeModal(event)">
        <div class="modal-card" style="max-width:340px;">
            <div class="modal-header">
                <div class="modal-title">💱 积分兑换抽奖</div>
                <button class="modal-close" onclick="closeExchangeModal()">✕</button>
            </div>
            <div style="padding:16px 0 8px;">
                <div style="background:#f7fafc;border-radius:12px;padding:14px 16px;margin-bottom:16px;font-size:0.9rem;color:#4a5568;line-height:1.7;">
                    <div>🪙 当前积分：<strong id="exchangeCurrentPoints" style="color:#553c9a;">-</strong></div>
                    <div>🎯 兑换比例：<strong id="exchangeRatioLabel" style="color:#553c9a;">-</strong></div>
                    <div>🎰 最多可兑换：<strong id="exchangeMaxTimes" style="color:#553c9a;">-</strong> 次</div>
                </div>
                <div style="margin-bottom:14px;">
                    <div style="font-size:0.85rem;font-weight:600;color:#4a5568;margin-bottom:8px;">兑换次数</div>
                    <div style="display:flex;align-items:center;gap:10px;">
                        <button onclick="adjustExchange(-1)" style="width:38px;height:38px;border-radius:50%;border:2px solid #667eea;background:white;color:#667eea;font-size:1.3rem;font-weight:bold;cursor:pointer;line-height:1;">−</button>
                        <input type="number" id="exchangeTimes" value="1" min="1"
                               style="flex:1;text-align:center;padding:8px;border:1.5px solid #e2e8f0;border-radius:10px;font-size:1.1rem;font-weight:700;">
                        <button onclick="adjustExchange(1)" style="width:38px;height:38px;border-radius:50%;border:2px solid #667eea;background:#667eea;color:white;font-size:1.3rem;font-weight:bold;cursor:pointer;line-height:1;">+</button>
                    </div>
                    <div id="exchangeCostHint" style="text-align:center;margin-top:8px;font-size:0.82rem;color:#718096;"></div>
                </div>
                <button class="lottery-spin-btn" id="exchangeConfirmBtn" onclick="doExchange()" style="margin-top:4px;">
                    💱 确认兑换
                </button>
            </div>
        </div>
    </div>

    <script>
        let studentId = <%= student.getId() %>;
        
        // 页面加载完成后获取打卡事项（由下方统一处理）
        // window.addEventListener('load', ...) 已移至文件底部统一调用
        
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
            .then(response => response.json())
            .then(data => {
                const result = data.result;
                if (result === 'success') {
                    showMessage('打卡成功！🎉', 'success');
                    updateItemStatus(itemId, 1);
                    updateTotalPoints();
                    // 全部打卡完成赠送抽奖次数
                    if (data.lotteryRewarded) {
                        lotteryCount = data.lotteryCount;
                        updateLotteryUI();
                        document.getElementById('quickActions').style.display = 'flex';
                        setTimeout(function() {
                            showMessage('🎰 全部打卡完成！获赠 ' + data.lotteryRewardCount + ' 次抽奖机会！', 'success');
                        }, 1200);
                    }
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
            .then(response => response.json())
            .then(data => {
                const result = data.result;
                if (result === 'success') {
                    showMessage('撤销成功', 'success');
                    updateItemStatus(itemId, 0);
                    updateTotalPoints();
                    // 若全部完成奖励被收回，更新抽奖次数显示
                    if (data.lotteryRevoked) {
                        lotteryCount = data.lotteryCount;
                        updateLotteryUI();
                        setTimeout(function() {
                            showMessage('⚠️ 打卡奖励已收回 ' + data.lotteryRevokedCount + ' 次抽奖机会', 'info');
                        }, 1200);
                    }
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
        
        // 更新总积分显示（从数据库实时查询，不依赖session缓存）
        function updateTotalPoints() {
            return fetch('/mobile/currentPoints')
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.totalPoints !== undefined) {
                        document.getElementById('totalPoints').textContent = data.totalPoints;
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
            
            // 同时更新日期、积分、打卡事项和抽奖数据
            Promise.all([
                updateDateInfo(),
                updateTotalPoints(),
                loadCheckinItems(),
                loadLotteryData(),
                loadExchangeConfig()
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

        // ==================== 抽奖转盘功能 ====================
        var lotteryItems = [];

        // ==================== 积分兑换功能 ====================
        var exchangeRatio = 0;
        var exchangeMaxTimes = 0;

        function loadExchangeConfig() {
            return fetch('/mobile/exchangeConfig')
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.success && data.enabled) {
                        exchangeRatio = data.ratio;
                        document.getElementById('exchangeRatioHint').textContent = data.ratio + '积分/次';
                        document.getElementById('exchangeEntry').style.display = 'block';
                    } else {
                        document.getElementById('exchangeEntry').style.display = 'none';
                    }
                })
                .catch(function() {});
        }

        function openExchangeModal() {
            fetch('/mobile/exchangeConfig')
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (!data.success || !data.enabled) {
                        showMessage('积分兑换功能未开启', 'info'); return;
                    }
                    exchangeRatio = data.ratio;
                    exchangeMaxTimes = data.maxExchangeable || 0;
                    document.getElementById('exchangeCurrentPoints').textContent = data.currentPoints + ' 积分';
                    document.getElementById('exchangeRatioLabel').textContent = data.ratio + ' 积分 = 1 次抽奖';
                    document.getElementById('exchangeMaxTimes').textContent = exchangeMaxTimes;
                    var input = document.getElementById('exchangeTimes');
                    input.max = exchangeMaxTimes;
                    input.value = exchangeMaxTimes > 0 ? 1 : 0;
                    input.disabled = exchangeMaxTimes <= 0;
                    var confirmBtn = document.getElementById('exchangeConfirmBtn');
                    if (exchangeMaxTimes <= 0) {
                        confirmBtn.disabled = true;
                        confirmBtn.textContent = '积分不足，无法兑换';
                    } else {
                        confirmBtn.disabled = false;
                        confirmBtn.textContent = '💱 确认兑换';
                    }
                    updateExchangeCostHint();
                    document.getElementById('exchangeModal').classList.add('show');
                });
        }

        function closeExchangeModal(e) {
            if (e && e.target !== document.getElementById('exchangeModal')) return;
            document.getElementById('exchangeModal').classList.remove('show');
        }

        function adjustExchange(delta) {
            var input = document.getElementById('exchangeTimes');
            if (exchangeMaxTimes <= 0) return;
            var val = parseInt(input.value) || 1;
            val = Math.max(1, Math.min(exchangeMaxTimes, val + delta));
            input.value = val;
            updateExchangeCostHint();
        }

        document.addEventListener('input', function(e) {
            if (e.target && e.target.id === 'exchangeTimes') {
                var val = parseInt(e.target.value) || 1;
                if (exchangeMaxTimes > 0) {
                    val = Math.max(1, Math.min(exchangeMaxTimes, val));
                    e.target.value = val;
                }
                updateExchangeCostHint();
            }
        });

        function updateExchangeCostHint() {
            if (exchangeMaxTimes <= 0) {
                document.getElementById('exchangeCostHint').textContent = '当前积分不足，无法兑换';
                return;
            }
            var times = parseInt(document.getElementById('exchangeTimes').value) || 1;
            var cost = times * exchangeRatio;
            document.getElementById('exchangeCostHint').textContent =
                '本次消耗 ' + cost + ' 积分，兑换 ' + times + ' 次抽奖机会';
        }

        function doExchange() {
            var times = parseInt(document.getElementById('exchangeTimes').value);
            if (!times || times <= 0) { showMessage('请输入有效的兑换次数', 'error'); return; }
            if (times > exchangeMaxTimes) {
                showMessage('兑换次数不能超过 ' + exchangeMaxTimes + ' 次（积分不足）', 'error');
                document.getElementById('exchangeTimes').value = exchangeMaxTimes > 0 ? exchangeMaxTimes : 1;
                updateExchangeCostHint();
                return;
            }
            var btn = document.getElementById('exchangeConfirmBtn');
            btn.disabled = true;
            fetch('/mobile/exchangePoints', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'times=' + times
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                btn.disabled = false;
                if (data.success) {
                    document.getElementById('exchangeModal').classList.remove('show');
                    lotteryCount = data.lotteryCount;
                    updateLotteryUI();
                    document.getElementById('quickActions').style.display = 'flex';
                    updateTotalPoints();
                    // 更新兑换按钮提示
                    loadExchangeConfig();
                    showMessage('🎉 ' + data.message, 'success');
                } else {
                    showMessage('❌ ' + data.message, 'error');
                }
            })
            .catch(function() {
                btn.disabled = false;
                showMessage('网络错误，请重试', 'error');
            });
        }
        var lotteryCount = 0;
        var wheelSpinning = false;
        var currentAngle = 0;
        var wheelDrawn = false;

        var WHEEL_COLORS = ['#4fd1c5','#f6d365','#fda085','#a29bfe','#fd79a8','#00b894','#fdcb6e','#e17055','#74b9ff','#55efc4'];

        function loadLotteryData() {
            return fetch('/mobile/lotteryItems')
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.success && data.items && data.items.length > 0) {
                        lotteryItems = data.items;
                        lotteryCount = data.lotteryCount || 0;
                        updateLotteryUI();
                        document.getElementById('quickActions').style.display = 'flex';
                    } else {
                        // 抽奖项被全部删除/禁用，或次数为0：重置状态，隐藏入口
                        lotteryItems = [];
                        lotteryCount = data.lotteryCount || 0;
                        updateLotteryUI();
                        if (lotteryItems.length === 0) {
                            document.getElementById('quickActions').style.display = 'none';
                        }
                    }
                })
                .catch(function(e) { console.log('抽奖数据加载失败:', e); });
        }

        function updateLotteryUI() {
            document.getElementById('lotteryCountDisplay').textContent = lotteryCount;
            document.getElementById('lotteryBtn').disabled = lotteryCount <= 0;
            document.getElementById('lotteryCountBadge').textContent = '剩余 ' + lotteryCount + ' 次';
            var entryBtn = document.getElementById('lotteryEntryBtn');
            if (lotteryCount <= 0) {
                entryBtn.classList.add('disabled-btn');
                entryBtn.classList.remove('lottery');
            } else {
                entryBtn.classList.remove('disabled-btn');
                entryBtn.classList.add('lottery');
            }
        }

        function openLotteryModal() {
            document.getElementById('lotteryModal').classList.add('show');
            // 弹窗打开后绘制转盘
            setTimeout(function() { drawWheel(currentAngle); }, 50);
        }

        function closeLotteryModal(e) {
            if (e && e.target !== document.getElementById('lotteryModal')) return;
            document.getElementById('lotteryModal').classList.remove('show');
        }

        function openRecordsModal() {
            document.getElementById('recordsModal').classList.add('show');
            // 默认显示未兑奖
            currentRecordsTab = 0;
            document.getElementById('tabPending').classList.add('active');
            document.getElementById('tabRedeemed').classList.remove('active');
            loadMyLotteryRecords(0);
        }

        function switchRecordsTab(status) {
            currentRecordsTab = status;
            document.getElementById('tabPending').classList.toggle('active', status === 0);
            document.getElementById('tabRedeemed').classList.toggle('active', status === 1);
            document.getElementById('lotteryRecordList').innerHTML =
                '<div style="text-align:center;padding:30px;color:#718096;">加载中...</div>';
            loadMyLotteryRecords(status);
        }

        var currentRecordsTab = 0;

        function closeRecordsModal(e) {
            if (e && e.target !== document.getElementById('recordsModal')) return;
            document.getElementById('recordsModal').classList.remove('show');
        }

        function drawWheel(rotationAngle) {
            var canvas = document.getElementById('wheelCanvas');
            if (!canvas) return;
            var ctx = canvas.getContext('2d');
            var items = lotteryItems;
            if (!items || items.length === 0) return;

            var cx = canvas.width / 2;
            var cy = canvas.height / 2;
            var radius = cx - 5;
            var sliceAngle = (2 * Math.PI) / items.length;

            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // 绘制外圈装饰
            ctx.beginPath();
            ctx.arc(cx, cy, radius + 4, 0, 2 * Math.PI);
            ctx.strokeStyle = '#4fd1c5';
            ctx.lineWidth = 4;
            ctx.stroke();

            items.forEach(function(item, i) {
                var startAngle = rotationAngle + i * sliceAngle;
                var endAngle = startAngle + sliceAngle;

                // 绘制扇形
                ctx.beginPath();
                ctx.moveTo(cx, cy);
                ctx.arc(cx, cy, radius, startAngle, endAngle);
                ctx.closePath();
                ctx.fillStyle = WHEEL_COLORS[i % WHEEL_COLORS.length];
                ctx.fill();
                ctx.strokeStyle = 'white';
                ctx.lineWidth = 2;
                ctx.stroke();

                // 绘制文字
                ctx.save();
                ctx.translate(cx, cy);
                ctx.rotate(startAngle + sliceAngle / 2);
                ctx.textAlign = 'right';
                ctx.fillStyle = 'white';
                ctx.font = 'bold 13px -apple-system, sans-serif';
                ctx.shadowColor = 'rgba(0,0,0,0.3)';
                ctx.shadowBlur = 3;
                var text = item.name.length > 6 ? item.name.substring(0, 6) + '..' : item.name;
                ctx.fillText(text, radius - 12, 5);
                ctx.restore();
            });

            // 中心圆
            ctx.beginPath();
            ctx.arc(cx, cy, 28, 0, 2 * Math.PI);
            ctx.fillStyle = 'white';
            ctx.fill();
            ctx.strokeStyle = '#4fd1c5';
            ctx.lineWidth = 3;
            ctx.stroke();
            ctx.fillStyle = '#2d3748';
            ctx.font = 'bold 12px -apple-system, sans-serif';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText('抽奖', cx, cy);
        }

        function doLottery() {
            if (wheelSpinning) return;
            if (lotteryCount <= 0) {
                showMessage('抽奖次数已用完 😢', 'error');
                return;
            }
            if (lotteryItems.length === 0) {
                showMessage('暂无可用奖品', 'error');
                return;
            }

            wheelSpinning = true;
            document.getElementById('lotteryBtn').disabled = true;

            fetch('/mobile/doLottery', { method: 'POST' })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.success) {
                        var prize = data.prize;
                        var remaining = data.remainingCount;
                        // 若抽到小红花奖品，更新花朵余量显示
                        if (data.flowerRewarded && data.flowerRewarded > 0) {
                            updateFlowerBadge(data.flowerBalance || 0);
                        }

                        // 找到中奖奖品的索引
                        var prizeIndex = lotteryItems.findIndex(function(i) { return i.name === prize; });
                        if (prizeIndex < 0) {
                            // 本地奖品列表与后端不一致（后台已修改），先停止转动
                            wheelSpinning = false;
                            lotteryCount = remaining;
                            showMessage('🔄 奖品列表已更新，正在刷新...', 'info');
                            // 自动重载抽奖数据，重载后再提示中奖
                            loadLotteryData().then(function() {
                                showMessage('🎉 恭喜获得：' + prize + '！请重新查看转盘', 'success');
                                document.getElementById('lotteryBtn').disabled = lotteryCount <= 0;
                            });
                            return;
                        }

                        // 计算目标角度：让对应扇形转到顶部指针处
                        var sliceAngle = (2 * Math.PI) / lotteryItems.length;
                        var targetSliceCenter = prizeIndex * sliceAngle + sliceAngle / 2;
                        // 转盘需要旋转使 targetSliceCenter 到达 -π/2（顶部）
                        var targetAngle = -Math.PI / 2 - targetSliceCenter;
                        // 加上几圈旋转增加动画效果
                        var totalRotation = currentAngle + (5 * 2 * Math.PI) + (targetAngle - (currentAngle % (2 * Math.PI)));

                        spinWheel(totalRotation, prize, remaining);
                    } else {                        // 同步后端返回的最新次数
                        if (typeof data.remainingCount !== 'undefined') {
                            lotteryCount = data.remainingCount;
                            updateLotteryUI();
                        }
                        showMessage(data.message || '抽奖失败，请重试', 'error');
                        wheelSpinning = false;
                        document.getElementById('lotteryBtn').disabled = lotteryCount <= 0;
                        // 奖品列表变更时自动重载
                        if (data.errorType === 'NO_ITEMS') {
                            setTimeout(function() { loadLotteryData(); }, 1500);
                        }
                    }
                })
                .catch(function(e) {
                    showMessage('网络错误，请检查连接后重试', 'error');
                    wheelSpinning = false;
                    document.getElementById('lotteryBtn').disabled = false;
                });
        }

        function spinWheel(targetAngle, prize, remaining) {
            var startAngle = currentAngle;
            var duration = 3500;
            var startTime = null;

            function easeOut(t) {
                return 1 - Math.pow(1 - t, 4);
            }

            function animate(timestamp) {
                if (!startTime) startTime = timestamp;
                var elapsed = timestamp - startTime;
                var progress = Math.min(elapsed / duration, 1);
                var easedProgress = easeOut(progress);

                currentAngle = startAngle + (targetAngle - startAngle) * easedProgress;
                drawWheel(currentAngle);

                if (progress < 1) {
                    requestAnimationFrame(animate);
                } else {
                    currentAngle = targetAngle;
                    wheelSpinning = false;
                    lotteryCount = remaining;
                    updateLotteryUI();
                    // 显示结果
                    setTimeout(function() { showPrize(prize); }, 200);
                    // 刷新记录（静默），按当前 tab 刷新
                    loadMyLotteryRecords(currentRecordsTab);
                }
            }
            requestAnimationFrame(animate);
        }

        function showPrize(prize) {
            document.getElementById('prizeName').textContent = prize;
            document.getElementById('prizeOverlay').classList.add('show');
        }

        function closePrizeOverlay() {
            document.getElementById('prizeOverlay').classList.remove('show');
        }

        function loadMyLotteryRecords(isRedeemed) {
            var url = '/mobile/myLotteryRecords?isRedeemed=' + (isRedeemed !== undefined ? isRedeemed : currentRecordsTab);
            fetch(url)
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.success) {
                        renderLotteryRecords(data.records || [], isRedeemed !== undefined ? isRedeemed : currentRecordsTab);
                    }
                })
                .catch(function(e) { console.log('记录加载失败', e); });
        }

        function renderLotteryRecords(records, tabStatus) {
            var container = document.getElementById('lotteryRecordList');
            var emptyText = tabStatus === 0 ? '暂无未兑奖记录 🎉' : '暂无已兑奖记录';
            if (!records || records.length === 0) {
                container.innerHTML = '<div style="text-align:center;padding:20px;color:#718096;">' + emptyText + '</div>';
                return;
            }
            var html = '';
            records.forEach(function(r) {
                var timeStr = r.lotteryTime ? new Date(r.lotteryTime).toLocaleDateString('zh-CN', {month:'numeric',day:'numeric',hour:'numeric',minute:'numeric'}) : '';
                var statusHtml = r.isRedeemed === 1
                    ? '<span class="record-status-redeemed">✅ 已兑奖</span>'
                    : '<span class="record-status-pending">⏳ 待兑奖</span>';
                html += '<div class="record-item">'
                    + '<div><div class="record-prize">🎁 ' + r.itemName + '</div><div class="record-time">' + timeStr + '</div></div>'
                    + statusHtml
                    + '</div>';
            });
            container.innerHTML = html;
        }

        // 在页面加载时同时加载抽奖数据
        window.addEventListener('load', function() {
            updateDateInfo();
            loadCheckinItems();
            loadLotteryData();
            loadExchangeConfig();
        });
    </script>

<!-- ==================== 小红花面板 ==================== -->
<div id="flowerModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.55);z-index:3000;align-items:center;justify-content:center;padding:20px;box-sizing:border-box;">
  <div style="width:100%;max-width:480px;height:82vh;max-height:90vh;background:#fff;border-radius:20px;display:flex;flex-direction:column;overflow:hidden;box-shadow:0 20px 60px rgba(0,0,0,0.3);">
    <!-- 头部（固定，不滚动） -->
    <div style="background:linear-gradient(135deg,#ff758c,#ff7eb3);padding:16px 20px 18px;border-radius:20px 20px 0 0;color:#fff;flex-shrink:0;">
      <div style="display:flex;justify-content:space-between;align-items:center;">
        <div style="font-size:1.15rem;font-weight:700;">🌸 我的小红花</div>
        <button onclick="closeFlowerModal()" style="background:rgba(255,255,255,0.25);border:none;color:#fff;border-radius:50%;width:32px;height:32px;font-size:1.1rem;cursor:pointer;">✕</button>
      </div>
      <div style="margin-top:10px;display:flex;align-items:baseline;gap:8px;">
        <span style="font-size:2.5rem;font-weight:900;" id="flowerBalanceDisplay">0</span>
        <span style="font-size:1rem;opacity:0.9;">朵</span>
      </div>
    </div>
    <!-- Tab 导航（固定，不滚动） -->
    <div style="display:flex;border-bottom:2px solid #f0f0f0;background:#fff;flex-shrink:0;">
      <button id="flowerTab_redeem" onclick="switchFlowerTab('redeem')"
              style="flex:1;padding:12px 0;border:none;background:none;font-size:0.9rem;font-weight:600;color:#ff758c;border-bottom:2.5px solid #ff758c;cursor:pointer;">兑换</button>
      <button id="flowerTab_history" onclick="switchFlowerTab('history')"
              style="flex:1;padding:12px 0;border:none;background:none;font-size:0.9rem;color:#718096;border-bottom:2.5px solid transparent;cursor:pointer;">变更记录</button>
      <button id="flowerTab_redemptions" onclick="switchFlowerTab('redemptions')"
              style="flex:1;padding:12px 0;border:none;background:none;font-size:0.9rem;color:#718096;border-bottom:2.5px solid transparent;cursor:pointer;">兑换申请</button>
    </div>
    <!-- 内容区（填满剩余高度，各 Tab 独立滚动） -->
    <div style="flex:1;overflow:hidden;position:relative;">
      <!-- 兑换面板 -->
      <div id="flowerPanel_redeem" style="position:absolute;inset:0;overflow-y:auto;padding:16px;">
        <div id="flowerItemList" style="display:flex;flex-direction:column;gap:12px;">
          <div style="text-align:center;color:#a0aec0;padding:30px;">加载中...</div>
        </div>
      </div>
      <!-- 变更记录面板 -->
      <div id="flowerPanel_history" style="display:none;position:absolute;inset:0;overflow-y:auto;padding:16px;">
        <div id="flowerRecordList"></div>
      </div>
      <!-- 兑换申请面板 -->
      <div id="flowerPanel_redemptions" style="display:none;position:absolute;inset:0;overflow-y:auto;padding:16px;">
        <div id="flowerRedemptionList"></div>
      </div>
      <!-- 数量选择子面板（覆盖在内容区上） -->
      <div id="redeemPanel" style="display:none;position:absolute;inset:0;background:rgba(0,0,0,0.35);align-items:flex-end;z-index:10;">
        <div style="width:100%;background:#fff;border-radius:20px 20px 0 0;padding:24px 20px 30px;">
          <div style="font-size:1rem;font-weight:700;color:#2d3748;margin-bottom:16px;">
            🌸 兑换数量 — <span id="redeemItemName"></span>
          </div>
          <div style="display:flex;justify-content:space-between;font-size:0.85rem;color:#718096;margin-bottom:14px;">
            <span>每次消耗：<strong style="color:#ff758c;" id="redeemCostPerUnit"></strong> 朵</span>
            <span>每次时长：<strong style="color:#38a169;" id="redeemTimePerUnit"></strong></span>
          </div>
          <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
            <button onclick="var v=document.getElementById('redeemQtyInput');v.value=Math.max(1,parseInt(v.value)-1);calcRedeemSummary();"
                    style="width:40px;height:40px;border-radius:50%;border:2px solid #fed7e2;background:#fff5f7;font-size:1.3rem;color:#ff758c;cursor:pointer;font-weight:bold;">−</button>
            <input id="redeemQtyInput" type="number" min="1" value="1" oninput="calcRedeemSummary()"
                   style="flex:1;height:44px;text-align:center;font-size:1.4rem;font-weight:700;border:2px solid #fed7e2;border-radius:12px;color:#2d3748;">
            <button onclick="var v=document.getElementById('redeemQtyInput');v.value=Math.min(parseInt(v.max)||99,parseInt(v.value)+1);calcRedeemSummary();"
                    style="width:40px;height:40px;border-radius:50%;border:2px solid #fed7e2;background:#fff5f7;font-size:1.3rem;color:#ff758c;cursor:pointer;font-weight:bold;">+</button>
          </div>
          <div style="font-size:0.78rem;color:#a0aec0;text-align:center;margin-bottom:16px;" id="redeemLimitHint"></div>
          <div style="background:#fff5f7;border-radius:10px;padding:10px 14px;text-align:center;margin-bottom:18px;font-size:0.9rem;" id="redeemSummaryText"></div>
          <div style="display:flex;gap:10px;">
            <button onclick="closeRedeemPanel()"
                    style="flex:1;height:46px;border-radius:23px;border:1.5px solid #fed7e2;background:#fff;color:#ff758c;font-size:0.95rem;cursor:pointer;">取消</button>
            <button onclick="doFlowerRedeem()"
                    style="flex:2;height:46px;border-radius:23px;border:none;background:linear-gradient(135deg,#ff758c,#ff7eb3);color:#fff;font-size:0.95rem;font-weight:700;cursor:pointer;">确认兑换</button>
          </div>
        </div>
      </div>
    </div><!-- 内容区 -->
  </div><!-- 面板主体 max-width -->
</div><!-- flowerModal -->

<script>
var flowerBalance = 0;
var currentFlowerTab = 'redeem';

function openFlowerModal() {
    document.getElementById('flowerModal').style.display = 'flex';
    document.body.style.overflow = 'hidden';
    loadFlowerInfo();
}
function closeFlowerModal() {
    document.getElementById('flowerModal').style.display = 'none';
    document.body.style.overflow = '';
}
function switchFlowerTab(tab) {
    currentFlowerTab = tab;
    ['redeem','history','redemptions'].forEach(function(t) {
        var panel = document.getElementById('flowerPanel_' + t);
        panel.style.display = (t === tab) ? 'block' : 'none';
        var btn = document.getElementById('flowerTab_' + t);
        btn.style.color = t === tab ? '#ff758c' : '#718096';
        btn.style.borderBottom = t === tab ? '2.5px solid #ff758c' : '2.5px solid transparent';
    });
    if (tab === 'history') loadFlowerRecords();
    if (tab === 'redemptions') loadMyRedemptions();
}
function loadFlowerInfo() {
    fetch('/flower/info')
        .then(function(r){ return r.json(); })
        .then(function(data){
            if (!data.success) return;
            flowerBalance = data.balance || 0;
            document.getElementById('flowerBalanceDisplay').textContent = flowerBalance;
            document.getElementById('flowerCountBadge').textContent = flowerBalance + ' 朵';
            renderFlowerItems(data.items || []);
        });
}
function renderFlowerItems(items) {
    var container = document.getElementById('flowerItemList');
    if (!items || items.length === 0) {
        container.innerHTML = '<div style="text-align:center;color:#a0aec0;padding:30px;">暂未配置兑换项目，联系家长添加 🌸</div>';
        return;
    }
    container.innerHTML = items.map(function(item) {
        var canRedeem = flowerBalance >= item.flowerCost;
        var timeStr = item.timeMinutes ? '（' + item.timeMinutes + ' 分钟/次）' : '';
        var limitStr = item.dailyLimit ? '每日上限 ' + item.dailyLimit + ' 朵' : '不限';
        return '<div style="background:#fff5f7;border:1.5px solid #fed7e2;border-radius:14px;padding:14px 16px;display:flex;justify-content:space-between;align-items:center;">' +
          '<div style="flex:1;min-width:0;">' +
            '<div style="font-size:0.98rem;font-weight:700;color:#2d3748;">' + item.name + timeStr + '</div>' +
            '<div style="font-size:0.78rem;color:#a0aec0;margin-top:3px;">' + limitStr +
              (item.description ? ' · ' + item.description : '') + '</div>' +
          '</div>' +
          '<div style="text-align:right;flex-shrink:0;margin-left:12px;">' +
            '<div style="font-size:1.05rem;font-weight:900;color:#ff758c;white-space:nowrap;">🌸×' + item.flowerCost + '/次</div>' +
            '<button onclick="openRedeemPanel(' + JSON.stringify(item).replace(/"/g,'&quot;') + ')"' +
              ' style="margin-top:6px;padding:6px 14px;border-radius:20px;border:none;font-size:0.82rem;font-weight:600;cursor:pointer;' +
              (canRedeem ? 'background:linear-gradient(135deg,#ff758c,#ff7eb3);color:#fff;' : 'background:#e2e8f0;color:#a0aec0;cursor:not-allowed;') + '"' +
              (canRedeem ? '' : ' disabled') + '>兑换</button>' +
          '</div>' +
        '</div>';
    }).join('');
}

// 当前选中兑换项目
var _redeemItem = null;
function openRedeemPanel(item) {
    _redeemItem = item;
    var maxQty = item.dailyLimit ? item.dailyLimit : 99;
    // 按余额限制最大数量
    var maxByBalance = item.flowerCost > 0 ? Math.floor(flowerBalance / item.flowerCost) : 99;
    maxQty = Math.min(maxQty, maxByBalance);
    if (maxQty <= 0) { showMessage('小红花不足 🌸', 'error'); return; }

    document.getElementById('redeemItemName').textContent = item.name;
    document.getElementById('redeemCostPerUnit').textContent = item.flowerCost;
    document.getElementById('redeemTimePerUnit').textContent = item.timeMinutes ? item.timeMinutes + ' 分钟' : '-';
    document.getElementById('redeemQtyInput').max = maxQty;
    document.getElementById('redeemQtyInput').value = 1;
    document.getElementById('redeemLimitHint').textContent = '最多可兑 ' + maxQty + ' 次';
    calcRedeemSummary();
    document.getElementById('redeemPanel').style.display = 'flex';
}
function closeRedeemPanel() {
    document.getElementById('redeemPanel').style.display = 'none';
}
function calcRedeemSummary() {
    if (!_redeemItem) return;
    var qty = parseInt(document.getElementById('redeemQtyInput').value);
    if (isNaN(qty) || qty < 1) { document.getElementById('redeemSummaryText').innerHTML = '<span style="color:#e53e3e;">数量至少为 1</span>'; return; }
    var totalCost = _redeemItem.flowerCost * qty;
    var totalTime = _redeemItem.timeMinutes ? _redeemItem.timeMinutes * qty : null;
    document.getElementById('redeemSummaryText').innerHTML =
        '消耗 <strong style="color:#ff758c;">🌸×' + totalCost + '</strong>' +
        (totalTime ? '，获得 <strong style="color:#38a169;">' + totalTime + ' 分钟</strong>' : '');
}
function doFlowerRedeem() {
    if (!_redeemItem) return;
    var qty = parseInt(document.getElementById('redeemQtyInput').value);
    if (isNaN(qty) || qty < 1) { showMessage('兑换数量至少为 1', 'error'); return; }
    var totalCost = _redeemItem.flowerCost * qty;
    if (flowerBalance < totalCost) { showMessage('小红花不足 🌸', 'error'); return; }
    var fd = new FormData();
    fd.append('itemId', _redeemItem.id);
    fd.append('qty', qty);
    fetch('/flower/redeem', { method:'POST', body: fd })
        .then(function(r){ return r.json(); })
        .then(function(data){
            if (data.success) {
                flowerBalance = data.newBalance || 0;
                document.getElementById('flowerBalanceDisplay').textContent = flowerBalance;
                document.getElementById('flowerCountBadge').textContent = flowerBalance + ' 朵';
                closeRedeemPanel();
                loadFlowerInfo();
                showMessage(data.message, 'success');
            } else {
                showMessage(data.message || '兑换失败', 'error');
            }
        })
        .catch(function(){ showMessage('网络错误', 'error'); });
}
function loadFlowerRecords() {
    fetch('/flower/records')
        .then(function(r){ return r.json(); })
        .then(function(data){
            var container = document.getElementById('flowerRecordList');
            if (!data.success || !data.records || data.records.length === 0) {
                container.innerHTML = '<div style="text-align:center;color:#a0aec0;padding:30px;">暂无变更记录</div>';
                return;
            }
            var typeLabel = {1:'🎰抽奖获得', 2:'🌸兑换消耗', 3:'👨‍👩‍👧家长调整', 4:'↩️撤销退还'};
            container.innerHTML = data.records.map(function(r){
                var sign = r.changeAmount > 0 ? '+' : '';
                var color = r.changeAmount > 0 ? '#38a169' : '#e53e3e';
                var d = r.operateTime ? new Date(r.operateTime).toLocaleString('zh-CN',{month:'numeric',day:'numeric',hour:'numeric',minute:'numeric'}) : '';
                return '<div style="display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid #f7fafc;">' +
                  '<div>' +
                    '<div style="font-size:0.88rem;color:#4a5568;">' + (typeLabel[r.type] || '变更') + '</div>' +
                    '<div style="font-size:0.75rem;color:#a0aec0;">' + (r.remark || '') + '  ' + d + '</div>' +
                  '</div>' +
                  '<div style="text-align:right;">' +
                    '<div style="font-size:1rem;font-weight:700;color:' + color + ';">' + sign + r.changeAmount + ' 朵</div>' +
                    '<div style="font-size:0.75rem;color:#a0aec0;">余 ' + r.balance + '</div>' +
                  '</div>' +
                '</div>';
            }).join('');
        });
}
function loadMyRedemptions() {
    fetch('/flower/myRedemptions')
        .then(function(r){ return r.json(); })
        .then(function(data){
            var container = document.getElementById('flowerRedemptionList');
            if (!data.success || !data.redemptions || data.redemptions.length === 0) {
                container.innerHTML = '<div style="text-align:center;color:#a0aec0;padding:30px;">暂无兑换申请记录</div>';
                return;
            }
            var statusLabel = {0:'⏳待审批', 1:'✅已审批', 2:'❌已撤销'};
            var statusColor = {0:'#d69e2e', 1:'#38a169', 2:'#a0aec0'};
            container.innerHTML = data.redemptions.map(function(r){
                var d = r.redeemTime ? new Date(r.redeemTime).toLocaleString('zh-CN',{month:'numeric',day:'numeric',hour:'numeric',minute:'numeric'}) : '';
                var timeStr = r.timeMinutes ? '（' + r.timeMinutes + ' 分钟）' : '';
                return '<div style="background:#fff5f7;border-radius:12px;padding:12px 14px;margin-bottom:10px;">' +
                  '<div style="display:flex;justify-content:space-between;">' +
                    '<div style="font-weight:600;color:#2d3748;">' + r.itemName + timeStr + '</div>' +
                    '<div style="font-size:0.82rem;font-weight:700;color:' + (statusColor[r.status]||'#718096') + ';">' + (statusLabel[r.status]||'') + '</div>' +
                  '</div>' +
                  '<div style="font-size:0.78rem;color:#a0aec0;margin-top:4px;">消耗 🌸×' + r.flowerCost + '  · ' + d + '</div>' +
                '</div>';
            }).join('');
        });
}
// 抽奖中奖小红花时刷新显示
function updateFlowerBadge(newBalance) {
    flowerBalance = newBalance;
    document.getElementById('flowerCountBadge').textContent = flowerBalance + ' 朵';
    if (document.getElementById('flowerBalanceDisplay')) {
        document.getElementById('flowerBalanceDisplay').textContent = flowerBalance;
    }
}
// 关闭背景点击
document.getElementById('flowerModal').addEventListener('click', function(e){
    if (e.target === this) closeFlowerModal();
});
// 页面初始化时加载小红花余量
(function initFlowerBadge(){
    fetch('/flower/info')
        .then(function(r){ return r.json(); })
        .then(function(data){
            if (data.success) {
                flowerBalance = data.balance || 0;
                document.getElementById('flowerCountBadge').textContent = flowerBalance + ' 朵';
            }
        }).catch(function(){});
})();
</script>
</body>
</html>
