package com.punch.service.impl;

import com.punch.entity.CheckinItem;
import com.punch.entity.CheckinTemplate;
import com.punch.dto.CheckinItemDTO;
import com.punch.mapper.CheckinItemMapper;
import com.punch.mapper.CheckinTemplateMapper;
import com.punch.service.CheckinItemService;
import com.punch.service.TemplateStudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.beans.BeanUtils;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class CheckinItemServiceImpl implements CheckinItemService {
    @Autowired
    private CheckinItemMapper itemMapper;
    
    @Autowired
    private CheckinTemplateMapper templateMapper;
    
    @Autowired
    private TemplateStudentService templateStudentService;

    @Override
    public CheckinItem getById(Long id) {
        return itemMapper.selectById(id);
    }

    @Override
    public List<CheckinItem> getByTemplateId(Long templateId) {
        return itemMapper.selectByTemplateId(templateId);
    }

    @Override
    public List<CheckinItemDTO> getByTemplateIdWithTemplate(Long templateId) {
        // 1. 获取指定模板的事项
        List<CheckinItem> items = itemMapper.selectByTemplateId(templateId);
        
        // 2. 转换为DTO并填充模板名称
        return items.stream().map(item -> {
            CheckinItemDTO dto = new CheckinItemDTO();
            BeanUtils.copyProperties(item, dto);
            
            // 根据templateId获取模板名称
            if (item.getTemplateId() != null) {
                CheckinTemplate template = templateMapper.selectById(item.getTemplateId());
                if (template != null) {
                    dto.setTemplateName(template.getTemplateName());
                }
            }
            
            return dto;
        }).collect(Collectors.toList());
    }

    @Override
    public List<CheckinItemDTO> getAllItemsWithTemplate() {
        // 1. 获取所有事项
        List<CheckinItem> items = itemMapper.selectAll();
        
        // 2. 转换为DTO并填充模板名称
        return items.stream().map(item -> {
            CheckinItemDTO dto = new CheckinItemDTO();
            BeanUtils.copyProperties(item, dto);
            
            // 根据templateId获取模板名称
            if (item.getTemplateId() != null) {
                CheckinTemplate template = templateMapper.selectById(item.getTemplateId());
                if (template != null) {
                    dto.setTemplateName(template.getTemplateName());
                }
            }
            
            return dto;
        }).collect(Collectors.toList());
    }

    @Override
    public int createItem(CheckinItem item) {
        // 每模板最多30项
        if (itemMapper.countByTemplateId(item.getTemplateId()) >= 30) {
            return -1;
        }
        return itemMapper.insert(item);
    }

    @Override
    public int updateItem(CheckinItem item) {
        return itemMapper.update(item);
    }

    @Override
    public int deleteItem(Long id) {
        return itemMapper.deleteById(id);
    }

    @Override
    public List<CheckinItemDTO> getActiveItemsWithTemplate() {
        // 1. 获取所有非禁用事项（status != 2）
        List<CheckinItem> items = itemMapper.selectActiveItems();
        
        // 2. 转换为DTO并填充模板名称
        return items.stream().map(item -> {
            CheckinItemDTO dto = new CheckinItemDTO();
            BeanUtils.copyProperties(item, dto);
            
            // 根据templateId获取模板名称
            if (item.getTemplateId() != null) {
                CheckinTemplate template = templateMapper.selectById(item.getTemplateId());
                if (template != null) {
                    dto.setTemplateName(template.getTemplateName());
                }
            }
            
            return dto;
        }).collect(Collectors.toList());
    }

    @Override
    public int countByTemplateId(Long templateId) {
        return itemMapper.countByTemplateId(templateId);
    }

    @Override
    public List<CheckinItemDTO> getActiveItemsForStudent(Long studentId) {
        // 如果学生ID为null，返回空列表
        if (studentId == null) {
            return new java.util.ArrayList<>();
        }
        
        // 1. 获取学生分配的模板ID列表
        List<Long> templateIds = templateStudentService.getTemplateIdsByStudentId(studentId);
        
        if (templateIds == null || templateIds.isEmpty()) {
            return new java.util.ArrayList<>();
        }
        
        // 2. 获取这些模板下的所有非禁用事项
        List<CheckinItem> items = itemMapper.selectActiveItems();
        
        // 3. 过滤出属于学生分配模板的事项
        List<CheckinItem> studentItems = items.stream()
                .filter(item -> templateIds.contains(item.getTemplateId()))
                .collect(Collectors.toList());
        
        // 4. 转换为DTO并填充模板名称
        return studentItems.stream().map(item -> {
            CheckinItemDTO dto = new CheckinItemDTO();
            BeanUtils.copyProperties(item, dto);
            
            // 根据templateId获取模板名称
            if (item.getTemplateId() != null) {
                CheckinTemplate template = templateMapper.selectById(item.getTemplateId());
                if (template != null) {
                    dto.setTemplateName(template.getTemplateName());
                }
            }
            
            return dto;
        }).collect(Collectors.toList());
    }

    @Override
    public List<CheckinItemDTO> getItemsByParentId(Long parentId) {
        if (parentId == null) {
            return new java.util.ArrayList<>();
        }
        
        // 1. 获取家长创建的模板ID列表
        List<CheckinTemplate> parentTemplates = templateMapper.selectByParentId(parentId);
        if (parentTemplates == null || parentTemplates.isEmpty()) {
            return new java.util.ArrayList<>();
        }
        
        List<Long> templateIds = parentTemplates.stream()
                .map(CheckinTemplate::getId)
                .collect(Collectors.toList());
        
        // 2. 获取所有事项
        List<CheckinItem> allItems = itemMapper.selectAll();
        
        // 3. 过滤出属于家长模板的事项
        List<CheckinItem> parentItems = allItems.stream()
                .filter(item -> templateIds.contains(item.getTemplateId()))
                .collect(Collectors.toList());
        
        // 4. 转换为DTO并填充模板名称
        List<CheckinItemDTO> dtos = new java.util.ArrayList<>();
        for (CheckinItem item : parentItems) {
            CheckinItemDTO dto = new CheckinItemDTO();
            BeanUtils.copyProperties(item, dto);
            
            // 填充模板名称
            CheckinTemplate template = templateMapper.selectById(item.getTemplateId());
            if (template != null) {
                dto.setTemplateName(template.getTemplateName());
            }
            
            dtos.add(dto);
        }
        
        return dtos;
    }

    @Override
    public boolean moveItemUp(Long id) {
        // 1. 获取当前事项
        CheckinItem currentItem = itemMapper.selectById(id);
        if (currentItem == null) {
            return false;
        }
        
        // 2. 获取同一模板下的所有事项，按sortOrder排序
        List<CheckinItem> items = itemMapper.selectByTemplateId(currentItem.getTemplateId());
        items.sort((a, b) -> a.getSortOrder().compareTo(b.getSortOrder()));
        
        // 3. 找到当前事项的位置
        int currentIndex = -1;
        for (int i = 0; i < items.size(); i++) {
            if (items.get(i).getId().equals(id)) {
                currentIndex = i;
                break;
            }
        }
        
        // 4. 如果已经是第一个，返回false
        if (currentIndex <= 0) {
            return false;
        }
        
        // 5. 和上一个事项交换sortOrder
        CheckinItem prevItem = items.get(currentIndex - 1);
        Integer tempOrder = currentItem.getSortOrder();
        currentItem.setSortOrder(prevItem.getSortOrder());
        prevItem.setSortOrder(tempOrder);
        
        // 6. 更新数据库
        itemMapper.update(currentItem);
        itemMapper.update(prevItem);
        
        return true;
    }

    @Override
    public boolean moveItemDown(Long id) {
        // 1. 获取当前事项
        CheckinItem currentItem = itemMapper.selectById(id);
        if (currentItem == null) {
            return false;
        }
        
        // 2. 获取同一模板下的所有事项，按sortOrder排序
        List<CheckinItem> items = itemMapper.selectByTemplateId(currentItem.getTemplateId());
        items.sort((a, b) -> a.getSortOrder().compareTo(b.getSortOrder()));
        
        // 3. 找到当前事项的位置
        int currentIndex = -1;
        for (int i = 0; i < items.size(); i++) {
            if (items.get(i).getId().equals(id)) {
                currentIndex = i;
                break;
            }
        }
        
        // 4. 如果已经是最后一个，返回false
        if (currentIndex < 0 || currentIndex >= items.size() - 1) {
            return false;
        }
        
        // 5. 和下一个事项交换sortOrder
        CheckinItem nextItem = items.get(currentIndex + 1);
        Integer tempOrder = currentItem.getSortOrder();
        currentItem.setSortOrder(nextItem.getSortOrder());
        nextItem.setSortOrder(tempOrder);
        
        // 6. 更新数据库
        itemMapper.update(currentItem);
        itemMapper.update(nextItem);
        
        return true;
    }
}
