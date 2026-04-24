package com.punch.service.impl;

import com.punch.entity.LotteryItem;
import com.punch.mapper.LotteryItemMapper;
import com.punch.service.LotteryItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.List;

@Service
public class LotteryItemServiceImpl implements LotteryItemService {

    @Autowired
    private LotteryItemMapper lotteryItemMapper;

    @Override
    public LotteryItem getById(Long id) {
        return lotteryItemMapper.selectById(id);
    }

    @Override
    public List<LotteryItem> getByParentId(Long parentId) {
        return lotteryItemMapper.selectByParentId(parentId);
    }

    @Override
    public List<LotteryItem> getEnabledByParentId(Long parentId) {
        return lotteryItemMapper.selectEnabledByParentId(parentId);
    }

    @Override
    public List<LotteryItem> getEnabledPityPrizesByParentId(Long parentId) {
        return lotteryItemMapper.selectEnabledPityByParentId(parentId);
    }

    @Override
    public int create(LotteryItem item) {
        item.setCreateTime(new Date());
        item.setUpdateTime(new Date());
        return lotteryItemMapper.insert(item);
    }

    @Override
    public int update(LotteryItem item) {
        item.setUpdateTime(new Date());
        return lotteryItemMapper.update(item);
    }

    @Override
    public int delete(Long id) {
        return lotteryItemMapper.deleteById(id);
    }
}
