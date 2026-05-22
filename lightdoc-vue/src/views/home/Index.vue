<template>
  <a-layout style="min-height: 100vh">
    <!-- 顶部导航栏 -->
    <a-layout-header class="header">
      <div class="logo">
        <h2>LightDoc</h2>
      </div>
      <div class="header-right">
        <a-space>
          <a-button type="text" @click="createNewDocument">
            <template #icon><PlusOutlined /></template>
            新建
          </a-button>
          <a-input-search
            placeholder="搜索文档..."
            style="width: 200px; margin-right: 16px;"
            v-model:value="searchText"
            @search="onSearch"
          />
          <a-dropdown>
            <div class="user-info">
              <a-avatar style="margin-right: 8px">
                <template #icon><UserOutlined /></template>
              </a-avatar>
              <span>{{ currentUser?.nickname || currentUser?.username }}</span>
            </div>
            <template #overlay>
              <a-menu>
                <a-menu-item @click="goToProfile">个人资料</a-menu-item>
                <a-menu-item @click="goToSettings">设置</a-menu-item>
                <a-menu-divider />
                <a-menu-item @click="handleLogout">退出登录</a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
        </a-space>
      </div>
    </a-layout-header>

    <a-layout>
      <!-- 侧边导航栏 -->
      <a-layout-sider 
        v-model:collapsed="collapsed" 
        collapsible 
        width="256px"
        class="sider"
      >
        <div class="sider-content">
          <a-menu
            v-model:selectedKeys="selectedKeys"
            mode="inline"
            @click="handleMenuClick"
          >
            <a-menu-item key="dashboard">
              <template #icon><AppstoreOutlined /></template>
              仪表板
            </a-menu-item>
            <a-menu-item key="all-documents">
              <template #icon><FileTextOutlined /></template>
              全部文档
            </a-menu-item>
            <a-menu-item key="my-documents">
              <template #icon><UserOutlined /></template>
              我的文档
            </a-menu-item>
            <a-menu-item key="shared-documents">
              <template #icon><ShareAltOutlined /></template>
              共享给我的
            </a-menu-item>
            <a-menu-item key="favorites">
              <template #icon><StarOutlined /></template>
              收藏
            </a-menu-item>
            <a-menu-item key="trash">
              <template #icon><DeleteOutlined /></template>
              回收站
            </a-menu-item>
          </a-menu>

          <!-- 知识库列表 -->
          <div class="knowledge-base-section">
            <div class="section-header">
              <span>知识库</span>
              <a-button type="text" size="small" @click="showCreateKnowledgeBaseModal = true">
                <template #icon><PlusOutlined /></template>
              </a-button>
            </div>
            <a-tree
              :tree-data="knowledgeBaseTree"
              :field-names="{ key: 'id', title: 'name', children: 'children' }"
              @select="handleKnowledgeBaseSelect"
              class="knowledge-base-tree"
            >
              <template #title="{ name }">
                <div class="knowledge-base-item">
                  <FolderOutlined style="margin-right: 8px;" />
                  <span>{{ name }}</span>
                </div>
              </template>
            </a-tree>
          </div>
        </div>
      </a-layout-sider>

      <!-- 主内容区 -->
      <a-layout-content class="content">
        <div class="content-wrapper">
          <!-- 面包屑导航 -->
          <div class="breadcrumb">
            <a-breadcrumb>
              <a-breadcrumb-item>首页</a-breadcrumb-item>
              <a-breadcrumb-item>{{ currentViewTitle }}</a-breadcrumb-item>
            </a-breadcrumb>
          </div>

          <!-- 主要内容 -->
          <div class="main-content">
            <div v-if="currentView === 'dashboard'" class="dashboard-view">
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
                    <a-card class="stat-card">
                      <div class="stat-content">
                        <div class="stat-icon">
                          <EditOutlined style="font-size: 28px; color: #fa8c16;" />
                        </div>
                        <div class="stat-info">
                          <div class="stat-number">{{ stats.recentEdits }}</div>
                          <div class="stat-label">近期编辑</div>
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
                        <a @click="goToAllDocuments">查看全部</a>
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
                      </div>
                    </a-card>
                    
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
            <div v-else-if="currentView === 'all-documents'" class="documents-view">
              <div class="view-header">
                <h3>全部文档</h3>
                <a-button type="primary" @click="createNewDocument">
                  <template #icon><PlusOutlined /></template>
                  新建文档
                </a-button>
              </div>
              <a-list
                :data-source="documents"
                :loading="loading"
                :pagination="false"
                class="document-list"
              >
                <template #renderItem="{ item }">
                  <a-list-item>
                    <a-list-item-meta>
                      <template #title>
                        <a @click="openDocument(item)">{{ item.title }}</a>
                      </template>
                      <!-- <template #description>
                        {{ item.summary || '暂无描述' }}
                      </template> -->
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
                      <a-tooltip title="分享">
                        <a-button type="text">
                          <ShareAltOutlined />
                        </a-button>
                      </a-tooltip>
                      <a-tooltip title="更多">
                        <a-dropdown>
                          <a-button type="text">
                            <EllipsisOutlined />
                          </a-button>
                          <template #overlay>
                            <a-menu>
                              <a-menu-item>复制链接</a-menu-item>
                              <a-menu-item>移动</a-menu-item>
                              <a-menu-item danger>删除</a-menu-item>
                            </a-menu>
                          </template>
                        </a-dropdown>
                      </a-tooltip>
                    </template>
                    <div class="document-meta">
                      <span>更新于 {{ formatDate(item.updatedAt) }}</span>
                      <span>{{ item.ownerNickname || item.username || '未知' }}</span>
                    </div>
                  </a-list-item>
                </template>
              </a-list>
              
              <!-- 独立的分页组件 -->
              <div v-if="pagination.total > 0" class="pagination-container" style="margin-top: 16px; text-align: right;">
                <a-pagination
                  :current="pagination.current"
                  :page-size="pagination.pageSize"
                  :total="pagination.total"
                  :show-size-changer="true"
                  :show-quick-jumper="true"
                  :show-total="(total: number) => `共 ${total} 条`"
                  @change="handlePageChange"
                  @showSizeChange="handlePageSizeChange"
                />
              </div>
            </div>
            <!-- 其他视图内容将根据需要添加 -->
            <div v-else class="empty-view">
              <a-empty :description="`请选择左侧导航项`" />
            </div>
          </div>
        </div>
      </a-layout-content>
    </a-layout>

    <!-- 新建知识库模态框 -->
    <a-modal
      v-model:open="showCreateKnowledgeBaseModal"
      title="新建知识库"
      @ok="handleCreateKnowledgeBase"
      :confirm-loading="creatingKnowledgeBase"
    >
      <a-form :model="newKnowledgeBase" layout="vertical">
        <a-form-item label="知识库名称">
          <a-input v-model:value="newKnowledgeBase.name" placeholder="请输入知识库名称" />
        </a-form-item>
        <a-form-item label="描述">
          <a-textarea v-model:value="newKnowledgeBase.description" placeholder="请输入知识库描述" />
        </a-form-item>
      </a-form>
    </a-modal>
  </a-layout>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { storage } from '@/utils/storage'
import { documentApi, type DocumentDTO } from '@/api/documents'
import { knowledgeBaseApi, type KnowledgeBase } from '@/api/knowledgeBase'
import { 
  AppstoreOutlined, 
  FileTextOutlined, 
  UserOutlined, 
  ShareAltOutlined, 
  StarOutlined, 
  DeleteOutlined, 
  PlusOutlined, 
  FolderOutlined,
  EditOutlined,
  EllipsisOutlined,
  FolderAddOutlined
} from '@ant-design/icons-vue'

const router = useRouter()

// 响应式数据
const collapsed = ref(false)
const selectedKeys = ref(['dashboard'])
const currentView = ref('dashboard')
const currentViewTitle = ref('仪表板')
const currentUser = ref(storage.getUser())
const searchText = ref('')
const showCreateKnowledgeBaseModal = ref(false)
const creatingKnowledgeBase = ref(false)
const loading = ref(false)

// 知识库相关
const knowledgeBaseTree = ref<KnowledgeBase[]>([])
const newKnowledgeBase = reactive({
  name: '',
  description: ''
})

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

// 文档相关
const documents = ref<DocumentDTO[]>([])
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0
})

const handlePageChange = (page: number, pageSize: number) => {
  pagination.current = page
  pagination.pageSize = pageSize
  loadDocuments()
}

const handlePageSizeChange = (current: number, size: number) => {
  pagination.current = 1
  pagination.pageSize = size
  loadDocuments()
}

// 初始化
onMounted(() => {
  loadUserInfo()
  loadKnowledgeBases()
  loadDocuments()
  loadDashboardData()
})

// 加载仪表盘数据
const loadDashboardData = async () => {
  // 加载统计数据
  loadStats()
  // 加载最近文档
  loadRecentDocuments()
  // 加载最近访问的知识库
  loadRecentKnowledgeBases()
}

// 加载统计数据
const loadStats = async () => {
  try {
    // 模拟统计数据加载，实际应用中应从API获取
    stats.totalDocuments = 12
    stats.totalKnowledgeBases = 5
    stats.sharedWithMe = 3
    stats.recentEdits = 8
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

// 加载最近文档
const loadRecentDocuments = async () => {
  loadingRecentDocs.value = true
  try {
    const params = {
      page: 1,
      size: 5, // 只获取最近的5个文档
      sortBy: 'updatedAt' // 按更新时间排序
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
      size: 5 // 只获取最近的5个知识库
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

// 加载用户信息
const loadUserInfo = () => {
  currentUser.value = storage.getUser()
}

// 加载知识库
const loadKnowledgeBases = async () => {
  try {
    const params = {
      page: 1,
      size: 100 // 获取所有知识库
    }
    const response = await knowledgeBaseApi.queryKnowledgeBases(params)
    if (response.code === 200 && response.data) {
      // 这里可能需要构建树形结构，取决于后端返回的数据格式
      // 暂时直接赋值，后续根据实际API返回格式调整
      knowledgeBaseTree.value = response.data.records
    } else {
      message.error(response.message || '加载知识库失败')
    }
  } catch (error) {
    console.error('加载知识库失败:', error)
    message.error('加载知识库失败')
  }
}

// 加载文档列表
const loadDocuments = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.current,
      size: pagination.pageSize,
      title: searchText.value || undefined
    }
    const response = await documentApi.queryDocuments(params)
    if (response.code === 200 && response.data) {
      documents.value = response.data.records
      pagination.total = response.data.total
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

// 菜单点击处理
const handleMenuClick = (item: { key: string }) => {
  selectedKeys.value = [item.key]
  currentView.value = item.key
  
  switch (item.key) {
    case 'dashboard':
      currentViewTitle.value = '仪表板'
      break
    case 'all-documents':
      currentViewTitle.value = '全部文档'
      break
    case 'my-documents':
      router.push('/my-documents')
      break
    case 'shared-documents':
      currentViewTitle.value = '共享给我的'
      break
    case 'favorites':
      currentViewTitle.value = '收藏'
      break
    case 'trash':
      currentViewTitle.value = '回收站'
      break
    default:
      currentViewTitle.value = '未知视图'
  }
}

// 知识库选择处理
const handleKnowledgeBaseSelect = (selectedKeys: any[], e: { selectedNodes: any[] }) => {
  if (selectedKeys.length > 0) {
    const selectedNode = e.selectedNodes[0]
    // 跳转到知识库详情页
    router.push(`/knowledge-base/${selectedNode.id}`)
  }
}

// 搜索处理
const onSearch = (value: string) => {
  console.log('搜索:', value)
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

// 创建知识库
const handleCreateKnowledgeBase = async () => {
  if (!newKnowledgeBase.name.trim()) {
    message.error('请输入知识库名称')
    return
  }
  
  creatingKnowledgeBase.value = true
  try {
    const response = await knowledgeBaseApi.createKnowledgeBase({
      name: newKnowledgeBase.name,
      description: newKnowledgeBase.description,
      parentId: null // 根级知识库
    })
    
    if (response.code === 200 && response.data) {
      // 刷新知识库列表
      await loadKnowledgeBases()
      message.success('知识库创建成功')
      showCreateKnowledgeBaseModal.value = false
      newKnowledgeBase.name = ''
      newKnowledgeBase.description = ''
    } else {
      message.error(response.message || '创建知识库失败')
    }
  } catch (error) {
    console.error('创建知识库失败:', error)
    message.error('创建知识库失败')
  } finally {
    creatingKnowledgeBase.value = false
  }
}

// 日期格式化
const formatDate = (dateString?: string) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

// 个人资料
const goToProfile = () => {
  message.info('个人资料功能开发中')
}

// 创建新知识库
const createNewKnowledgeBase = () => {
  showCreateKnowledgeBaseModal.value = true
  newKnowledgeBase.name = ''
  newKnowledgeBase.description = ''
}

// 打开知识库
const openKnowledgeBase = (kb: KnowledgeBase) => {
  if (kb.id) {
    router.push(`/knowledge-base/${kb.id}`)
  }
}

// 跳转到所有文档
const goToAllDocuments = () => {
  currentView.value = 'all-documents'
  currentViewTitle.value = '全部文档'
  selectedKeys.value = ['all-documents']
}

// 跳转到共享文档
const goToSharedDocuments = () => {
  currentView.value = 'shared-documents'
  currentViewTitle.value = '共享给我的'
  selectedKeys.value = ['shared-documents']
}

// 设置
const goToSettings = () => {
  message.info('设置功能开发中')
}

// 退出登录
const handleLogout = () => {
  storage.clear()
  router.push('/login')
}
</script>

<style scoped>
.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.logo h2 {
  margin: 0;
  color: #1890ff;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.user-info:hover {
  opacity: 0.8;
}

.sider {
  background: #fff;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
}

.sider-content {
  padding: 16px 0;
  height: 100%;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 16px;
  font-weight: 500;
  color: rgba(0, 0, 0, 0.88);
}

.knowledge-base-section {
  margin-top: 16px;
  border-top: 1px solid #f0f0f0;
}

.knowledge-base-item {
  display: flex;
  align-items: center;
}

.knowledge-base-tree {
  margin-top: 8px;
  padding: 0 8px;
}

.content {
  background: #f5f5f5;
}

.content-wrapper {
  padding: 24px;
  min-height: 100%;
}

.breadcrumb {
  margin-bottom: 24px;
}

.main-content {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
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

.dashboard-content {
  margin-top: 24px;
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

.documents-view .view-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.document-list {
  margin-top: 24px;
}

.document-meta {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: #999;
}

.empty-view {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 60vh;
}
</style>
