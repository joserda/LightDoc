package com.lightdoc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lightdoc.dto.CreateNotificationDTO;
import com.lightdoc.dto.NotificationDTO;
import com.lightdoc.entity.Notification;
import com.lightdoc.mapper.NotificationMapper;
import com.lightdoc.service.NotificationService;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 通知服务实现类
 */
@Service
public class NotificationServiceImpl extends ServiceImpl<NotificationMapper, Notification> implements NotificationService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createNotification(CreateNotificationDTO dto) {
        Notification notification = new Notification();
        BeanUtils.copyProperties(dto, notification);
        notification.setIsRead(0);
        // 从SecurityUtils获取当前用户ID作为发送者
        notification.setSenderId(com.lightdoc.utils.SecurityUtils.getCurrentUserId());
        save(notification);
        return notification.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int createNotificationsBatch(List<CreateNotificationDTO> dtos) {
        if (dtos == null || dtos.isEmpty()) {
            return 0;
        }

        List<Notification> notifications = dtos.stream().map(dto -> {
            Notification notification = new Notification();
            BeanUtils.copyProperties(dto, notification);
            notification.setIsRead(0);
            return notification;
        }).collect(Collectors.toList());

        saveBatch(notifications);
        return notifications.size();
    }

    @Override
    public IPage<NotificationDTO> getUserNotifications(Long userId, Integer page, Integer size, Integer isRead) {
        Page<Notification> pageParam = new Page<>(page, size);

        LambdaQueryWrapper<Notification> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Notification::getUserId, userId);

        if (isRead != null) {
            queryWrapper.eq(Notification::getIsRead, isRead);
        }

        queryWrapper.orderByDesc(Notification::getCreatedAt);

        IPage<Notification> notificationPage = page(pageParam, queryWrapper);

        // 转换为DTO
        Page<NotificationDTO> dtoPage = new Page<>(notificationPage.getCurrent(), notificationPage.getSize(), notificationPage.getTotal());
        List<NotificationDTO> dtoList = notificationPage.getRecords().stream().map(notification -> {
            NotificationDTO dto = new NotificationDTO();
            BeanUtils.copyProperties(notification, dto);
            return dto;
        }).collect(Collectors.toList());

        dtoPage.setRecords(dtoList);
        return dtoPage;
    }

    @Override
    public NotificationDTO getNotificationDetail(Long userId, Long notificationId) {
        Notification notification = getOne(new LambdaQueryWrapper<Notification>()
                .eq(Notification::getId, notificationId)
                .eq(Notification::getUserId, userId));

        if (notification == null) {
            return null;
        }

        NotificationDTO dto = new NotificationDTO();
        BeanUtils.copyProperties(notification, dto);
        return dto;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean markAsRead(Long userId, Long notificationId) {
        return update(new LambdaUpdateWrapper<Notification>()
                .eq(Notification::getId, notificationId)
                .eq(Notification::getUserId, userId)
                .set(Notification::getIsRead, 1));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int markAsReadBatch(Long userId, List<Long> notificationIds) {
        if (notificationIds == null || notificationIds.isEmpty()) {
            return 0;
        }
        return baseMapper.markAsReadBatch(userId, notificationIds);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int markAllAsRead(Long userId) {
        return update(new LambdaUpdateWrapper<Notification>()
                .eq(Notification::getUserId, userId)
                .eq(Notification::getIsRead, 0)
                .set(Notification::getIsRead, 1))
                ? 1 : 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteNotification(Long userId, Long notificationId) {
        return remove(new LambdaQueryWrapper<Notification>()
                .eq(Notification::getId, notificationId)
                .eq(Notification::getUserId, userId));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteNotificationsBatch(Long userId, List<Long> notificationIds) {
        if (notificationIds == null || notificationIds.isEmpty()) {
            return 0;
        }
        return remove(new LambdaQueryWrapper<Notification>()
                .eq(Notification::getUserId, userId)
                .in(Notification::getId, notificationIds))
                ? notificationIds.size() : 0;
    }

    @Override
    public Long getUnreadCount(Long userId) {
        return baseMapper.countUnreadByUserId(userId);
    }

    @Override
    public IPage<NotificationDTO> getSentNotifications(Long senderId, Integer page, Integer size, Integer isRead) {
        Page<Notification> pageParam = new Page<>(page, size);

        LambdaQueryWrapper<Notification> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Notification::getSenderId, senderId);

        if (isRead != null) {
            queryWrapper.eq(Notification::getIsRead, isRead);
        }

        queryWrapper.orderByDesc(Notification::getCreatedAt);

        IPage<Notification> notificationPage = page(pageParam, queryWrapper);

        // 转换为DTO
        Page<NotificationDTO> dtoPage = new Page<>(notificationPage.getCurrent(), notificationPage.getSize(), notificationPage.getTotal());
        List<NotificationDTO> dtoList = notificationPage.getRecords().stream().map(notification -> {
            NotificationDTO dto = new NotificationDTO();
            BeanUtils.copyProperties(notification, dto);
            // TODO: 可以在这里添加发送者昵称的查询
            return dto;
        }).collect(Collectors.toList());

        dtoPage.setRecords(dtoList);
        return dtoPage;
    }

    @Override
    public Long getSentUnreadCount(Long senderId) {
        return baseMapper.countSentUnreadBySenderId(senderId);
    }
}