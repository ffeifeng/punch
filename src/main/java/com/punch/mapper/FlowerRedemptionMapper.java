package com.punch.mapper;

import com.punch.entity.FlowerRedemption;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface FlowerRedemptionMapper {
    int insert(FlowerRedemption redemption);
    int update(FlowerRedemption redemption);
    FlowerRedemption selectById(@Param("id") Long id);
    /** 查询某学生的兑换记录（最新在前） */
    List<FlowerRedemption> selectByStudentId(@Param("studentId") Long studentId);
    /** 查询某家长下所有孩子的待审批记录 */
    List<FlowerRedemption> selectPendingByParentId(@Param("parentId") Long parentId);
    /** 查询某家长下所有兑换记录 */
    List<FlowerRedemption> selectByParentId(@Param("parentId") Long parentId,
                                            @Param("status") Integer status);
    /** 统计某学生今日某项目已兑换次数（非撤销状态） */
    int countTodayByStudentAndItem(@Param("studentId") Long studentId,
                                   @Param("itemId") Long itemId,
                                   @Param("today") java.sql.Date today);
}
