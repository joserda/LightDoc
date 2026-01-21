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
            <a-menu-item key="notifications">
              <template #icon><BellOutlined /></template>
              我的通知
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
            <a-menu-item key="knowledge-bases">
              <template #icon><FolderOutlined /></template>
              知识库
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

          <!-- 子路由内容 -->
          <router-view />
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
import { useRouter, useRoute } from 'vue-router'
import { message } from 'ant-design-vue'
import { storage } from '@/utils/storage'
import { knowledgeBaseApi, type KnowledgeBase } from '@/api/knowledgeBase'
import {
  AppstoreOutlined,
  UserOutlined,
  ShareAltOutlined,
  StarOutlined,
  DeleteOutlined,
  PlusOutlined,
  FolderOutlined,
  BellOutlined
} from '@ant-design/icons-vue'

const router = useRouter()
const route = useRoute()

// 响应式数据
const collapsed = ref(false)
const selectedKeys = ref(['dashboard'])
const currentViewTitle = ref('仪表板')
const currentUser = ref(storage.getUser())
const searchText = ref('')
const showCreateKnowledgeBaseModal = ref(false)
const creatingKnowledgeBase = ref(false)

// 知识库相关
const knowledgeBaseTree = ref<KnowledgeBase[]>([])
const newKnowledgeBase = reactive({
  name: '',
  description: ''
})

// 初始化
onMounted(() => {
  loadUserInfo()
  loadKnowledgeBases()
  updateSelectedKeys()
})

// 更新选中菜单
const updateSelectedKeys = () => {
  const path = route.path
  if (path.includes('/my-documents')) {
    selectedKeys.value = ['my-documents']
    currentViewTitle.value = '我的文档'
  } else if (path.includes('/notifications')) {
    selectedKeys.value = ['notifications']
    currentViewTitle.value = '我的通知'
  } else if (path.includes('/knowledge-bases')) {
    selectedKeys.value = ['knowledge-bases']
    currentViewTitle.value = '知识库'
  } else {
    selectedKeys.value = ['dashboard']
    currentViewTitle.value = '仪表板'
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
      knowledgeBaseTree.value = response.data.records
    } else {
      message.error(response.message || '加载知识库失败')
    }
  } catch (error) {
    console.error('加载知识库失败:', error)
    message.error('加载知识库失败')
  }
}

// 菜单点击处理
const handleMenuClick = (item: { key: string }) => {
  selectedKeys.value = [item.key]

  switch (item.key) {
    case 'dashboard':
      currentViewTitle.value = '仪表板'
      router.push('/home/dashboard')
      break
    case 'notifications':
      currentViewTitle.value = '我的通知'
      router.push('/home/notifications')
      break
    case 'my-documents':
      currentViewTitle.value = '我的文档'
      router.push('/home/my-documents')
      break
    case 'shared-documents':
      currentViewTitle.value = '共享给我的'
      router.push('/home/shared-documents')
      break
    case 'favorites':
      currentViewTitle.value = '收藏'
      router.push('/home/favorites')
      break
    case 'trash':
      currentViewTitle.value = '回收站'
      router.push('/home/trash')
      break
    case 'knowledge-bases':
      currentViewTitle.value = '知识库'
      router.push('/home/knowledge-bases')
      break
    default:
      currentViewTitle.value = '未知视图'
  }
}

// 知识库选择处理
const handleKnowledgeBaseSelect = (selectedKeys: any[], e: { selectedNodes: any[] }) => {
  if (selectedKeys.length > 0) {
    const selectedNode = e.selectedNodes[0]
    router.push(`/home/knowledge-base/${selectedNode.id}`)
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

// 个人资料
const goToProfile = () => {
  message.info('个人资料功能开发中')
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
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  height: 64px;
  line-height: 64px;
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
  position: fixed;
  left: 0;
  top: 64px;
  bottom: 0;
  z-index: 999;
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
  margin-top: 64px;
  margin-left: 256px;
  background: #f5f5f5;
  transition: margin-left 0.2s;
}

.content-wrapper {
  padding: 24px;
  min-height: 100%;
}

:deep(.ant-layout-sider-collapsed) + .ant-layout-content {
  margin-left: 80px;
}

.breadcrumb {
  margin-bottom: 24px;
}
</style>
