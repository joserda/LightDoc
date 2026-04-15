﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿import request from '@/utils/request'
import type { ApiResponse } from '@/types'

/**
 * 邀请DTO
 */
export interface InviteDTO {
  userId: number
  permissionLevel: number
}

/**
 * 成员DTO
 */
export interface MemberDTO {
  userId: number
  username: string
  nickname: string
  avatar: string
  email?: string
  permissionLevel: number
  inviteTime: string
  joinedAt: string
  inviterNickname: string
}

/**
 * 邀请详情DTO
 */
export interface InviteDetailDTO {
  documentId: number
  userId: number
  documentTitle: string
  inviterId: number
  inviterNickname: string
  permissionLevel: number
  inviteTime: number
  status: string
}

/**
 * 文档邀请API
 */
export const documentInviteApi = {
  /**
   * 邀请用户加入文档
   */
  inviteUser: (documentId: number, data: InviteDTO) => {
    return request.post<ApiResponse<boolean>>(`/documents/${documentId}/invite`, data)
  },

  /**
   * 接受邀请
   */
  acceptInvite: (documentId: number) => {
    return request.put<ApiResponse<boolean>>(`/documents/${documentId}/invites/accept`)
  },

  /**
   * 拒绝邀请
   */
  rejectInvite: (documentId: number) => {
    return request.put<ApiResponse<boolean>>(`/documents/${documentId}/invites/reject`)
  },

  /**
   * 获取文档成员列表
   */
  getDocumentMembers: (documentId: number) => {
    return request.get<ApiResponse<MemberDTO[]>>(`/documents/${documentId}/members`)
  },

  /**
   * 获取文档当前在线用户ID列表
   */
  getDocumentOnlineUsers: (documentId: number) => {
    return request.get<ApiResponse<number[]>>(`/documents/${documentId}/online-users`)
  },

  /**
   * 移除成员
   */
  removeMember: (documentId: number, userId: number) => {
    return request.delete<ApiResponse<boolean>>(`/documents/${documentId}/members/${userId}`)
  },

  /**
   * 修改成员权限
   */
  updateMemberPermission: (documentId: number, userId: number, permissionLevel: number) => {
    return request.put<ApiResponse<boolean>>(`/documents/${documentId}/members/${userId}/permission`, null, {
      params: { permissionLevel }
    })
  },

  /**
   * 获取文档的待处理邀请列表
   */
  getDocumentInvites: (documentId: number) => {
    return request.get<ApiResponse<InviteDetailDTO[]>>(`/documents/${documentId}/invites`)
  },

  /**
   * 获取当前用户的待处理邀请列表
   */
  getUserInvites: () => {
    return request.get<ApiResponse<InviteDetailDTO[]>>('/documents/user/invites')
  }
}
