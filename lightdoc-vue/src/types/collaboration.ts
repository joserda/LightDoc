import * as Y from 'yjs'

// 协同编辑相关类型定义

export interface CollaborationUser {
  id: number
  username: string
  color: string
  avatar?: string
}

export interface Comment {
  id: number
  userId: number
  username: string
  content: string
  selectedText?: string
  position?: {
    from: number
    to: number
  }
  createdAt: string
  resolved: boolean
  replies?: Comment[]
}

export interface DocumentVersion {
  id: number
  documentId: number
  versionNumber: number
  versionType: 'full' | 'incremental' | 'major' | 'minor'
  snapshotPath: string
  snapshotSize: number
  changeDescription?: string
  createdBy: number
  createdByName: string
  createdAt: string
  isCurrent: boolean
  operationCount?: number
  duration?: number
}

export interface DocumentLock {
  userId: number
  username: string
  expiresAt: Date
  lockType: 'edit' | 'section'
}

export interface ShareSettings {
  accessLevel: 'private' | 'restricted' | 'public'
  allowComments: boolean
  allowDownload: boolean
  allowPrint: boolean
  expiryTime: 'never' | '1day' | '7days' | '30days' | 'custom'
  password: string
  allowEmbed: boolean
}

export interface UserPermission {
  userId: number
  username: string
  email: string
  permissionLevel: 'read' | 'write' | 'admin'
  grantedBy: string
  grantedAt: string
}

export interface ShareStats {
  viewCount: number
  commentCount: number
  downloadCount: number
  shareCount: number
}

export interface CollaborationMessage {
  type: string
  userId: number
  documentId: number
  data: any
  timestamp: number
}

export interface YjsDocumentWrapper {
  ydoc: Y.Doc
  yText: Y.Text
  pendingUpdates: Uint8Array[]
  lock: any
}
