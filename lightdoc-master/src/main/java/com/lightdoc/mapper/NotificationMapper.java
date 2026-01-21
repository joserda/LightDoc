package com.lightdoc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lightdoc.entity.Notification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 通知Mapper接口
 */
@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {

    /**
     * 批量标记为已读
     *
     * @param userId 用户ID
     * @param notificationIds 通知ID列表
     * @return 影响行数
     */
    int markAsReadBatch(@Param("userId") Long userId, @Param("notificationIds") List<Long> notificationIds);

    /**
     * 统计未读通知数量
     *
     * @param userId 用户ID
     * @return 未读通知数量
     */
    Long countUnreadByUserId(@Param("userId") Long userId);

    /**
     * 统计发送者未读通知数量
     *
     * @param senderId 发送者ID
     * @return 未读通知数量
     */
    Long countSentUnreadBySenderId(@Param("senderId") Long senderId);
}