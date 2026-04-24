package com.punch.service;

import com.punch.entity.FlowerItem;
import java.util.List;

public interface FlowerItemService {
    FlowerItem getById(Long id);
    List<FlowerItem> getByParentId(Long parentId);
    List<FlowerItem> getEnabledByParentId(Long parentId);
    int create(FlowerItem item);
    int update(FlowerItem item);
    int delete(Long id);
}
