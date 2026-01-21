package com.lightdoc.controller;

import com.lightdoc.common.Result;
import com.lightdoc.entity.User;
import com.lightdoc.service.UserService;
import com.lightdoc.utils.SecurityUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * 搜索用户
     *
     * @param keyword 搜索关键词（用户名或邮箱）
     * @param excludeIds 排除的用户ID列表（逗号分隔）
     * @return 用户列表
     */
    @GetMapping("/search")
    public Result<List<User>> searchUsers(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String excludeIds) {

        List<Long> excludeIdList = new ArrayList<>();
        if (excludeIds != null && !excludeIds.trim().isEmpty()) {
            String[] ids = excludeIds.split(",");
            for (String id : ids) {
                try {
                    excludeIdList.add(Long.parseLong(id.trim()));
                } catch (NumberFormatException e) {
                    // 忽略无效的ID
                }
            }
        }

        List<User> users = userService.searchUsers(keyword, excludeIdList);
        return Result.success(users);
    }
}