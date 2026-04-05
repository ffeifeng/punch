package com.punch.mapper;

import com.punch.entity.CheckinCompleteReward;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.Date;

@Mapper
public interface CheckinCompleteRewardMapper {

    int insert(CheckinCompleteReward reward);

    /** 查询某学生某模板某日是否已领取奖励 */
    int countByStudentTemplateDate(
        @Param("studentId") Long studentId,
        @Param("templateId") Long templateId,
        @Param("rewardDate") Date rewardDate
    );
}
