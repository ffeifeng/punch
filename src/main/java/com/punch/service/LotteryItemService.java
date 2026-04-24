package com.punch.service;

import com.punch.entity.LotteryItem;
import java.util.List;

public interface LotteryItemService {
    LotteryItem getById(Long id);
    List<LotteryItem> getByParentId(Long parentId);
    List<LotteryItem> getEnabledByParentId(Long parentId);
    /** 获取某家长下已启用的保底奖品列表 */
    List<LotteryItem> getEnabledPityPrizesByParentId(Long parentId);
    int create(LotteryItem item);
    int update(LotteryItem item);
    int delete(Long id);
}
