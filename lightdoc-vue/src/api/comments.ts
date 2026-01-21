import request from '@/utils/request'
import type { ApiResponse } from '@/types'

export interface CommentDTO {
  id?: number
  documentId: number
  userId?: number
  content: string
  parentId?: number
  positionInfo?: string
  status?: number
  createdAt?: string
  updatedAt?: string
  replies?: CommentDTO[]
}

export const commentApi = {
  getDocumentComments(documentId: number) {
    return request.get<ApiResponse<CommentDTO[]>>(`/comments/document/${documentId}`)
  },

  createComment(data: { documentId: number; content: string; positionInfo?: string }) {
    return request.post<ApiResponse<CommentDTO>>('/comments', data)
  },

  replyComment(
    commentId: number,
    data: { documentId: number; content: string; positionInfo?: string }
  ) {
    return request.post<ApiResponse<CommentDTO>>(`/comments/${commentId}/reply`, data)
  },

  updateComment(commentId: number, data: { content: string; positionInfo?: string }) {
    return request.put<ApiResponse<CommentDTO>>(`/comments/${commentId}`, data)
  },

  deleteComment(commentId: number) {
    return request.delete<ApiResponse<void>>(`/comments/${commentId}`)
  },
}

