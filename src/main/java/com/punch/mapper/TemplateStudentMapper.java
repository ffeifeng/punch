package com.punch.mapper;

import com.punch.entity.TemplateStudent;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface TemplateStudentMapper {
    int insert(TemplateStudent templateStudent);
    int deleteByTemplateId(@Param("templateId") Long templateId);
    int deleteByStudentId(@Param("studentId") Long studentId);
    int deleteByTemplateIdAndStudentId(@Param("templateId") Long templateId, @Param("studentId") Long studentId);
    
    List<TemplateStudent> selectByTemplateId(@Param("templateId") Long templateId);
    List<TemplateStudent> selectByStudentId(@Param("studentId") Long studentId);
    List<Long> selectStudentIdsByTemplateId(@Param("templateId") Long templateId);
    List<Long> selectTemplateIdsByStudentId(@Param("studentId") Long studentId);
    
    TemplateStudent selectByTemplateIdAndStudentId(@Param("templateId") Long templateId, @Param("studentId") Long studentId);
}
