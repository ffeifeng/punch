package com.punch.mapper;

import com.punch.entity.OperationLog;
import com.punch.dto.OperationLogDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface OperationLogMapper {
    int insert(OperationLog log);
    List<OperationLog> selectAll();
    List<OperationLog> selectByUserId(@Param("userId") Long userId);
    List<OperationLogDTO> selectByCondition(@Param("userName") String userName, 
                                           @Param("operation") String operation, 
                                           @Param("content") String content, 
                                           @Param("ip") String ip);
}
