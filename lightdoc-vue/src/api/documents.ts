import request from '@/utils/request'
import type { ApiResponse } from '@/types'

export interface DocumentDTO {
  id?: number
  title: string
  summary?: string
  ownerId?: number
  ownerNickname?: string
  createdAt?: string
  updatedAt?: string
  status?: number
  version?: number
  wordCount?: number
  tags?: string
  permissionLevel?: number
  isPublic?: boolean
  viewCount?: number
  favoriteCount?: number
  commentCount?: number
  username?: string
  proseMirrorJson?: string
  canView?: boolean
  canComment?: boolean
  canEdit?: boolean
  canSaveVersion?: boolean
  canLock?: boolean
  canManageMembers?: boolean
  canChangeVisibility?: boolean
  isOwner?: boolean
}

export interface DocumentSettingsDTO {
  versioningEnabled?: boolean
  maxVersionCount?: number
  autosaveEnabled?: boolean
  autosaveIntervalSeconds?: number
}

export interface DocumentVersionDTO {
  versionNumber: number
  versionType?: string
  snapshotSize?: number
  changeDescription?: string
  createdBy?: number
  creatorNickname?: string
  createdAt?: string
}

export interface DocumentSettingsDTO {
  versioningEnabled?: boolean
  maxVersionCount?: number
  autosaveEnabled?: boolean
  autosaveIntervalSeconds?: number
}

export interface DocumentQueryDTO {
  title?: string
  ownerId?: number
  status?: number
  isPublic?: boolean
  tags?: string
  page?: number
  size?: number
}

export interface DocumentPage<T> {
  records: T[]
  total: number
  size: number
  current: number
  pages: number
}

export interface DocumentResource {
  id?: number
  documentId: number
  resourceId: string
  resourcePath: string
  resourceName: string
  resourceType: string
  fileSize?: number
  uploadBy?: number
  uploadTime?: string
}

export const documentApi = {
  getDocumentDetail(documentId: number) {
    return request.get<ApiResponse<DocumentDTO>>(`/documents/${documentId}`)
  },

  queryDocuments(params?: DocumentQueryDTO) {
    return request.get<ApiResponse<DocumentPage<DocumentDTO>>>('/documents', { params })
  },

  createDocument(data: Partial<DocumentDTO>) {
    return request.post<ApiResponse<DocumentDTO>>('/documents', data)
  },

  updateDocument(documentId: number, data: Partial<DocumentDTO>) {
    return request.put<ApiResponse<DocumentDTO>>(`/documents/${documentId}`, data)
  },

  deleteDocument(documentId: number) {
    return request.delete<ApiResponse<void>>(`/documents/${documentId}`)
  },

  downloadDocument(documentId: number) {
    return request.get(`/documents/${documentId}/download`, {
      responseType: 'blob'
    })
  },

  updateDocumentJson(documentId: number, proseMirrorJson: string) {
    return request.put<ApiResponse<DocumentDTO>>(`/documents/${documentId}/json`, {
      proseMirrorJson,
    })
  },

  getDocumentSettings(documentId: number) {
    return request.get<ApiResponse<DocumentSettingsDTO>>(`/documents/${documentId}/settings`)
  },

  updateDocumentSettings(documentId: number, data: DocumentSettingsDTO) {
    return request.put<ApiResponse<DocumentSettingsDTO>>(
      `/documents/${documentId}/settings`,
      data
    )
  },

  /**
   * 保存文档的Yjs状态
   * @param documentId 文档ID
   * @param yjsState Yjs二进制状态的Base64编码
   */
  saveDocumentYjsState(documentId: number, yjsState: string) {
    return request.post<ApiResponse<boolean>>(`/documents/${documentId}/yjs-state`, {
      yjsState
    })
  },

  /**
   * 加载文档的Yjs状态
   * @param documentId 文档ID
   */
  loadDocumentYjsState(documentId: number) {
    return request.get<ApiResponse<string>>(`/documents/${documentId}/yjs-state`)
  },

  listDocumentVersions(documentId: number) {
    return request.get<ApiResponse<DocumentVersionDTO[]>>(`/documents/${documentId}/versions`)
  },

  createDocumentVersion(
    documentId: number,
    data: { yjsState: string; description?: string }
  ) {
    return request.post<ApiResponse<DocumentVersionDTO>>(
      `/documents/${documentId}/versions`,
      data
    )
  },

  rollbackDocumentToVersion(documentId: number, versionNumber: number) {
    return request.post<ApiResponse<boolean>>(
      `/documents/${documentId}/versions/${versionNumber}/rollback`,
      {}
    )
  },
}
