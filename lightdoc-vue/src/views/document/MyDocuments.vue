<template>
  <div class="my-documents-page">
    <!-- 页面标题和操作栏 -->
    <div class="page-header">
      <h2>我的文档</h2>
      <div class="page-actions">
        <a-button type="default" @click="showCreateModal = true">
          <template #icon><PlusOutlined /></template>
          创建文档
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
              <a-tooltip title="编辑">
                <a-button type="text" @click="openDocument(item)">
                  <EditOutlined />
                </a-button>
              </a-tooltip>
              <a-tooltip title="下载">
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
            <div class="document-meta">
              <span>{{ formatDate(item.createdAt) }}</span>
              <span>{{ item.wordCount || 0 }} 字</span>
              <span>{{ formatFileSize(item.fileSize) }}</span>
            </div>
          </a-list-item>
        </template>
      </a-list>
    </div>

    <!-- 创建文档模态框 -->
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
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

// 响应式数据
const documents = ref<DocumentDTO[]>([])
const loading = ref(false)
const creating = ref(false)

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

// 创建文档相关
const showCreateModal = ref(false)
const newDocument = reactive({
  title: '',
  knowledgeBaseId: undefined as number | undefined,
  tags: ''
})

// 知识库列表
const knowledgeBases = ref<KnowledgeBase[]>([])

// 初始化
onMounted(() => {
  loadKnowledgeBases()
  loadDocuments()
})

// 加载文档列表
const loadDocuments = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.current,
      size: pagination.pageSize,
      ownerId: undefined as number | undefined // 获取当前用户的文档
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

// 下载文档
const downloadDocument = async (document: DocumentDTO) => {
  if (document.id) {
    try {
      await documentApi.downloadDocument(document.id)
      message.success('开始下载')
    } catch (error) {
      console.error('下载失败:', error)
      message.error('下载失败')
    }
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

// 删除文档
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
