package com.punch.service;

import com.punch.entity.CheckinTemplate;
import com.punch.dto.CheckinTemplateDTO;
import java.util.List;

public interface CheckinTemplateService {
    CheckinTemplate getById(Long id);
    List<CheckinTemplate> getByParentId(Long parentId);
    List<CheckinTemplateDTO> getTemplatesWithStudentNames(Long parentId);
    List<CheckinTemplateDTO> getAllTemplatesWithStudentNames();
    int createTemplate(CheckinTemplate template);
    int updateTemplate(CheckinTemplate template);
    int deleteTemplate(Long id);
    List<CheckinTemplate> getAllTemplates();
    int countByParentId(Long parentId);
}
