<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>配置管理</title>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-easyui-1.4.2/jquery.min.js"></script>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f7fafc; margin: 0; padding: 20px; }
        .page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
        .page-title { font-size: 1.4rem; font-weight: 700; color: #2d3748; }
        .page-subtitle { font-size: 0.88rem; color: #718096; margin-top: 2px; }
        .config-card { background: white; border-radius: 16px; padding: 28px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); margin-bottom: 20px; }
        .config-card-title { font-size: 1rem; font-weight: 600; color: #2d3748; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; border-bottom: 2px solid #edf2f7; padding-bottom: 12px; }
        .form-row { display: flex; align-items: flex-start; gap: 20px; flex-wrap: wrap; }
        .form-group { flex: 1; min-width: 200px; }
        .form-label { display: block; font-size: 0.85rem; font-weight: 600; color: #4a5568; margin-bottom: 8px; }
        .form-input { width: 100%; padding: 10px 14px; border: 1.5px solid #e2e8f0; border-radius: 10px; font-size: 0.95rem; box-sizing: border-box; transition: border-color 0.2s; }
        .form-input:focus { outline: none; border-color: #667eea; }
        .form-hint { font-size: 0.78rem; color: #a0aec0; margin-top: 5px; }
        .btn-save { padding: 10px 28px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 10px; font-size: 0.95rem; font-weight: 600; cursor: pointer; transition: all 0.2s; }
        .btn-save:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(102,126,234,0.4); }
        .status-tag { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 20px; font-size: 0.85rem; font-weight: 600; }
        .status-on { background: #c6f6d5; color: #276749; }
        .status-off { background: #fed7d7; color: #9b2c2c; }
        .preview-box { background: linear-gradient(135deg, #667eea10, #764ba210); border: 1.5px solid #667eea30; border-radius: 12px; padding: 16px 20px; margin-top: 16px; }
        .preview-text { font-size: 0.9rem; color: #553c9a; font-weight: 500; }
        .msg-success { color: #276749; background: #c6f6d5; border-radius: 8px; padding: 10px 16px; margin-top: 12px; display: none; font-size: 0.9rem; }
        .msg-error { color: #9b2c2c; background: #fed7d7; border-radius: 8px; padding: 10px 16px; margin-top: 12px; display: none; font-size: 0.9rem; }
    </style>
</head>
<body>
<div class="page-header">
    <div>
        <div class="page-title">⚙️ 配置管理</div>
        <div class="page-subtitle">管理系统参数配置，自定义规则设置</div>
    </div>
</div>

<!-- 积分兑换抽奖配置 -->
<div class="config-card">
    <div class="config-card-title">🎰 积分兑换抽奖配置</div>

    <div style="margin-bottom:16px;">
        当前状态：<span id="statusTag" class="status-tag">加载中...</span>
    </div>

    <div class="form-row">
        <div class="form-group" style="max-width:260px;">
            <label class="form-label">兑换比例（积分 / 次）</label>
            <input type="number" id="ratioInput" class="form-input" min="0" max="99999" placeholder="如：100" value="">
            <div class="form-hint">填 0 表示关闭此功能；填 100 表示消耗 100 积分换 1 次抽奖</div>
        </div>
        <div class="form-group">
            <label class="form-label">备注说明（可选）</label>
            <input type="text" id="descInput" class="form-input" placeholder="如：完成100积分任务，奖励1次抽奖机会" maxlength="100">
        </div>
    </div>

    <div class="preview-box" id="previewBox" style="display:none;">
        <div class="preview-text" id="previewText"></div>
    </div>

    <div style="margin-top:20px;">
        <button class="btn-save" onclick="saveConfig()">💾 保存配置</button>
    </div>

    <div class="msg-success" id="msgSuccess"></div>
    <div class="msg-error" id="msgError"></div>
</div>

<script>
    // 加载当前配置
    function loadConfig() {
        $.get('/config/pointsRatio', function(data) {
            if (data.success) {
                var ratio = data.ratio;
                $('#ratioInput').val(ratio);
                updateStatus(ratio);
                updatePreview(ratio);
            }
        });
    }

    function updateStatus(ratio) {
        var tag = $('#statusTag');
        if (ratio > 0) {
            tag.text('✅ 已开启（' + ratio + ' 积分 = 1 次抽奖）').removeClass('status-off').addClass('status-on status-tag');
        } else {
            tag.text('❌ 已关闭').removeClass('status-on').addClass('status-off status-tag');
        }
    }

    function updatePreview(ratio) {
        if (ratio > 0) {
            $('#previewText').text('💡 规则预览：孩子每积累 ' + ratio + ' 积分，可在打卡页面兑换 1 次抽奖机会');
            $('#previewBox').show();
        } else {
            $('#previewBox').hide();
        }
    }

    $('#ratioInput').on('input', function() {
        var v = parseInt($(this).val()) || 0;
        updatePreview(v);
    });

    function saveConfig() {
        var ratio = parseInt($('#ratioInput').val());
        if (isNaN(ratio) || ratio < 0) {
            showMsg('error', '请输入有效的积分比例（≥0 的整数）');
            return;
        }
        var desc = $('#descInput').val().trim();
        $.post('/config/savePointsRatio', { ratio: ratio, description: desc }, function(data) {
            if (data.success) {
                showMsg('success', '✅ ' + data.message);
                updateStatus(ratio);
                updatePreview(ratio);
            } else {
                showMsg('error', '❌ ' + data.message);
            }
        });
    }

    function showMsg(type, text) {
        $('#msgSuccess, #msgError').hide();
        if (type === 'success') { $('#msgSuccess').text(text).fadeIn(); setTimeout(function(){ $('#msgSuccess').fadeOut(); }, 3000); }
        else { $('#msgError').text(text).fadeIn(); setTimeout(function(){ $('#msgError').fadeOut(); }, 4000); }
    }

    loadConfig();
</script>
</body>
</html>
