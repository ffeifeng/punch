package com.punch.service.impl;

import com.punch.entity.SystemConfig;
import com.punch.mapper.SystemConfigMapper;
import com.punch.service.SystemConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class SystemConfigServiceImpl implements SystemConfigService {

    private static final String KEY_POINTS_RATIO = "points_to_lottery_ratio";

    @Autowired
    private SystemConfigMapper systemConfigMapper;

    @Override
    public int getPointsToLotteryRatio(Long parentId) {
        SystemConfig config = systemConfigMapper.selectByKeyAndParent(KEY_POINTS_RATIO, parentId);
        if (config == null) return 0;
        try {
            return Integer.parseInt(config.getConfigValue());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    @Override
    public void savePointsToLotteryRatio(Long parentId, int ratio, String configName, String description) {
        SystemConfig config = new SystemConfig();
        config.setConfigKey(KEY_POINTS_RATIO);
        config.setConfigValue(String.valueOf(ratio));
        config.setConfigName(configName != null ? configName : "积分兑换抽奖比例");
        config.setDescription(description);
        config.setParentId(parentId);
        systemConfigMapper.insertOrUpdate(config);
    }
}
