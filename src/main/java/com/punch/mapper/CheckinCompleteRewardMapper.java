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

    /** 获取某学生某模板某日的奖励记录（用于撤销时取回奖励次数） */
    CheckinCompleteReward selectByStudentTemplateDate(
        @Param("studentId") Long studentId,
        @Param("templateId") Long templateId,
        @Param("rewardDate") Date rewardDate
    );

    /** 删除某学生某模板某日的奖励记录（撤销打卡时收回奖励） */
    int deleteByStudentTemplateDate(
        @Param("studentId") Long studentId,
        @Param("templateId") Long templateId,
        @Param("rewardDate") Date rewardDate
    );
}
