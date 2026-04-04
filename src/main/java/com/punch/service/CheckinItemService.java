package com.punch.service;

import com.punch.entity.CheckinItem;
import com.punch.dto.CheckinItemDTO;
import java.util.List;

public interface CheckinItemService {
    CheckinItem getById(Long id);
    List<CheckinItem> getByTemplateId(Long templateId);
    List<CheckinItemDTO> getByTemplateIdWithTemplate(Long templateId); // 返回DTO，包含模板名称
    List<CheckinItemDTO> getAllItemsWithTemplate();
    List<CheckinItemDTO> getActiveItemsWithTemplate(); // 获取非禁用的事项
    List<CheckinItemDTO> getActiveItemsForStudent(Long studentId); // 获取学生分配的事项
    List<CheckinItemDTO> getItemsByParentId(Long parentId); // 获取家长创建的模板下的事项
    int createItem(CheckinItem item);
    int updateItem(CheckinItem item);
    int deleteItem(Long id);
    int countByTemplateId(Long templateId);
    boolean moveItemUp(Long id); // 上移事项
    boolean moveItemDown(Long id); // 下移事项
}
