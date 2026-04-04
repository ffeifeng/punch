package com.punch.service;

import com.punch.entity.OperationLog;
import com.punch.dto.OperationLogDTO;
import java.util.List;

public interface OperationLogService {
    int insert(OperationLog log);
    List<OperationLog> getAll();
    List<OperationLog> getByUserId(Long userId);
    List<OperationLogDTO> getByCondition(String userName, String operation, String content, String ip);
}
