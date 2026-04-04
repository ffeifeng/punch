package com.punch.service.impl;

import com.punch.entity.OperationLog;
import com.punch.dto.OperationLogDTO;
import com.punch.mapper.OperationLogMapper;
import com.punch.service.OperationLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class OperationLogServiceImpl implements OperationLogService {
    @Autowired
    private OperationLogMapper logMapper;

    @Override
    public int insert(OperationLog log) {
        return logMapper.insert(log);
    }

    @Override
    public List<OperationLog> getAll() {
        return logMapper.selectAll();
    }

    @Override
    public List<OperationLog> getByUserId(Long userId) {
        return logMapper.selectByUserId(userId);
    }

    @Override
    public List<OperationLogDTO> getByCondition(String userName, String operation, String content, String ip) {
        return logMapper.selectByCondition(userName, operation, content, ip);
    }
}
