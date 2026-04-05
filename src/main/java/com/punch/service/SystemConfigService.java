package com.punch.service;

public interface SystemConfigService {

    /** 获取积分兑换抽奖比例（每N积分换1次），0表示关闭 */
    int getPointsToLotteryRatio(Long parentId);

    /** 保存积分兑换抽奖比例 */
    void savePointsToLotteryRatio(Long parentId, int ratio, String configName, String description);
}
