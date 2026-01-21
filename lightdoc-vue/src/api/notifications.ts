import request from '@/utils/request'

/**
 * 通知DTO
 */
export interface NotificationDTO {
  id: number
  userId: number
  senderId?: number
  senderName?: string
  type: string
  title: string
  content?: string
  relatedType?: string
  relatedId?: number
  isRead: number
  createdAt: string
  updatedAt: string
}

/**
 * 创建通知DTO
 */
export interface CreateNotificationDTO {
  userId: number
  type: string
  title: string
  content?: string
  relatedType?: string
  relatedId?: number
}

/**
 * 通知API
 */
export const notificationApi = {
  /**
   * 创建通知
   */
  createNotification: (data: CreateNotificationDTO) => {
    return request.post<{
      code: number
      message: string
      data: number
    }>('/notifications', data)
  },

  /**
   * 批量创建通知
   */
  createNotificationsBatch: (data: CreateNotificationDTO[]) => {
    return request.post<{
      code: number
      message: string
      data: number
    }>('/notifications/batch', data)
  },

  /**
   * 获取用户通知列表（分页）
   */
  getUserNotifications: (params: {
    page?: number
    size?: number
    isRead?: number
  }) => {
    return request.get<{
      code: number
      message: string
      data: {
        records: NotificationDTO[]
        total: number
        size: number
        current: number
        pages: number
      }
    }>('/notifications', { params })
  },

  /**
   * 获取通知详情
   */
  getNotificationDetail: (notificationId: number) => {
    return request.get<{
      code: number
      message: string
      data: NotificationDTO
    }>(`/notifications/${notificationId}`)
  },

  /**
   * 标记通知为已读
   */
  markAsRead: (notificationId: number) => {
    return request.put<{
      code: number
      message: string
      data: boolean
    }>(`/notifications/${notificationId}/read`)
  },

  /**
   * 批量标记通知为已读
   */
  markAsReadBatch: (notificationIds: number[]) => {
    return request.put<{
      code: number
      message: string
      data: number
    }>('/notifications/batch/read', notificationIds)
  },

  /**
   * 标记所有通知为已读
   */
  markAllAsRead: () => {
    return request.put<{
      code: number
      message: string
      data: number
    }>('/notifications/all/read')
  },

  /**
   * 删除通知
   */
  deleteNotification: (notificationId: number) => {
    return request.delete<{
      code: number
      message: string
      data: boolean
    }>(`/notifications/${notificationId}`)
  },

  /**
   * 批量删除通知
   */
  deleteNotificationsBatch: (notificationIds: number[]) => {
    return request.delete<{
      code: number
      message: string
      data: number
    }>('/notifications/batch', { data: notificationIds })
  },

  /**
   * 获取未读通知数量
   */
  getUnreadCount: () => {
    return request.get<{
      code: number
      message: string
      data: number
    }>('/notifications/unread/count')
  },

  /**
   * 获取当前用户发送的通知列表（分页）
   */
  getSentNotifications: (params: {
    page?: number
    size?: number
    isRead?: number
  }) => {
    return request.get<{
      code: number
      message: string
      data: {
        records: NotificationDTO[]
        total: number
        size: number
        current: number
        pages: number
      }
    }>('/notifications/sent', { params })
  },

  /**
   * 获取当前用户发送的未读通知数量
   */
  getSentUnreadCount: () => {
    return request.get<{
      code: number
      message: string
      data: number
    }>('/notifications/sent/unread/count')
  }
}