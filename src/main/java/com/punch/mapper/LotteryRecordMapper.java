package com.punch.mapper;

import com.punch.entity.LotteryRecord;
import com.punch.dto.LotteryRecordDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface LotteryRecordMapper {
    LotteryRecord selectById(@Param("id") Long id);
    List<LotteryRecord> selectByStudentId(@Param("studentId") Long studentId);
    List<LotteryRecordDTO> selectByParentId(@Param("parentId") Long parentId,
                                             @Param("studentId") Long studentId,
                                             @Param("isRedeemed") Integer isRedeemed);
    int insert(LotteryRecord record);
    int update(LotteryRecord record);
}
