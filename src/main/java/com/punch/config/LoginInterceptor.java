package com.punch.config;

import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.lang.NonNull;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class LoginInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull Object handler) throws Exception {
        HttpSession session = request.getSession();
        Object user = session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("/login");
            return false;
        }
        
        return true;
    }
}
