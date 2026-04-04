package com.punch.service.impl;

import com.punch.entity.TemplateStudent;
import com.punch.mapper.TemplateStudentMapper;
import com.punch.service.TemplateStudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.List;

@Service
public class TemplateStudentServiceImpl implements TemplateStudentService {
    
    @Autowired
    private TemplateStudentMapper templateStudentMapper;
    
    @Override
    public int assignTemplateToStudents(Long templateId, List<Long> studentIds, Long createBy) {
        if (studentIds == null || studentIds.isEmpty()) {
            return 0;
        }
        
        int count = 0;
        for (Long studentId : studentIds) {
            // 检查是否已存在，避免重复分配
            if (!isTemplateAssignedToStudent(templateId, studentId)) {
                TemplateStudent templateStudent = new TemplateStudent();
                templateStudent.setTemplateId(templateId);
                templateStudent.setStudentId(studentId);
                templateStudent.setCreateBy(createBy);
                templateStudent.setCreateTime(new Date());
                count += templateStudentMapper.insert(templateStudent);
            }
        }
        return count;
    }
    
    @Override
    public int removeTemplateFromStudents(Long templateId, List<Long> studentIds) {
        if (studentIds == null || studentIds.isEmpty()) {
            return 0;
        }
        
        int count = 0;
        for (Long studentId : studentIds) {
            count += templateStudentMapper.deleteByTemplateIdAndStudentId(templateId, studentId);
        }
        return count;
    }
    
    @Override
    public int removeAllStudentsFromTemplate(Long templateId) {
        return templateStudentMapper.deleteByTemplateId(templateId);
    }
    
    @Override
    public List<Long> getStudentIdsByTemplateId(Long templateId) {
        return templateStudentMapper.selectStudentIdsByTemplateId(templateId);
    }
    
    @Override
    public List<Long> getTemplateIdsByStudentId(Long studentId) {
        return templateStudentMapper.selectTemplateIdsByStudentId(studentId);
    }
    
    @Override
    public boolean isTemplateAssignedToStudent(Long templateId, Long studentId) {
        TemplateStudent result = templateStudentMapper.selectByTemplateIdAndStudentId(templateId, studentId);
        return result != null;
    }
}
