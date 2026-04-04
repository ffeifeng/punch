package com.punch.service;

import com.punch.entity.TemplateStudent;
import java.util.List;

public interface TemplateStudentService {
    int assignTemplateToStudents(Long templateId, List<Long> studentIds, Long createBy);
    int removeTemplateFromStudents(Long templateId, List<Long> studentIds);
    int removeAllStudentsFromTemplate(Long templateId);
    
    List<Long> getStudentIdsByTemplateId(Long templateId);
    List<Long> getTemplateIdsByStudentId(Long studentId);
    
    boolean isTemplateAssignedToStudent(Long templateId, Long studentId);
}
