package com.lightdoc.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lightdoc.common.Result;
import com.lightdoc.dto.CreateNotificationDTO;
import com.lightdoc.dto.NotificationDTO;
import com.lightdoc.service.NotificationService;
import com.lightdoc.utils.SecurityUtils;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 通知控制器
 */
@RestController
@RequestMapping("/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    /**
     * 创建通知
     */
    @PostMapping
    public Result<Long> createNotification(@Valid @RequestBody CreateNotificationDTO dto) {
        Long notificationId = notificationService.createNotification(dto);
        return Result.success(notificationId);
    }

    /**
     * 批量创建通知
     */
    @PostMapping("/batch")
    public Result<Integer> createNotificationsBatch(@Valid @RequestBody List<CreateNotificationDTO> dtos) {
        int count = notificationService.createNotificationsBatch(dtos);
        return Result.success(count);
    }

    /**
     * 获取当前用户的通知列表（分页）
     */
    @GetMapping
    public Result<IPage<NotificationDTO>> getUserNotifications(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Integer isRead) {

        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        IPage<NotificationDTO> notifications = notificationService.getUserNotifications(userId, page, size, isRead);
        return Result.success(notifications);
    }

    /**
     * 获取通知详情
     */
    @GetMapping("/{notificationId}")
    public Result<NotificationDTO> getNotificationDetail(@PathVariable Long notificationId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        NotificationDTO notification = notificationService.getNotificationDetail(userId, notificationId);
        if (notification == null) {
            return Result.error("通知不存在");
        }
        return Result.success(notification);
    }

    /**
     * 标记通知为已读
     */
    @PutMapping("/{notificationId}/read")
    public Result<Boolean> markAsRead(@PathVariable Long notificationId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        boolean success = notificationService.markAsRead(userId, notificationId);
        return Result.success(success);
    }

    /**
     * 批量标记通知为已读
     */
    @PutMapping("/batch/read")
    public Result<Integer> markAsReadBatch(@RequestBody List<Long> notificationIds) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        int count = notificationService.markAsReadBatch(userId, notificationIds);
        return Result.success(count);
    }

    /**
     * 标记所有通知为已读
     */
    @PutMapping("/all/read")
    public Result<Integer> markAllAsRead() {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        int count = notificationService.markAllAsRead(userId);
        return Result.success(count);
    }

    /**
     * 删除通知
     */
    @DeleteMapping("/{notificationId}")
    public Result<Boolean> deleteNotification(@PathVariable Long notificationId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        boolean success = notificationService.deleteNotification(userId, notificationId);
        return Result.success(success);
    }

    /**
     * 批量删除通知
     */
    @DeleteMapping("/batch")
    public Result<Integer> deleteNotificationsBatch(@RequestBody List<Long> notificationIds) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        int count = notificationService.deleteNotificationsBatch(userId, notificationIds);
        return Result.success(count);
    }

    /**
     * 获取未读通知数量
     */
    @GetMapping("/unread/count")
    public Result<Long> getUnreadCount() {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        Long count = notificationService.getUnreadCount(userId);
        return Result.success(count);
    }

    /**
     * 获取当前用户发送的通知列表（分页）
     */
    @GetMapping("/sent")
    public Result<IPage<NotificationDTO>> getSentNotifications(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Integer isRead) {

        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        IPage<NotificationDTO> notifications = notificationService.getSentNotifications(userId, page, size, isRead);
        return Result.success(notifications);
    }

    /**
     * 获取当前用户发送的未读通知数量
     */
    @GetMapping("/sent/unread/count")
    public Result<Long> getSentUnreadCount() {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        Long count = notificationService.getSentUnreadCount(userId);
        return Result.success(count);
    }
}