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
    List<LotteryRecord> selectByStudentIdAndStatus(@Param("studentId") Long studentId,
                                                    @Param("isRedeemed") Integer isRedeemed);
    List<LotteryRecordDTO> selectByParentId(@Param("parentId") Long parentId,
                                             @Param("studentId") Long studentId,
                                             @Param("isRedeemed") Integer isRedeemed);
    /** 查询某家长下未兑奖记录按奖品分组统计（基于 lottery_item 配置项，含条数） */
    List<java.util.Map<String, Object>> countUnredeemedGroupByItem(@Param("parentId") Long parentId,
                                                                    @Param("studentId") Long studentId);
    /** 按 itemId 列表批量标记为已兑奖 */
    List<LotteryRecord> selectUnredeemedByItemIds(@Param("parentId") Long parentId,
                                                   @Param("studentId") Long studentId,
                                                   @Param("itemIds") List<Long> itemIds);
    int insert(LotteryRecord record);
    int update(LotteryRecord record);
}
