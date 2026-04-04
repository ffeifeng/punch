package com.punch.service.impl;

import com.punch.entity.CheckinTemplate;
import com.punch.dto.CheckinTemplateDTO;
import com.punch.mapper.CheckinTemplateMapper;
import com.punch.mapper.UserMapper;
import com.punch.service.CheckinTemplateService;
import com.punch.service.TemplateStudentService;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class CheckinTemplateServiceImpl implements CheckinTemplateService {
    @Autowired
    private CheckinTemplateMapper templateMapper;
    
    @Autowired
    private TemplateStudentService templateStudentService;
    
    @Autowired
    private UserMapper userMapper;

    @Override
    public CheckinTemplate getById(Long id) {
        return templateMapper.selectById(id);
    }

    @Override
    public List<CheckinTemplate> getByParentId(Long parentId) {
        return templateMapper.selectByParentId(parentId);
    }

    @Override
    public int createTemplate(CheckinTemplate template) {
        // 家长最多3个模板
        if (template.getParentId() != null && templateMapper.selectByParentId(template.getParentId()).size() >= 3) {
            return -1;
        }
        return templateMapper.insert(template);
    }

    @Override
    public int updateTemplate(CheckinTemplate template) {
        return templateMapper.update(template);
    }

    @Override
    public int deleteTemplate(Long id) {
        return templateMapper.deleteById(id);
    }

    @Override
    public List<CheckinTemplate> getAllTemplates() {
        return templateMapper.selectAll();
    }

    @Override
    public int countByParentId(Long parentId) {
        return templateMapper.selectByParentId(parentId).size();
    }

    @Override
    public List<CheckinTemplateDTO> getTemplatesWithStudentNames(Long parentId) {
        List<CheckinTemplate> templates = templateMapper.selectByParentId(parentId);
        return templates.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    @Override
    public List<CheckinTemplateDTO> getAllTemplatesWithStudentNames() {
        List<CheckinTemplate> templates = templateMapper.selectAll();
        return templates.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    /**
     * 将CheckinTemplate转换为CheckinTemplateDTO，并填充学生姓名
     */
    private CheckinTemplateDTO convertToDTO(CheckinTemplate template) {
        CheckinTemplateDTO dto = new CheckinTemplateDTO();
        BeanUtils.copyProperties(template, dto);
        
        // 获取分配给该模板的学生ID列表
        List<Long> studentIds = templateStudentService.getStudentIdsByTemplateId(template.getId());
        
        if (studentIds != null && !studentIds.isEmpty()) {
            // 获取学生姓名并用逗号连接
            List<String> studentNames = studentIds.stream()
                .map(studentId -> {
                    try {
                        return userMapper.selectById(studentId).getRealName();
                    } catch (Exception e) {
                        return "未知用户";
                    }
                })
                .filter(name -> name != null && !name.trim().isEmpty())
                .collect(Collectors.toList());
            
            dto.setStudentNames(String.join(", ", studentNames));
        } else {
            dto.setStudentNames("未分配");
        }
        
        return dto;
    }
}
