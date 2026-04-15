import request from '@/utils/request'
import type { ApiResponse } from '@/types'

export interface DocumentDTO {
  id?: number
  title: string
  originalDocumentType?: string
  originalFilePath?: string
  fileSize?: number
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
  viewType?: string
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

export interface UploadImageResponse {
  url: string
  objectName: string
  name: string
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

  restoreDocument(documentId: number) {
    return request.post<ApiResponse<void>>(`/documents/${documentId}/restore`)
  },

  deleteDocumentPermanently(documentId: number) {
    return request.delete<ApiResponse<void>>(`/documents/${documentId}/permanent`)
  },

  downloadDocument(documentId: number) {
    return request.get(`/documents/${documentId}/download`, {
      responseType: 'blob'
    })
  },

  downloadDocumentJson(documentId: number) {
    return request.get<Blob>(`/documents/${documentId}/json-download`, {
      // 通过 responseType: 'blob' 获取原始二进制数据
      // 响应拦截器会返回 Blob 本身
      // AxiosRequestConfig 在这里的类型不影响实际运行
      responseType: 'blob' as any,
    } as any)
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

  uploadDocumentImage(documentId: number, file: File) {
    const formData = new FormData()
    formData.append('file', file)
    return request.post<ApiResponse<UploadImageResponse>>(
      `/documents/${documentId}/images`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      }
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

  getDocumentVersionSnapshot(documentId: number, versionNumber: number) {
    return request.get<ApiResponse<string>>(
      `/documents/${documentId}/versions/${versionNumber}/snapshot`
    )
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
