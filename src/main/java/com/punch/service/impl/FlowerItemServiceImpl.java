package com.punch.service.impl;

import com.punch.entity.FlowerItem;
import com.punch.mapper.FlowerItemMapper;
import com.punch.service.FlowerItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.List;

@Service
public class FlowerItemServiceImpl implements FlowerItemService {

    @Autowired
    private FlowerItemMapper flowerItemMapper;

    @Override
    public FlowerItem getById(Long id) {
        return flowerItemMapper.selectById(id);
    }

    @Override
    public List<FlowerItem> getByParentId(Long parentId) {
        return flowerItemMapper.selectByParentId(parentId);
    }

    @Override
    public List<FlowerItem> getEnabledByParentId(Long parentId) {
        return flowerItemMapper.selectEnabledByParentId(parentId);
    }

    @Override
    public int create(FlowerItem item) {
        item.setCreateTime(new Date());
        item.setUpdateTime(new Date());
        if (item.getSortOrder() == null) item.setSortOrder(0);
        return flowerItemMapper.insert(item);
    }

    @Override
    public int update(FlowerItem item) {
        item.setUpdateTime(new Date());
        return flowerItemMapper.update(item);
    }

    @Override
    public int delete(Long id) {
        return flowerItemMapper.deleteById(id);
    }
}
