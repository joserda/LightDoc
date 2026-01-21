<template>
  <div class="knowledge-base-container">
    <div class="knowledge-base-header">
      <h2>知识库管理</h2>
      <a-button type="primary" @click="showCreateModal = true">
        <template #icon><PlusOutlined /></template>
        新建知识库
      </a-button>
    </div>

    <div class="knowledge-base-content">
      <a-tree
        v-if="knowledgeBases.length > 0"
        :tree-data="treeData"
        :field-names="{ key: 'id', title: 'name', children: 'children' }"
        :expanded-keys="expandedKeys"
        @expand="onExpand"
        @select="onSelect"
        class="knowledge-base-tree"
      >
        <template #title="node">
          <div class="tree-node">
            <div class="node-info">
              <FolderOutlined style="margin-right: 8px;" />
              <span class="node-title">{{ node.name }}</span>
              <span class="node-doc-count">({{ node.docCount || 0 }})</span>
            </div>
            <div class="node-actions">
              <a-dropdown>
                <a-button type="text" size="small">
                  <EllipsisOutlined />
                </a-button>
                <template #overlay>
                  <a-menu>
                    <a-menu-item @click="editKnowledgeBase(node)">
                      <EditOutlined /> 编辑
                    </a-menu-item>
                    <a-menu-item @click="addChildKnowledgeBase(node)">
                      <PlusOutlined /> 添加子知识库
                    </a-menu-item>
                    <a-menu-divider />
                    <a-menu-item danger @click="deleteKnowledgeBase(node.id)">
                      <DeleteOutlined /> 删除
                    </a-menu-item>
                  </a-menu>
                </template>
              </a-dropdown>
            </div>
          </div>
        </template>
      </a-tree>
      
      <a-empty v-else :description="'暂无知识库，点击右上角按钮创建'" />
    </div>

    <!-- 创建/编辑知识库模态框 -->
    <a-modal
      v-model:open="showCreateModal"
      :title="currentKnowledgeBase ? '编辑知识库' : '新建知识库'"
      @ok="handleSaveKnowledgeBase"
      :confirm-loading="savingKnowledgeBase"
    >
      <a-form :model="knowledgeBaseForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
        <a-form-item label="知识库名称" :rules="[{ required: true, message: '请输入知识库名称' }]">
          <a-input v-model:value="knowledgeBaseForm.name" placeholder="请输入知识库名称" />
        </a-form-item>
        <a-form-item label="描述">
          <a-textarea 
            v-model:value="knowledgeBaseForm.description" 
            placeholder="请输入知识库描述" 
            :rows="4"
          />
        </a-form-item>
        <a-form-item label="权限设置">
          <a-radio-group v-model:value="knowledgeBaseForm.permissionLevel">
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
import { ref, reactive, onMounted, computed } from 'vue'
import { message } from 'ant-design-vue'
import { knowledgeBaseApi, type KnowledgeBase } from '@/api/knowledgeBase'
import { 
  PlusOutlined, 
  FolderOutlined, 
  EllipsisOutlined, 
  EditOutlined, 
  DeleteOutlined 
} from '@ant-design/icons-vue'

// 响应式数据
const knowledgeBases = ref<KnowledgeBase[]>([])
const expandedKeys = ref<number[]>([])
const selectedKeys = ref<number[]>([])
const showCreateModal = ref(false)
const savingKnowledgeBase = ref(false)
const currentKnowledgeBase = ref<KnowledgeBase | null>(null)

// 知识库表单
const knowledgeBaseForm = reactive({
  name: '',
  description: '',
  permissionLevel: 0,
  parentId: null as number | null
})

// 计算属性：构建树形结构
const treeData = computed(() => {
  // 找到所有根级知识库（parentId 为 null 或不存在）
  const rootNodes = knowledgeBases.value.filter(kb => !kb.parentId)
  
  const buildTree = (nodes: KnowledgeBase[]): any[] => {
    return nodes.map(node => {
      const children = knowledgeBases.value.filter(kb => kb.parentId === node.id)
      return {
        ...node,
        children: children.length > 0 ? buildTree(children) : []
      }
    })
  }
  
  return buildTree(rootNodes)
})

// 初始化数据
onMounted(() => {
  loadKnowledgeBases()
})

// 加载知识库列表
const loadKnowledgeBases = async () => {
  try {
    const params = {
      page: 1,
      size: 1000 // 获取所有知识库
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

// 展开节点
const onExpand = (keys: any[]) => {
  expandedKeys.value = keys
}

// 选择节点
const onSelect = (keys: any[], info: any) => {
  selectedKeys.value = keys
  console.log('Selected node:', info.node)
}

// 编辑知识库
const editKnowledgeBase = (knowledgeBase: KnowledgeBase) => {
  currentKnowledgeBase.value = knowledgeBase
  knowledgeBaseForm.name = knowledgeBase.name
  knowledgeBaseForm.description = knowledgeBase.description || ''
  knowledgeBaseForm.permissionLevel = knowledgeBase.permissionLevel || 0
  knowledgeBaseForm.parentId = knowledgeBase.parentId || null
  showCreateModal.value = true
}

// 添加子知识库
const addChildKnowledgeBase = (parent: KnowledgeBase) => {
  currentKnowledgeBase.value = null
  knowledgeBaseForm.name = ''
  knowledgeBaseForm.description = ''
  knowledgeBaseForm.permissionLevel = 0
  knowledgeBaseForm.parentId = parent.id || null
  showCreateModal.value = true
}

// 保存知识库
const handleSaveKnowledgeBase = async () => {
  if (!knowledgeBaseForm.name.trim()) {
    message.error('请输入知识库名称')
    return
  }
  
  savingKnowledgeBase.value = true
  try {
    let response
    if (currentKnowledgeBase.value) {
      // 更新知识库
      response = await knowledgeBaseApi.updateKnowledgeBase(
        currentKnowledgeBase.value.id!, 
        {
          name: knowledgeBaseForm.name,
          description: knowledgeBaseForm.description,
          permissionLevel: knowledgeBaseForm.permissionLevel,
          parentId: knowledgeBaseForm.parentId
        }
      )
    } else {
      // 创建知识库
      response = await knowledgeBaseApi.createKnowledgeBase({
        name: knowledgeBaseForm.name,
        description: knowledgeBaseForm.description,
        permissionLevel: knowledgeBaseForm.permissionLevel,
        parentId: knowledgeBaseForm.parentId
      })
    }
    
    if (response.code === 200) {
      message.success(currentKnowledgeBase.value ? '知识库更新成功' : '知识库创建成功')
      showCreateModal.value = false
      await loadKnowledgeBases() // 重新加载数据
    } else {
      message.error(response.message || (currentKnowledgeBase.value ? '更新失败' : '创建失败'))
    }
  } catch (error) {
    console.error('保存知识库失败:', error)
    message.error(currentKnowledgeBase.value ? '更新知识库失败' : '创建知识库失败')
  } finally {
    savingKnowledgeBase.value = false
  }
}

// 删除知识库
const deleteKnowledgeBase = async (id: number) => {
  try {
    await knowledgeBaseApi.deleteKnowledgeBase(id)
    message.success('知识库删除成功')
    await loadKnowledgeBases() // 重新加载数据
  } catch (error) {
    console.error('删除知识库失败:', error)
    message.error('删除知识库失败')
  }
}
</script>

<style scoped>
.knowledge-base-container {
  padding: 24px;
  background: #fff;
  border-radius: 8px;
}

.knowledge-base-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.knowledge-base-content {
  background: #fafafa;
  padding: 16px;
  border-radius: 8px;
}

.knowledge-base-tree {
  background: #fff;
  padding: 16px;
  border-radius: 8px;
}

.tree-node {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding: 4px 0;
}

.node-info {
  display: flex;
  align-items: center;
  flex: 1;
}

.node-title {
  margin-right: 8px;
}

.node-doc-count {
  color: #999;
  font-size: 12px;
}

.node-actions {
  opacity: 0;
  transition: opacity 0.3s;
}

.tree-node:hover .node-actions {
  opacity: 1;
}
</style>
