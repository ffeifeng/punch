package com.punch.controller;

import com.punch.entity.OperationLog;
import com.punch.dto.OperationLogDTO;
import com.punch.service.OperationLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestParam;
import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/operationLog")
public class OperationLogController {
    @Autowired
    private OperationLogService logService;

    @GetMapping("/list")
    @ResponseBody
    public List<OperationLogDTO> list(@RequestParam(required = false) String userName,
                                      @RequestParam(required = false) String operation,
                                      @RequestParam(required = false) String content,
                                      @RequestParam(required = false) String ip,
                                      HttpSession session) {
        return logService.getByCondition(userName, operation, content, ip);
    }
}
