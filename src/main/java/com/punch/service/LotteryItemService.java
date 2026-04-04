package com.punch.service;

import com.punch.entity.LotteryItem;
import java.util.List;

public interface LotteryItemService {
    LotteryItem getById(Long id);
    List<LotteryItem> getByParentId(Long parentId);
    List<LotteryItem> getEnabledByParentId(Long parentId);
    int create(LotteryItem item);
    int update(LotteryItem item);
    int delete(Long id);
}
