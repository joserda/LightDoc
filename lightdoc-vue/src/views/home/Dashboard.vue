<template>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h2>工作台</h2>
      <p>欢迎使用 LightDoc 文档协同编辑平台</p>
    </div>

    <div class="dashboard-stats">
      <a-row :gutter="[16, 16]">
        <a-col :xs="24" :sm="12" :md="6">
          <a-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <FileTextOutlined style="font-size: 28px; color: #1890ff;" />
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ stats.totalDocuments }}</div>
                <div class="stat-label">我的文档</div>
              </div>
            </div>
          </a-card>
        </a-col>
        <a-col :xs="24" :sm="12" :md="6">
          <a-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <FolderOutlined style="font-size: 28px; color: #52c41a;" />
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ stats.totalKnowledgeBases }}</div>
                <div class="stat-label">知识库</div>
              </div>
            </div>
          </a-card>
        </a-col>
        <a-col :xs="24" :sm="12" :md="6">
          <a-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <ShareAltOutlined style="font-size: 28px; color: #722ed1;" />
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ stats.sharedWithMe }}</div>
                <div class="stat-label">共享给我</div>
              </div>
            </div>
          </a-card>
        </a-col>
        <a-col :xs="24" :sm="12" :md="6">
          <a-card class="stat-card" @click="goToNotifications" style="cursor: pointer;">
            <div class="stat-content">
              <div class="stat-icon">
                <BellOutlined style="font-size: 28px; color: #fa8c16;" />
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ unreadCount }}</div>
                <div class="stat-label">未读通知</div>
              </div>
            </div>
          </a-card>
        </a-col>
      </a-row>
    </div>

    <div class="dashboard-content">
      <a-row :gutter="[24, 24]">
        <a-col :lg="16">
          <a-card title="最近的文档" class="recent-docs-card">
            <template #extra>
              <router-link to="/home/my-documents">查看全部</router-link>
            </template>
            <a-list
              :data-source="recentDocuments"
              :pagination="false"
              :loading="loadingRecentDocs"
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
                      <FileTextOutlined style="font-size: 20px; color: #1890ff;" />
                    </template>
                  </a-list-item-meta>
                  <div class="doc-meta">
                    <span>{{ formatDate(item.updatedAt) }}</span>
                    <span>{{ item.ownerNickname || '未知' }}</span>
                  </div>
                </a-list-item>
              </template>
            </a-list>
          </a-card>
        </a-col>
        <a-col :lg="8">
          <a-card title="快捷操作" class="quick-actions-card">
            <div class="quick-actions">
                          <a-button 
                            type="primary" 
                            block 
                            size="large" 
                            @click="createNewDocument"
                            class="quick-action-btn"
                          >
                            <template #icon><PlusOutlined /></template>
                            新建文档
                          </a-button>
                          <a-button 
                            block 
                            size="large" 
                            @click="createNewKnowledgeBase"
                            class="quick-action-btn"
                          >
                            <template #icon><FolderAddOutlined /></template>
                            新建知识库
                          </a-button>
                          <a-button 
                            block 
                            size="large" 
                            @click="goToSharedDocuments"
                            class="quick-action-btn"
                          >
                            <template #icon><ShareAltOutlined /></template>
                            查看共享
                          </a-button>
                        </div>          </a-card>

          <a-card title="最近访问的知识库" class="recent-kb-card" style="margin-top: 24px;">
            <a-list
              :data-source="recentKnowledgeBases"
              :pagination="false"
              :loading="loadingRecentKBs"
            >
              <template #renderItem="{ item }">
                <a-list-item>
                  <a-list-item-meta>
                    <template #title>
                      <a @click="openKnowledgeBase(item)">{{ item.name }}</a>
                    </template>
                    <template #description>
                      {{ item.description || '暂无描述' }}
                    </template>
                    <template #avatar>
                      <FolderOutlined style="font-size: 20px; color: #52c41a;" />
                    </template>
                  </a-list-item-meta>
                  <div class="kb-meta">
                    <span>{{ item.docCount || 0 }} 个文档</span>
                  </div>
                </a-list-item>
              </template>
            </a-list>
          </a-card>
        </a-col>
      </a-row>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { documentApi, type DocumentDTO } from '@/api/documents'
import { knowledgeBaseApi, type KnowledgeBase } from '@/api/knowledgeBase'
import { notificationApi } from '@/api/notifications'
import {
  FileTextOutlined,
  FolderOutlined,
  ShareAltOutlined,
  PlusOutlined,
  FolderAddOutlined,
  BellOutlined
} from '@ant-design/icons-vue'

const router = useRouter()

// 统计数据
const stats = reactive({
  totalDocuments: 0,
  totalKnowledgeBases: 0,
  sharedWithMe: 0,
  recentEdits: 0
})

// 仪表盘相关数据
const loadingRecentDocs = ref(false)
const loadingRecentKBs = ref(false)
const recentDocuments = ref<DocumentDTO[]>([])
const recentKnowledgeBases = ref<KnowledgeBase[]>([])

// 未读通知数量
const unreadCount = ref(0)

// 初始化
onMounted(() => {
  loadDashboardData()
})

// 加载仪表盘数据
const loadDashboardData = async () => {
  loadStats()
  loadRecentDocuments()
  loadRecentKnowledgeBases()
  loadUnreadCount()
}

// 加载统计数据
const loadStats = async () => {
  try {
    stats.totalDocuments = 12
    stats.totalKnowledgeBases = 5
    stats.sharedWithMe = 3
    stats.recentEdits = 8
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

// 加载未读通知数量
const loadUnreadCount = async () => {
  try {
    const response = await notificationApi.getUnreadCount()
    if (response.code === 200) {
      unreadCount.value = response.data
    }
  } catch (error) {
    console.error('加载未读通知数量失败:', error)
  }
}

// 跳转到通知页面
const goToNotifications = () => {
  router.push('/home/notifications')
}

// 加载最近文档
const loadRecentDocuments = async () => {
  loadingRecentDocs.value = true
  try {
    const params = {
      page: 1,
      size: 5,
      sortBy: 'updatedAt'
    }
    const response = await documentApi.queryDocuments(params)
    if (response.code === 200 && response.data) {
      recentDocuments.value = response.data.records.slice(0, 5)
    } else {
      message.error(response.message || '加载最近文档失败')
    }
  } catch (error) {
    console.error('加载最近文档失败:', error)
    message.error('加载最近文档失败')
  } finally {
    loadingRecentDocs.value = false
  }
}

// 加载最近访问的知识库
const loadRecentKnowledgeBases = async () => {
  loadingRecentKBs.value = true
  try {
    const params = {
      page: 1,
      size: 5
    }
    const response = await knowledgeBaseApi.queryKnowledgeBases(params)
    if (response.code === 200 && response.data) {
      recentKnowledgeBases.value = response.data.records.slice(0, 5)
    } else {
      message.error(response.message || '加载知识库失败')
    }
  } catch (error) {
    console.error('加载知识库失败:', error)
    message.error('加载知识库失败')
  } finally {
    loadingRecentKBs.value = false
  }
}

// 创建新文档
const createNewDocument = () => {
  message.info('创建新文档功能开发中')
}

// 打开文档
const openDocument = (document: DocumentDTO) => {
  if (document.id) {
    router.push(`/document/${document.id}/edit`)
  }
}

// 创建新知识库
const createNewKnowledgeBase = () => {
  message.info('创建新知识库功能开发中')
}

// 打开知识库
const openKnowledgeBase = (kb: KnowledgeBase) => {
  if (kb.id) {
    router.push(`/home/knowledge-base/${kb.id}`)
  }
}

// 跳转到共享文档
const goToSharedDocuments = () => {
  router.push('/home/shared-documents')
}

// 日期格式化
const formatDate = (dateString?: string) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}
</script>

<style scoped>
.dashboard-container {
  padding: 0;
}

.dashboard-header {
  margin-bottom: 24px;
}

.dashboard-header h2 {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 600;
}

.dashboard-header p {
  margin: 0;
  color: #666;
  font-size: 14px;
}

.dashboard-stats {
  margin-bottom: 24px;
}

.stat-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-4px);
}

.stat-content {
  display: flex;
  align-items: center;
}

.stat-icon {
  margin-right: 16px;
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #666;
}

.recent-docs-card, .quick-actions-card, .recent-kb-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.quick-action-btn {
  margin-bottom: 0;
}

.doc-meta, .kb-meta {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  font-size: 12px;
  color: #999;
  text-align: right;
}
</style>
