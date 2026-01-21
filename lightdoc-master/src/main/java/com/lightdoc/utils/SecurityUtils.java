package com.lightdoc.utils;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * 安全工具类
 * 用于获取当前登录用户信息
 */
public class SecurityUtils {

    private static final String USER_ID_ATTRIBUTE = "userId";

    /**
     * 获取当前登录用户ID
     *
     * @return 用户ID，如果未登录返回null
     */
    public static Long getCurrentUserId() {
        // 1. 首先从请求属性中获取（由JwtAuthenticationFilter设置）
        HttpServletRequest request = getCurrentRequest();
        if (request != null) {
            Object userId = request.getAttribute(USER_ID_ATTRIBUTE);
            if (userId instanceof Long) {
                return (Long) userId;
            } else if (userId instanceof Integer) {
                return ((Integer) userId).longValue();
            }
        }

        // 2. 如果请求属性中没有，尝试从SecurityContext中获取
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()) {
            Object principal = authentication.getPrincipal();
            if (principal instanceof String) {
                // 用户名格式，需要从JWT token中提取
                // 这里需要注入JwtUtil，但静态方法无法注入
                // 所以建议使用第一种方式（从请求属性中获取）
                return null;
            }
        }

        return null;
    }

    /**
     * 获取当前登录用户名
     *
     * @return 用户名，如果未登录返回null
     */
    public static String getCurrentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()) {
            return authentication.getName();
        }
        return null;
    }

    /**
     * 获取当前请求对象
     *
     * @return HttpServletRequest，如果不在请求上下文中返回null
     */
    public static HttpServletRequest getCurrentRequest() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes != null) {
            return attributes.getRequest();
        }
        return null;
    }

    /**
     * 检查当前用户是否已登录
     *
     * @return 是否已登录
     */
    public static boolean isAuthenticated() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal());
    }

    /**
     * 检查当前用户是否为管理员
     *
     * @return 是否为管理员
     */
    public static boolean isAdmin() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()) {
            return authentication.getAuthorities().stream()
                    .anyMatch(authority -> authority.getAuthority().equals("ROLE_ADMIN"));
        }
        return false;
    }
}