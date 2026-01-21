<template>
  <div class="editor-menubar">
    <!-- 第一组：文本格式 -->
    <div class="menubar-group">
      <a-tooltip title="撤销">
        <a-button 
          type="text" 
          size="small" 
          :disabled="!canEditorDo('undo')"
          @click="editor?.chain().focus().undo().run()"
        >
          <template #icon><UndoOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="重做">
        <a-button 
          type="text" 
          size="small" 
          :disabled="!canEditorDo('redo')"
          @click="editor?.chain().focus().redo().run()"
        >
          <template #icon><RedoOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-divider type="vertical" />
      <a-tooltip title="加粗 (Ctrl+B)">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('bold') }"
          @click="editor?.chain().focus().toggleBold().run()"
        >
          <template #icon><BoldOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="斜体 (Ctrl+I)">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('italic') }"
          @click="editor?.chain().focus().toggleItalic().run()"
        >
          <template #icon><ItalicOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="下划线 (Ctrl+U)">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('underline') }"
          @click="editor?.chain().focus().toggleUnderline().run()"
        >
          <template #icon><UnderlineOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="删除线">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('strike') }"
          @click="editor?.chain().focus().toggleStrike().run()"
        >
          <template #icon><StrikethroughOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="代码">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('code') }"
          @click="editor?.chain().focus().toggleCode().run()"
        >
          <template #icon><CodeOutlined /></template>
        </a-button>
      </a-tooltip>
    </div>

    <!-- 第二组：标题 -->
    <div class="menubar-group">
      <a-divider type="vertical" />
      <a-dropdown>
        <a-button type="text" size="small">
          <template #icon><FontSizeOutlined /></template>
          <span>{{ headingLevel || '段落' }}</span>
        </a-button>
        <template #overlay>
          <a-menu @click="handleHeadingClick">
            <a-menu-item key="0" :class="{ 'is-active': isEditorActive('paragraph') }">
              段落
            </a-menu-item>
            <a-menu-item key="1" :class="{ 'is-active': isEditorActive('heading', { level: 1 }) }">
              标题 1
            </a-menu-item>
            <a-menu-item key="2" :class="{ 'is-active': isEditorActive('heading', { level: 2 }) }">
              标题 2
            </a-menu-item>
            <a-menu-item key="3" :class="{ 'is-active': isEditorActive('heading', { level: 3 }) }">
              标题 3
            </a-menu-item>
            <a-menu-item key="4" :class="{ 'is-active': isEditorActive('heading', { level: 4 }) }">
              标题 4
            </a-menu-item>
            <a-menu-item key="5" :class="{ 'is-active': isEditorActive('heading', { level: 5 }) }">
              标题 5
            </a-menu-item>
            <a-menu-item key="6" :class="{ 'is-active': isEditorActive('heading', { level: 6 }) }">
              标题 6
            </a-menu-item>
          </a-menu>
        </template>
      </a-dropdown>
    </div>

    <!-- 第三组：列表 -->
    <div class="menubar-group">
      <a-divider type="vertical" />
      <a-tooltip title="无序列表">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('bulletList') }"
          @click="editor?.chain().focus().toggleBulletList().run()"
        >
          <template #icon><UnorderedListOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="有序列表">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('orderedList') }"
          @click="editor?.chain().focus().toggleOrderedList().run()"
        >
          <template #icon><OrderedListOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="引用">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('blockquote') }"
          @click="editor?.chain().focus().toggleBlockquote().run()"
        >
          <template #icon><MessageOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="代码块">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('codeBlock') }"
          @click="editor?.chain().focus().toggleCodeBlock().run()"
        >
          <template #icon><CodeSandboxOutlined /></template>
        </a-button>
      </a-tooltip>
    </div>

    <!-- 第四组：对齐 -->
    <div class="menubar-group">
      <a-divider type="vertical" />
      <a-tooltip title="左对齐">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('textAlign', 'left') }"
          @click="editor?.chain().focus().setTextAlign('left').run()"
        >
          <template #icon><AlignLeftOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="居中对齐">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('textAlign', 'center') }"
          @click="editor?.chain().focus().setTextAlign('center').run()"
        >
          <template #icon><AlignCenterOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="右对齐">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('textAlign', 'right') }"
          @click="editor?.chain().focus().setTextAlign('right').run()"
        >
          <template #icon><AlignRightOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="两端对齐">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('textAlign', 'justify') }"
          @click="editor?.chain().focus().setTextAlign('justify').run()"
        >
          <template #icon><ColumnWidthOutlined /></template>
        </a-button>
      </a-tooltip>
    </div>

    <!-- 第五组：插入 -->
    <div class="menubar-group">
      <a-divider type="vertical" />
      <a-tooltip title="插入链接">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('link') }"
          @click="addLink"
        >
          <template #icon><LinkOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="插入图片">
        <a-button 
          type="text" 
          size="small" 
          @click="addImage"
        >
          <template #icon><PictureOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="插入表格">
        <a-button 
          type="text" 
          size="small" 
          :class="{ 'is-active': isEditorActive('table') }"
          @click="addTable"
        >
          <template #icon><TableOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="水平线">
        <a-button 
          type="text" 
          size="small" 
          @click="editor?.chain().focus().setHorizontalRule().run()"
        >
          <template #icon><MinusOutlined /></template>
        </a-button>
      </a-tooltip>
    </div>

    <!-- 第六组：表格操作 -->
    <div class="menubar-group" v-if="isEditorActive('table')">
      <a-divider type="vertical" />
      <a-tooltip title="添加列">
        <a-button 
          type="text" 
          size="small" 
          @click="editor?.chain().focus().addColumnBefore().run()"
        >
          <template #icon><PlusOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="删除列">
        <a-button 
          type="text" 
          size="small" 
          @click="editor?.chain().focus().deleteColumn().run()"
        >
          <template #icon><MinusSquareOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="添加行">
        <a-button 
          type="text" 
          size="small" 
          @click="editor?.chain().focus().addRowBefore().run()"
        >
          <template #icon><LineOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="删除行">
        <a-button 
          type="text" 
          size="small" 
          @click="editor?.chain().focus().deleteRow().run()"
        >
          <template #icon><DeleteOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-tooltip title="删除表格">
        <a-button 
          type="text" 
          size="small" 
          @click="editor?.chain().focus().deleteTable().run()"
        >
          <template #icon><DeleteOutlined /></template>
        </a-button>
      </a-tooltip>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import {
  UndoOutlined,
  RedoOutlined,
  BoldOutlined,
  ItalicOutlined,
  UnderlineOutlined,
  StrikethroughOutlined,
  CodeOutlined,
  FontSizeOutlined,
  UnorderedListOutlined,
  OrderedListOutlined,
  MessageOutlined,
  CodeSandboxOutlined,
  AlignLeftOutlined,
  AlignCenterOutlined,
  AlignRightOutlined,
  ColumnWidthOutlined,
  LinkOutlined,
  PictureOutlined,
  TableOutlined,
  MinusOutlined,
  PlusOutlined,
  MinusSquareOutlined,
  LineOutlined,
  DeleteOutlined,
} from '@ant-design/icons-vue'
import { Editor } from '@tiptap/vue-3'

interface Props {
  editor: Editor | null
}

const props = withDefaults(defineProps<Props>(), {
  editor: null
})

// 检查编辑器是否完全初始化
const isEditorReady = computed(() => {
  return props.editor !== null && 
         typeof props.editor.isActive === 'function' && 
         typeof props.editor.can === 'function' &&
         typeof props.editor.chain === 'function'
})

// 计算当前标题级别
const headingLevel = computed(() => {
  if (!isEditorReady.value) return '段落'
  
  try {
    if (props.editor!.isActive('heading', { level: 1 })) return '标题 1'
    if (props.editor!.isActive('heading', { level: 2 })) return '标题 2'
    if (props.editor!.isActive('heading', { level: 3 })) return '标题 3'
    if (props.editor!.isActive('heading', { level: 4 })) return '标题 4'
    if (props.editor!.isActive('heading', { level: 5 })) return '标题 5'
    if (props.editor!.isActive('heading', { level: 6 })) return '标题 6'
  } catch (error) {
    console.error('获取标题级别失败:', error)
  }
  
  return '段落'
})

// 安全的 isActive 检查
const isEditorActive = (name: string, attributes?: any) => {
  if (!isEditorReady.value) {
    return false
  }
  try {
    return props.editor!.isActive(name, attributes)
  } catch (error) {
    return false
  }
}

// 安全的 can 检查
const canEditorDo = (name: 'undo' | 'redo') => {
  if (!isEditorReady.value) {
    return false
  }
  try {
    const chain = props.editor!.can().chain().focus()
    return name === 'undo' ? chain.undo().run() : chain.redo().run()
  } catch (error) {
    return false
  }
}

// 处理标题点击
const handleHeadingClick = ({ key }: any) => {
  const level = parseInt(key)
  
  if (level === 0) {
    props.editor?.chain().focus().setParagraph().run()
  } else {
    if (level >= 1 && level <= 6) {
      props.editor?.chain().focus().toggleHeading({ level: level as 1 | 2 | 3 | 4 | 5 | 6 }).run()
    }
  }
}

// 添加链接
const addLink = () => {
  const url = window.prompt('请输入链接地址:')
  
  if (url === null) {
    return
  }
  
  if (url === '') {
    props.editor?.chain().focus().unsetLink().run()
  } else {
    props.editor?.chain().focus().setLink({ href: url }).run()
  }
}

// 添加图片
const addImage = () => {
  const url = window.prompt('请输入图片地址:')
  
  if (url) {
    props.editor?.chain().focus().setImage({ src: url }).run()
  }
}

// 添加表格
const addTable = () => {
  props.editor?.chain().focus()
    .insertTable({ rows: 3, cols: 3, withHeaderRow: true })
    .run()
}
</script>

<style scoped>
.editor-menubar {
  display: flex;
  align-items: center;
  gap: 4px;
  flex-wrap: wrap;
  padding: 4px 8px;
  background: #fff;
  border-bottom: 1px solid #e8e8e8;
}

.menubar-group {
  display: flex;
  align-items: center;
  gap: 2px;
}

.editor-menubar .ant-btn {
  border: none;
  color: #666;
  transition: all 0.2s;
}

.editor-menubar .ant-btn:hover {
  color: #1890ff;
  background: #f0f0f0;
}

.editor-menubar .ant-btn.is-active {
  color: #1890ff;
  background: #e6f7ff;
}

.editor-menubar .ant-btn:disabled {
  color: #d9d9d9;
  cursor: not-allowed;
}

.editor-menubar .ant-btn:disabled:hover {
  color: #d9d9d9;
  background: transparent;
}

.editor-menubar .ant-divider-vertical {
  height: 20px;
  margin: 0 8px;
}

.editor-menubar .ant-dropdown {
  display: flex;
  align-items: center;
}

.editor-menubar .ant-dropdown .ant-btn {
  display: flex;
  align-items: center;
  gap: 4px;
}

/* 菜单项激活状态 */
:deep(.ant-menu-item.is-active) {
  background: #e6f7ff;
  color: #1890ff;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .editor-menubar {
    padding: 4px;
  }
  
  .menubar-group {
    gap: 0;
  }
  
  .editor-menubar .ant-btn {
    padding: 4px 8px;
  }
  
  .editor-menubar .ant-divider-vertical {
    margin: 0 4px;
  }
}
</style>
