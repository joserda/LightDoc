<template>
  <div class="my-documents-page">
    <div class="page-header">
      <h2>{{ pageTitle }}</h2>
      <div class="page-actions">
        <a-button v-if="showCreateButton" type="default" @click="showCreateModal = true">
          <template #icon><PlusOutlined /></template>
          创建文档
        </a-button>
        <a-button v-if="showImportButton" type="default" @click="triggerImportJson">
          导入 JSON
        </a-button>
      </div>
    </div>

    <!-- 文档列表 -->
    <div class="document-list-container">
      <a-list
        :data-source="documents"
        :loading="loading"
        :pagination="paginationConfig"
        class="document-list"
      >
        <template #renderItem="{ item }">
          <a-list-item>
            <a-list-item-meta>
              <template #title>
                <a @click="openDocument(item)">{{ item.title }}</a>
              </template>
              <template #description>
                {{ item.summary || '暂无描述' }}
              </template>
              <template #avatar>
                <FileTextOutlined style="font-size: 24px; color: #1890ff;" />
              </template>
            </a-list-item-meta>
            <template #actions>
              <template v-if="isTrashView">
                <a-tooltip title="恢复">
                  <a-button type="text" @click="restoreDocument(item)">
                    恢复
                  </a-button>
                </a-tooltip>
                <a-tooltip title="彻底删除">
                  <a-button type="text" danger @click="deleteDocumentPermanently(item)">
                    彻底删除
                  </a-button>
                </a-tooltip>
              </template>
              <template v-else-if="isSharedView">
                <a-tooltip title="打开">
                  <a-button type="text" @click="openDocument(item)">
                    <EditOutlined />
                  </a-button>
                </a-tooltip>
              </template>
              <template v-else>
                <a-tooltip title="编辑文档信息">
                  <a-button type="text" @click="openEditModal(item)">
                    <EditOutlined />
                  </a-button>
                </a-tooltip>
                <a-tooltip title="下载JSON">
                  <a-button type="text" @click="downloadDocument(item)">
                    <DownloadOutlined />
                  </a-button>
                </a-tooltip>
                <a-tooltip title="更多">
                  <a-dropdown>
                    <a-button type="text">
                      <EllipsisOutlined />
                    </a-button>
                    <template #overlay>
                      <a-menu>
                        <a-menu-item @click="copyLink(item)">复制链接</a-menu-item>
                        <a-menu-item @click="shareDocument(item)">分享</a-menu-item>
                        <a-menu-divider />
                        <a-menu-item danger @click="deleteDocument(item)">删除</a-menu-item>
                      </a-menu>
                    </template>
                  </a-dropdown>
                </a-tooltip>
              </template>
            </template>
            <div class="document-meta">
              <span>{{ formatDate(item.createdAt) }}</span>
              <span>{{ item.wordCount || 0 }} 字</span>
              <span>{{ formatFileSize(item.fileSize) }}</span>
            </div>
          </a-list-item>
        </template>
      </a-list>
    </div>

    <a-modal
      v-model:open="showCreateModal"
      title="创建新文档"
      @ok="handleCreateDocument"
      :confirm-loading="creating"
    >
      <a-form :model="newDocument" layout="vertical">
        <a-form-item label="文档标题">
          <a-input
            v-model:value="newDocument.title"
            placeholder="请输入文档标题"
            :maxlength="100"
            show-count
          />
        </a-form-item>
        <a-form-item label="所属知识库">
          <a-select
            v-model:value="newDocument.knowledgeBaseId"
            placeholder="选择知识库（可选）"
            allowClear
          >
            <a-select-option
              v-for="kb in knowledgeBases"
              :key="kb.id"
              :value="kb.id"
            >
              {{ kb.name }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="标签">
          <a-input
            v-model:value="newDocument.tags"
            placeholder="输入标签，用逗号分隔（可选）"
          />
        </a-form-item>
      </a-form>
    </a-modal>
    <a-modal
      v-model:open="showEditModal"
      title="编辑文档信息"
      :confirm-loading="updating"
      @ok="handleUpdateDocument"
      @cancel="handleEditCancel"
    >
      <a-form :model="editDocument" layout="vertical">
        <a-form-item label="文档标题">
          <a-input
            v-model:value="editDocument.title"
            placeholder="请输入文档标题"
            :maxlength="100"
            show-count
          />
        </a-form-item>
        <a-form-item label="标签">
          <a-input
            v-model:value="editDocument.tags"
            placeholder="输入标签，用逗号分隔（可选）"
          />
        </a-form-item>
        <a-form-item label="摘要">
          <a-textarea
            v-model:value="editDocument.summary"
            placeholder="请输入文档摘要（可选）"
            :rows="4"
            :maxlength="500"
            show-count
          />
        </a-form-item>
      </a-form>
    </a-modal>
    <input
      ref="importInputRef"
      type="file"
      accept=".json,application/json"
      style="display: none"
      @change="handleImportFileChange"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { message } from 'ant-design-vue'
import { documentApi, type DocumentDTO } from '@/api/documents'
import { knowledgeBaseApi, type KnowledgeBase } from '@/api/knowledgeBase'
import { 
  PlusOutlined,
  FileTextOutlined,
  EditOutlined,
  DownloadOutlined,
  EllipsisOutlined
} from '@ant-design/icons-vue'

const router = useRouter()
const route = useRoute()

const documents = ref<DocumentDTO[]>([])
const loading = ref(false)
const creating = ref(false)
const updating = ref(false)

// 分页配置
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0
})

const paginationConfig = reactive({
  current: pagination.current,
  pageSize: pagination.pageSize,
  total: pagination.total,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共 ${total} 条`,
  onChange: (page: number, pageSize: number) => {
    pagination.current = page
    pagination.pageSize = pageSize
    loadDocuments()
  },
  onShowSizeChange: (current: number, size: number) => {
    pagination.current = current
    pagination.pageSize = size
    loadDocuments()
  }
})

const showCreateModal = ref(false)
const newDocument = reactive({
  title: '',
  knowledgeBaseId: undefined as number | undefined,
  tags: ''
})

const knowledgeBases = ref<KnowledgeBase[]>([])

const showEditModal = ref(false)
const editDocument = reactive({
  id: undefined as number | undefined,
  title: '',
  tags: '',
  summary: ''
})

const pageTitle = computed(() => {
  const name = route.name as string | undefined
  if (name === 'SharedDocuments') {
    return '共享给我的'
  }
  if (name === 'Trash') {
    return '回收站'
  }
  if (name === 'AllDocuments') {
    return '全部文档'
  }
  if (name === 'Favorites') {
    return '收藏'
  }
  return '我的文档'
})

const showCreateButton = computed(() => {
  const name = route.name as string | undefined
  return name === 'MyDocuments' || name === 'AllDocuments'
})

const showImportButton = computed(() => {
  const name = route.name as string | undefined
  return name === 'MyDocuments' || name === 'AllDocuments'
})

const isTrashView = computed(() => {
  const name = route.name as string | undefined
  return name === 'Trash'
})

const isSharedView = computed(() => {
  const name = route.name as string | undefined
  return name === 'SharedDocuments'
})

const importInputRef = ref<HTMLInputElement | null>(null)

onMounted(() => {
  loadKnowledgeBases()
  loadDocuments()
})

watch(
  () => route.name,
  () => {
    pagination.current = 1
    loadDocuments()
  }
)

const loadDocuments = async () => {
  loading.value = true
  try {
    let viewType: string | undefined
    const name = route.name as string | undefined
    if (name === 'MyDocuments') {
      viewType = 'MINE'
    } else if (name === 'SharedDocuments') {
      viewType = 'SHARED_WITH_ME'
    } else if (name === 'Trash') {
      viewType = 'TRASH'
    }

    const params = {
      page: pagination.current,
      size: pagination.pageSize,
      viewType
    }
    const response = await documentApi.queryDocuments(params)
    if (response.code === 200 && response.data) {
      documents.value = response.data.records
      pagination.total = response.data.total
      paginationConfig.total = response.data.total
    } else {
      message.error(response.message || '加载文档列表失败')
    }
  } catch (error) {
    console.error('加载文档列表失败:', error)
    message.error('加载文档列表失败')
  } finally {
    loading.value = false
  }
}

const triggerImportJson = () => {
  if (importInputRef.value) {
    importInputRef.value.value = ''
    importInputRef.value.click()
  }
}

const handleImportFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = async () => {
    try {
      const text = String(reader.result || '')
      const json = JSON.parse(text)
      const baseTitle = file.name.replace(/\.json$/i, '')
      const title = baseTitle || '导入文档'
      const params: Partial<DocumentDTO> = {
        title,
        proseMirrorJson: JSON.stringify(json)
      }
      const response = await documentApi.createDocument(params)
      if (response.code === 200 && response.data) {
        message.success('导入成功')
        loadDocuments()
        if (response.data.id) {
          router.push(`/document/${response.data.id}/edit`)
        }
      } else {
        message.error(response.message || '导入失败')
      }
    } catch (error) {
      console.error('导入文档失败:', error)
      message.error('JSON 文件格式不正确')
    } finally {
      if (importInputRef.value) {
        importInputRef.value.value = ''
      }
    }
  }
  reader.readAsText(file)
}

// 加载知识库列表
const loadKnowledgeBases = async () => {
  try {
    const params = {
      page: 1,
      size: 100 // 获取所有知识库
    }
    const response = await knowledgeBaseApi.queryKnowledgeBases(params)
    if (response.code === 200 && response.data) {
      knowledgeBases.value = response.data.records
    } else {
      message.error(response.message || '加载知识库失败')
    }
  } catch (error) {
    console.error('加载知识库失败:', error)
    message.error('加载知识库失败')
  }
}

// 处理创建文档
const handleCreateDocument = async () => {
  if (!newDocument.title.trim()) {
    message.error('请输入文档标题')
    return
  }

  creating.value = true
  try {
    const params = {
      title: newDocument.title,
      knowledgeBaseId: newDocument.knowledgeBaseId,
      tags: newDocument.tags
    }
    
    const response = await documentApi.createDocument(params)
    if (response.code === 200 && response.data) {
      message.success('文档创建成功')
      showCreateModal.value = false
      // 重置表单
      newDocument.title = ''
      newDocument.knowledgeBaseId = undefined
      newDocument.tags = ''
      
      // 重新加载文档列表
      loadDocuments()
      
      // 跳转到新创建的文档
      if (response.data.id) {
        router.push(`/document/${response.data.id}/edit`)
      }
    } else {
      message.error(response.message || '创建文档失败')
    }
  } catch (error) {
    console.error('创建文档失败:', error)
    message.error('创建文档失败')
  } finally {
    creating.value = false
  }
}

// 打开文档
const openDocument = (document: DocumentDTO) => {
  if (document.id) {
    router.push(`/document/${document.id}/edit`)
  }
}

const openEditModal = (doc: DocumentDTO) => {
  if (!doc.id) return

  editDocument.id = doc.id
  editDocument.title = doc.title || ''
  editDocument.tags = doc.tags || ''
  editDocument.summary = doc.summary || ''
  showEditModal.value = true
}

const handleUpdateDocument = async () => {
  if (!editDocument.id) return
  if (!editDocument.title.trim()) {
    message.error('请输入文档标题')
    return
  }

  updating.value = true
  try {
    const params: Partial<DocumentDTO> = {
      title: editDocument.title,
      tags: editDocument.tags,
      summary: editDocument.summary
    }
    const response = await documentApi.updateDocument(editDocument.id, params)
    if (response.code === 200) {
      message.success('文档信息已更新')
      showEditModal.value = false
      loadDocuments()
    } else {
      message.error(response.message || '更新文档信息失败')
    }
  } catch (error) {
    console.error('更新文档信息失败:', error)
    message.error('更新文档信息失败')
  } finally {
    updating.value = false
  }
}

const handleEditCancel = () => {
  showEditModal.value = false
}

// 下载文档JSON
const downloadDocument = async (doc: DocumentDTO) => {
  if (!doc.id) return

  try {
    const blob = await documentApi.downloadDocumentJson(doc.id)
    const url = window.URL.createObjectURL(blob as Blob)
    const link = window.document.createElement('a')
    link.href = url
    link.download = `${doc.title || 'document'}.json`
    window.document.body.appendChild(link)
    link.click()
    window.document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    message.success('开始下载')
  } catch (error) {
    console.error('下载失败:', error)
    message.error('下载失败')
  }
}

// 复制链接
const copyLink = (document: DocumentDTO) => {
  if (document.id) {
    const link = `${window.location.origin}/document/${document.id}/edit`
    navigator.clipboard.writeText(link)
      .then(() => {
        message.success('链接已复制到剪贴板')
      })
      .catch(() => {
        message.error('复制链接失败')
      })
  }
}

// 分享文档
const shareDocument = (_document: DocumentDTO) => {
  message.info('分享功能开发中')
  // 这里可以打开分享模态框
}

const restoreDocument = async (document: DocumentDTO) => {
  if (!document.id) return

  try {
    await documentApi.restoreDocument(document.id)
    message.success('文档已恢复')
    loadDocuments()
  } catch (error) {
    console.error('恢复文档失败:', error)
    message.error('恢复文档失败')
  }
}

const deleteDocumentPermanently = async (document: DocumentDTO) => {
  if (!document.id) return

  try {
    await documentApi.deleteDocumentPermanently(document.id)
    message.success('文档已彻底删除')
    loadDocuments()
  } catch (error) {
    console.error('彻底删除文档失败:', error)
    message.error('彻底删除文档失败')
  }
}

const deleteDocument = async (document: DocumentDTO) => {
  if (!document.id) return
  
  try {
    await documentApi.deleteDocument(document.id)
    message.success('文档删除成功')
    // 重新加载文档列表
    loadDocuments()
  } catch (error) {
    console.error('删除文档失败:', error)
    message.error('删除文档失败')
  }
}

// 日期格式化
const formatDate = (dateString?: string) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

// 文件大小格式化
const formatFileSize = (size?: number) => {
  if (size === undefined || size === null) return '-'
  
  if (size < 1024) {
    return size + ' B'
  } else if (size < 1024 * 1024) {
    return (size / 1024).toFixed(1) + ' KB'
  } else {
    return (size / (1024 * 1024)).toFixed(1) + ' MB'
  }
}
</script>

<style scoped>
.my-documents-page {
  padding: 24px;
  background: #fff;
  min-height: calc(100vh - 64px - 48px); /* 减去头部和底部高度 */
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
}

.page-actions {
  display: flex;
  gap: 12px;
}

.document-list-container {
  margin-top: 16px;
}

.document-meta {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: #999;
  text-align: right;
}

.document-list :deep(.ant-list-item) {
  padding: 16px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.document-list :deep(.ant-list-item-meta) {
  flex: 1;
}

.document-list :deep(.ant-list-item-action) {
  margin-left: auto;
}

.document-list :deep(.ant-list-item-meta-title) {
  margin-bottom: 4px;
}

.document-list :deep(.ant-list-item-meta-title a) {
  color: #1890ff;
  font-weight: 500;
  cursor: pointer;
}

.document-list :deep(.ant-list-item-meta-title a:hover) {
  color: #40a9ff;
}
</style>
