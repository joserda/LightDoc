import request from '@/utils/request'
import type { ApiResponse } from '@/types'

export interface KnowledgeBase {
  id?: number
  name: string
  description?: string
  ownerId?: number
  parentId?: number | null
  status?: number
  permissionLevel?: number
  isPublic?: boolean
  docCount?: number
  createdAt?: string
  updatedAt?: string
  ownerNickname?: string
  children?: KnowledgeBase[] // 子知识库
}

export interface KnowledgeBaseQueryDTO {
  name?: string
  ownerId?: number
  parentId?: number | null
  status?: number
  isPublic?: boolean
  page?: number
  size?: number
}

export interface KnowledgeBasePage<T> {
  records: T[]
  total: number
  size: number
  current: number
  pages: number
}

export const knowledgeBaseApi = {
  // 创建知识库
  createKnowledgeBase(data: Omit<KnowledgeBase, 'id'>) {
    return request.post<ApiResponse<KnowledgeBase>>('/knowledge-bases', data)
  },

  // 获取知识库详情
  getKnowledgeBase(knowledgeBaseId: number) {
    return request.get<ApiResponse<KnowledgeBase>>(`/knowledge-bases/${knowledgeBaseId}`)
  },

  // 分页查询知识库列表
  queryKnowledgeBases(params?: KnowledgeBaseQueryDTO) {
    return request.get<ApiResponse<KnowledgeBasePage<KnowledgeBase>>>('/knowledge-bases', { params })
  },

  // 更新知识库信息
  updateKnowledgeBase(knowledgeBaseId: number, data: Partial<KnowledgeBase>) {
    return request.put<ApiResponse<KnowledgeBase>>(`/knowledge-bases/${knowledgeBaseId}`, data)
  },

  // 删除知识库
  deleteKnowledgeBase(knowledgeBaseId: number) {
    return request.delete<ApiResponse<void>>(`/knowledge-bases/${knowledgeBaseId}`)
  },

  // 移动知识库
  moveKnowledgeBase(knowledgeBaseId: number, parentId: number) {
    return request.put<ApiResponse<KnowledgeBase>>(`/knowledge-bases/${knowledgeBaseId}/move?parentId=${parentId}`)
  }
}
