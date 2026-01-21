package com.lightdoc.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lightdoc.dto.CreateNotificationDTO;
import com.lightdoc.dto.NotificationDTO;

import java.util.List;

/**
 * 通知服务接口
 */
public interface NotificationService {

    /**
     * 创建通知
     *
     * @param dto 创建通知DTO
     * @return 通知ID
     */
    Long createNotification(CreateNotificationDTO dto);

    /**
     * 批量创建通知
     *
     * @param dtos 创建通知DTO列表
     * @return 创建的通知数量
     */
    int createNotificationsBatch(List<CreateNotificationDTO> dtos);

    /**
     * 获取用户的通知列表（分页）
     *
     * @param userId 用户ID
     * @param page 页码
     * @param size 每页大小
     * @param isRead 是否已读（null表示全部）
     * @return 通知列表
     */
    IPage<NotificationDTO> getUserNotifications(Long userId, Integer page, Integer size, Integer isRead);

    /**
     * 获取用户的通知详情
     *
     * @param userId 用户ID
     * @param notificationId 通知ID
     * @return 通知详情
     */
    NotificationDTO getNotificationDetail(Long userId, Long notificationId);

    /**
     * 标记通知为已读
     *
     * @param userId 用户ID
     * @param notificationId 通知ID
     * @return 是否成功
     */
    boolean markAsRead(Long userId, Long notificationId);

    /**
     * 批量标记通知为已读
     *
     * @param userId 用户ID
     * @param notificationIds 通知ID列表
     * @return 影响的行数
     */
    int markAsReadBatch(Long userId, List<Long> notificationIds);

    /**
     * 标记所有通知为已读
     *
     * @param userId 用户ID
     * @return 影响的行数
     */
    int markAllAsRead(Long userId);

    /**
     * 删除通知
     *
     * @param userId 用户ID
     * @param notificationId 通知ID
     * @return 是否成功
     */
    boolean deleteNotification(Long userId, Long notificationId);

    /**
     * 批量删除通知
     *
     * @param userId 用户ID
     * @param notificationIds 通知ID列表
     * @return 影响的行数
     */
    int deleteNotificationsBatch(Long userId, List<Long> notificationIds);

    /**
     * 获取未读通知数量
     *
     * @param userId 用户ID
     * @return 未读通知数量
     */
    Long getUnreadCount(Long userId);

    /**
     * 获取用户发送的通知列表（分页）
     *
     * @param senderId 发送者ID
     * @param page 页码
     * @param size 每页大小
     * @param isRead 是否已读（null表示全部）
     * @return 通知列表
     */
    IPage<NotificationDTO> getSentNotifications(Long senderId, Integer page, Integer size, Integer isRead);

    /**
     * 获取发送者未读通知数量
     *
     * @param senderId 发送者ID
     * @return 未读通知数量
     */
    Long getSentUnreadCount(Long senderId);
}