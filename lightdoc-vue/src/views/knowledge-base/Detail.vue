<template>
  <div class="knowledge-base-detail-container">
    <div class="detail-header">
      <div class="header-back">
        <a-button type="text" @click="goBack">
          <template #icon><ArrowLeftOutlined /></template>
        </a-button>
      </div>
      <div class="header-content">
        <h2>{{ knowledgeBase?.name || '加载中...' }}</h2>
        <p>{{ knowledgeBase?.description || '暂无描述' }}</p>
      </div>
      <div class="header-actions">
        <a-button @click="editKnowledgeBase">
          <template #icon><EditOutlined /></template>
          编辑
        </a-button>
        <a-dropdown>
          <a-button>
            <template #icon><EllipsisOutlined /></template>
          </a-button>
          <template #overlay>
            <a-menu>
              <a-menu-item @click="shareKnowledgeBase">
                <ShareAltOutlined /> 分享
              </a-menu-item>
              <a-menu-item @click="moveKnowledgeBase">
                <DragOutlined /> 移动
              </a-menu-item>
              <a-menu-divider />
              <a-menu-item danger @click="deleteKnowledgeBase">
                <DeleteOutlined /> 删除
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
      </div>
    </div>

    <div class="detail-content">
      <div class="content-tabs">
        <a-tabs default-active-key="documents">
          <a-tab-pane key="documents" tab="文档">
            <div class="tab-content-header">
              <a-button type="primary" @click="createDocument">
                <template #icon><PlusOutlined /></template>
                新建文档
              </a-button>
            </div>
            <a-list
              :data-source="documents"
              :loading="loadingDocuments"
              :pagination="false"
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
            <div v-if="documentPagination.total > 0" class="pagination-container" style="margin-top: 16px; text-align: right;">
              <a-pagination
                :current="documentPagination.current"
                :page-size="documentPagination.pageSize"
                :total="documentPagination.total"
                :show-size-changer="true"
                :show-quick-jumper="true"
                :show-total="(total: number) => `共 ${total} 条`"
                @change="handleDocumentPageChange"
                @showSizeChange="handleDocumentPageSizeChange"
              />
            </div>
          </a-tab-pane>
          <a-tab-pane key="sub-knowledge-bases" tab="子知识库">
            <div class="tab-content-header">
              <a-button type="primary" @click="createSubKnowledgeBase">
                <template #icon><PlusOutlined /></template>
                新建子知识库
              </a-button>
            </div>
            <a-empty v-if="subKnowledgeBases.length === 0" description="暂无子知识库" />
            <a-list
              v-else
              :data-source="subKnowledgeBases"
              :loading="loadingSubKnowledgeBases"
              class="sub-kb-list"
            >
              <template #renderItem="{ item }">
                <a-list-item>
                  <a-list-item-meta>
                    <template #title>
                      <a @click="openSubKnowledgeBase(item)">{{ item.name }}</a>
                    </template>
                    <template #description>
                      {{ item.description || '暂无描述' }}
                    </template>
                    <template #avatar>
                      <FolderOutlined style="font-size: 24px; color: #52c41a;" />
                    </template>
                  </a-list-item-meta>
                  <template #actions>
                    <a-button type="text" @click="openSubKnowledgeBase(item)">
                      <FolderOpenOutlined />
                    </a-button>
                    <a-dropdown>
                      <a-button type="text">
                        <EllipsisOutlined />
                      </a-button>
                      <template #overlay>
                        <a-menu>
                          <a-menu-item>编辑</a-menu-item>
                          <a-menu-item>移动</a-menu-item>
                          <a-menu-item danger>删除</a-menu-item>
                        </a-menu>
                      </template>
                    </a-dropdown>
                  </template>
                  <div class="kb-meta">
                    <span>{{ item.docCount || 0 }} 个文档</span>
                  </div>
                </a-list-item>
              </template>
            </a-list>
          </a-tab-pane>
          <a-tab-pane key="settings" tab="设置">
            <div class="settings-content">
              <a-form :model="settingsForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
                <a-form-item label="知识库名称">
                  <a-input v-model:value="settingsForm.name" />
                </a-form-item>
                <a-form-item label="描述">
                  <a-textarea v-model:value="settingsForm.description" :rows="4" />
                </a-form-item>
                <a-form-item label="权限设置">
                  <a-radio-group v-model:value="settingsForm.permissionLevel">
                    <a-radio :value="0">私有</a-radio>
                    <a-radio :value="1">团队可见</a-radio>
                    <a-radio :value="2">公开</a-radio>
                  </a-radio-group>
                </a-form-item>
                <a-form-item :wrapper-col="{ offset: 6 }">
                  <a-button type="primary" @click="saveSettings" :loading="savingSettings">
                    保存设置
                  </a-button>
                </a-form-item>
              </a-form>
            </div>
          </a-tab-pane>
        </a-tabs>
      </div>
    </div>

    <!-- 编辑知识库模态框 -->
    <a-modal
      v-model:open="showEditModal"
      title="编辑知识库"
      @ok="handleEdit"
      :confirm-loading="editingKnowledgeBase"
    >
      <a-form :model="editForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
        <a-form-item label="知识库名称">
          <a-input v-model:value="editForm.name" placeholder="请输入知识库名称" />
        </a-form-item>
        <a-form-item label="描述">
          <a-textarea v-model:value="editForm.description" placeholder="请输入知识库描述" :rows="4" />
        </a-form-item>
        <a-form-item label="权限设置">
          <a-radio-group v-model:value="editForm.permissionLevel">
            <a-radio :value="0">私有</a-radio>
            <a-radio :value="1">团队可见</a-radio>
            <a-radio :value="2">公开</a-radio>
          </a-radio-group>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { message } from 'ant-design-vue'
import { knowledgeBaseApi, type KnowledgeBase } from '@/api/knowledgeBase'
import { documentApi, type DocumentDTO } from '@/api/documents'
import { 
  ArrowLeftOutlined,
  EditOutlined,
  EllipsisOutlined,
  ShareAltOutlined,
  DragOutlined,
  DeleteOutlined,
  PlusOutlined,
  FileTextOutlined,
  FolderOutlined,
  FolderOpenOutlined
} from '@ant-design/icons-vue'

const router = useRouter()
const route = useRoute()

// 响应式数据
const knowledgeBase = ref<KnowledgeBase | null>(null)
const documents = ref<DocumentDTO[]>([])
const subKnowledgeBases = ref<KnowledgeBase[]>([])
const loadingDocuments = ref(false)
const loadingSubKnowledgeBases = ref(false)
const showEditModal = ref(false)
const editingKnowledgeBase = ref(false)
const savingSettings = ref(false)

// 分页相关
const documentPagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0
})

const handleDocumentPageChange = (page: number, pageSize: number) => {
  documentPagination.current = page
  documentPagination.pageSize = pageSize
  const kbId = Number(route.params.id)
  if (kbId) {
    loadDocuments(kbId)
  }
}

const handleDocumentPageSizeChange = (current: number, size: number) => {
  documentPagination.current = 1
  documentPagination.pageSize = size
  const kbId = Number(route.params.id)
  if (kbId) {
    loadDocuments(kbId)
  }
}

// 表单数据
const settingsForm = reactive({
  name: '',
  description: '',
  permissionLevel: 0
})

const editForm = reactive({
  name: '',
  description: '',
  permissionLevel: 0
})

// 初始化
onMounted(() => {
  const id = Number(route.params.id)
  if (id) {
    loadKnowledgeBase(id)
    loadDocuments(id)
    loadSubKnowledgeBases(id)
  }
})

// 加载知识库详情
const loadKnowledgeBase = async (id: number) => {
  try {
    const response = await knowledgeBaseApi.getKnowledgeBase(id)
    if (response.code === 200 && response.data) {
      knowledgeBase.value = response.data
      // 初始化设置表单
      settingsForm.name = response.data.name
      settingsForm.description = response.data.description || ''
      settingsForm.permissionLevel = response.data.permissionLevel || 0
    } else {
      message.error(response.message || '加载知识库失败')
    }
  } catch (error) {
    console.error('加载知识库失败:', error)
    message.error('加载知识库失败')
  }
}

// 加载文档列表
const loadDocuments = async (kbId: number) => {
  loadingDocuments.value = true
  try {
    const params = {
      page: documentPagination.current,
      size: documentPagination.pageSize,
      parentId: kbId // 假设通过parentId查询知识库下的文档
    }
    const response = await documentApi.queryDocuments(params)
    if (response.code === 200 && response.data) {
      documents.value = response.data.records
      documentPagination.total = response.data.total
    } else {
      message.error(response.message || '加载文档列表失败')
    }
  } catch (error) {
    console.error('加载文档列表失败:', error)
    message.error('加载文档列表失败')
  } finally {
    loadingDocuments.value = false
  }
}

// 加载子知识库
const loadSubKnowledgeBases = async (kbId: number) => {
  loadingSubKnowledgeBases.value = true
  try {
    const params = {
      parentId: kbId,
      page: 1,
      size: 100 // 获取所有子知识库
    }
    const response = await knowledgeBaseApi.queryKnowledgeBases(params)
    if (response.code === 200 && response.data) {
      subKnowledgeBases.value = response.data.records
    } else {
      message.error(response.message || '加载子知识库失败')
    }
  } catch (error) {
    console.error('加载子知识库失败:', error)
    message.error('加载子知识库失败')
  } finally {
    loadingSubKnowledgeBases.value = false
  }
}

// 返回上一页
const goBack = () => {
  router.go(-1)
}

// 编辑知识库
const editKnowledgeBase = () => {
  if (knowledgeBase.value) {
    editForm.name = knowledgeBase.value.name
    editForm.description = knowledgeBase.value.description || ''
    editForm.permissionLevel = knowledgeBase.value.permissionLevel || 0
    showEditModal.value = true
  }
}

// 保存编辑
const handleEdit = async () => {
  if (!knowledgeBase.value) return
  
  editingKnowledgeBase.value = true
  try {
    const response = await knowledgeBaseApi.updateKnowledgeBase(knowledgeBase.value.id!, {
      name: editForm.name,
      description: editForm.description,
      permissionLevel: editForm.permissionLevel
    })
    
    if (response.code === 200 && response.data) {
      knowledgeBase.value = response.data
      settingsForm.name = response.data.name
      settingsForm.description = response.data.description || ''
      settingsForm.permissionLevel = response.data.permissionLevel || 0
      message.success('知识库更新成功')
      showEditModal.value = false
    } else {
      message.error(response.message || '更新失败')
    }
  } catch (error) {
    console.error('更新知识库失败:', error)
    message.error('更新知识库失败')
  } finally {
    editingKnowledgeBase.value = false
  }
}

// 删除知识库
const deleteKnowledgeBase = async () => {
  try {
    await knowledgeBaseApi.deleteKnowledgeBase(knowledgeBase.value!.id!)
    message.success('知识库删除成功')
    router.push('/home/knowledge-bases')
  } catch (error) {
    console.error('删除知识库失败:', error)
    message.error('删除知识库失败')
  }
}

// 日期格式化
const formatDate = (dateString?: string) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

// 以下方法暂存，实际实现需要后端支持
const shareKnowledgeBase = () => {
  message.info('分享功能开发中')
}

const moveKnowledgeBase = () => {
  message.info('移动功能开发中')
}

const createDocument = () => {
  message.info('新建文档功能开发中')
}

const openDocument = (document: DocumentDTO) => {
  if (document.id) {
    router.push(`/document/${document.id}/edit`)
  }
}

const createSubKnowledgeBase = () => {
  message.info('新建子知识库功能开发中')
}

const openSubKnowledgeBase = (kb: KnowledgeBase) => {
  if (kb.id) {
    router.push(`/knowledge-base/${kb.id}`)
  }
}

const saveSettings = async () => {
  if (!knowledgeBase.value) return
  
  savingSettings.value = true
  try {
    const response = await knowledgeBaseApi.updateKnowledgeBase(knowledgeBase.value.id!, {
      name: settingsForm.name,
      description: settingsForm.description,
      permissionLevel: settingsForm.permissionLevel
    })
    
    if (response.code === 200 && response.data) {
      knowledgeBase.value = response.data
      message.success('设置保存成功')
    } else {
      message.error(response.message || '保存失败')
    }
  } catch (error) {
    console.error('保存设置失败:', error)
    message.error('保存设置失败')
  } finally {
    savingSettings.value = false
  }
}
</script>

<style scoped>
.knowledge-base-detail-container {
  padding: 24px;
  background: #fff;
  border-radius: 8px;
}

.detail-header {
  display: flex;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
}

.header-back {
  margin-right: 16px;
}

.header-content {
  flex: 1;
}

.header-content h2 {
  margin: 0 0 8px 0;
  font-size: 24px;
}

.header-content p {
  margin: 0;
  color: #666;
}

.header-actions {
  display: flex;
  gap: 8px;
}

.detail-content {
  background: #fafafa;
  border-radius: 8px;
  padding: 16px;
}

.tab-content-header {
  margin-bottom: 16px;
  display: flex;
  justify-content: flex-end;
}

.document-list, .sub-kb-list {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
}

.document-meta, .kb-meta {
  font-size: 12px;
  color: #999;
  text-align: right;
}

.settings-content {
  background: #fff;
  padding: 24px;
  border-radius: 8px;
}
</style>
