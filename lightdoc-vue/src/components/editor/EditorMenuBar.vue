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

    <div class="menubar-group">
      <a-divider type="vertical" />
      <a-dropdown>
        <a-button type="text" size="small">
          <template #icon><FontColorsOutlined /></template>
          <span class="color-indicator" :style="{ backgroundColor: currentTextColor || '#666' }"></span>
        </a-button>
        <template #overlay>
          <a-menu @click="handleTextColorClick">
            <a-menu-item key="__default__">默认</a-menu-item>
            <a-menu-divider />
            <a-menu-item v-for="c in presetTextColors" :key="c.value">
              <span class="color-swatch" :style="{ backgroundColor: c.value }"></span>
              <span>{{ c.label }}</span>
            </a-menu-item>
            <a-menu-divider />
            <a-menu-item key="__custom__" class="custom-input-item">
              <div class="custom-input-row" @click.stop>
                <a-input
                  v-model:value="customTextColorInput"
                  size="small"
                  placeholder="#ff0000"
                  @click.stop
                  @keydown.enter.stop.prevent="confirmCustomTextColor"
                />
                <a-button type="text" size="small" @click.stop="confirmCustomTextColor">
                  <template #icon><CheckOutlined /></template>
                </a-button>
              </div>
            </a-menu-item>
          </a-menu>
        </template>
      </a-dropdown>

      <a-dropdown>
        <a-button type="text" size="small">
          <template #icon><FontSizeOutlined /></template>
          <span class="font-size-indicator">{{ currentFontSizeLabel }}</span>
        </a-button>
        <template #overlay>
          <a-menu @click="handleFontSizeClick">
            <a-menu-item key="__default__">默认</a-menu-item>
            <a-menu-divider />
            <a-menu-item v-for="s in presetFontSizes" :key="s.value">{{ s.label }}</a-menu-item>
            <a-menu-divider />
            <a-menu-item key="__custom__" class="custom-input-item">
              <div class="custom-input-row" @click.stop>
                <a-input
                  v-model:value="customFontSizeInput"
                  size="small"
                  placeholder="16px"
                  @click.stop
                  @keydown.enter.stop.prevent="confirmCustomFontSize"
                />
                <a-button type="text" size="small" @click.stop="confirmCustomFontSize">
                  <template #icon><CheckOutlined /></template>
                </a-button>
              </div>
            </a-menu-item>
          </a-menu>
        </template>
      </a-dropdown>

      <a-tooltip title="上标">
        <a-button
          type="text"
          size="small"
          :class="{ 'is-active': isEditorActive('superscript') }"
          @click="toggleSuperscript"
        >
          x²
        </a-button>
      </a-tooltip>

      <a-tooltip title="下标">
        <a-button
          type="text"
          size="small"
          :class="{ 'is-active': isEditorActive('subscript') }"
          @click="toggleSubscript"
        >
          x₂
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
          @click="insertCodeBlock"
        >
          <template #icon><CodeSandboxOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-dropdown>
        <a-button type="text" size="small">
          <span>{{ currentCodeThemeLabel }}</span>
        </a-button>
        <template #overlay>
          <a-menu @click="handleCodeThemeClick">
            <a-menu-item v-for="item in codeThemes" :key="item.value">
              {{ item.label }}
            </a-menu-item>
          </a-menu>
        </template>
      </a-dropdown>
      <a-dropdown>
        <a-button type="text" size="small">
          <span>{{ currentCodeLanguageLabel }}</span>
        </a-button>
        <template #overlay>
          <a-menu @click="handleCodeLanguageClick">
            <a-menu-item v-for="item in codeLanguages" :key="item.value">
              {{ item.label }}
            </a-menu-item>
          </a-menu>
        </template>
      </a-dropdown>
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

    <div class="menubar-group" v-if="isEditorActive('image')">
      <a-divider type="vertical" />
      <span class="image-size-label">图片宽度</span>
      <a-tooltip title="小图">
        <a-button 
          type="text" 
          size="small" 
          @click="setImageWidth('25%')"
        >
          S
        </a-button>
      </a-tooltip>
      <a-tooltip title="中图">
        <a-button 
          type="text" 
          size="small" 
          @click="setImageWidth('50%')"
        >
          M
        </a-button>
      </a-tooltip>
      <a-tooltip title="大图">
        <a-button 
          type="text" 
          size="small" 
          @click="setImageWidth('100%')"
        >
          L
        </a-button>
      </a-tooltip>
      <div class="image-size-slider">
        <span class="image-size-value">{{ imageWidthPercent }}%</span>
        <a-slider
          :min="10"
          :max="100"
          :step="5"
          :value="imageWidthPercent"
          @change="handleImageSliderChange"
          style="width: 120px;"
        />
      </div>
    </div>

    <a-modal
      v-model:open="showImageModal"
      title="插入图片"
      :confirm-loading="uploadingImage"
      @ok="handleImageConfirm"
      @cancel="handleImageCancel"
      destroyOnClose
    >
      <div class="image-upload-modal">
        <a-upload
          :before-upload="handleBeforeUpload"
          :max-count="1"
          :show-upload-list="false"
        >
          <a-button type="primary">选择本地图片</a-button>
        </a-upload>
        <div v-if="selectedImageFile" class="selected-file-name">
          已选择: {{ selectedImageFile.name }}
        </div>
        <div v-else class="selected-file-placeholder">
          暂未选择图片
        </div>
      </div>
    </a-modal>

    <a-modal
      v-model:open="showTableModal"
      title="插入表格"
      @ok="handleTableConfirm"
      @cancel="handleTableCancel"
      destroyOnClose
    >
      <a-form :model="tableForm" layout="vertical">
        <a-form-item label="行数">
          <a-input-number v-model:value="tableForm.rows" :min="1" :max="20" style="width: 100%" />
        </a-form-item>
        <a-form-item label="列数">
          <a-input-number v-model:value="tableForm.cols" :min="1" :max="20" style="width: 100%" />
        </a-form-item>
        <a-form-item label="包含表头">
          <a-switch v-model:checked="tableForm.withHeaderRow" />
        </a-form-item>
      </a-form>
    </a-modal>

  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import {
  UndoOutlined,
  RedoOutlined,
  BoldOutlined,
  ItalicOutlined,
  UnderlineOutlined,
  StrikethroughOutlined,
  CodeOutlined,
  FontColorsOutlined,
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
  CheckOutlined,
} from '@ant-design/icons-vue'
import { Editor } from '@tiptap/vue-3'
import { message } from 'ant-design-vue'
import { documentApi } from '@/api/documents'

interface Props {
  editor: Editor | null
  documentId: number | null
}

const props = withDefaults(defineProps<Props>(), {
  editor: null,
  documentId: null,
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

const presetTextColors = [
  { label: '黑色', value: '#000000' },
  { label: '红色', value: '#f5222d' },
  { label: '橙色', value: '#fa8c16' },
  { label: '绿色', value: '#52c41a' },
  { label: '蓝色', value: '#1677ff' },
  { label: '紫色', value: '#722ed1' },
]

const presetFontSizes = [
  { label: '12px', value: '12px' },
  { label: '14px', value: '14px' },
  { label: '16px', value: '16px' },
  { label: '18px', value: '18px' },
  { label: '24px', value: '24px' },
  { label: '32px', value: '32px' },
]

const codeThemes = [
  { label: '暗色', value: 'dark' },
  { label: '浅色', value: 'light' },
  { label: '边框', value: 'bordered' },
]

const codeLanguages = [
  { label: '自动', value: 'plaintext' },
  { label: 'JavaScript', value: 'javascript' },
  { label: 'TypeScript', value: 'typescript' },
  { label: 'Java', value: 'java' },
  { label: 'Python', value: 'python' },
  { label: 'JSON', value: 'json' },
  { label: 'HTML', value: 'html' },
  { label: 'CSS', value: 'css' },
  { label: 'Shell', value: 'bash' },
]

const customTextColorInput = ref('')
const customFontSizeInput = ref('')

const currentTextColor = computed(() => {
  if (!isEditorReady.value) return null
  try {
    const attrs = props.editor!.getAttributes('textStyle') as any
    return (attrs?.color as string | null | undefined) ?? null
  } catch {
    return null
  }
})

const currentFontSize = computed(() => {
  if (!isEditorReady.value) return null
  try {
    const attrs = props.editor!.getAttributes('textStyle') as any
    return (attrs?.fontSize as string | null | undefined) ?? null
  } catch {
    return null
  }
})

const currentFontSizeLabel = computed(() => {
  return currentFontSize.value || '字号'
})

const currentCodeBlockAttrs = computed(() => {
  if (!isEditorReady.value) {
    return {
      language: 'plaintext',
      theme: 'dark',
    }
  }
  try {
    const attrs = props.editor!.getAttributes('codeBlock') as any
    return {
      language: (attrs?.language as string) || 'plaintext',
      theme: (attrs?.theme as string) || 'dark',
    }
  } catch {
    return {
      language: 'plaintext',
      theme: 'dark',
    }
  }
})

const currentCodeThemeLabel = computed(() => {
  const currentTheme = currentCodeBlockAttrs.value.theme
  const found = codeThemes.find(item => item.value === currentTheme)
  return found ? found.label : '暗色'
})

const currentCodeLanguageLabel = computed(() => {
  const currentLanguage = currentCodeBlockAttrs.value.language
  const found = codeLanguages.find(item => item.value === currentLanguage)
  return found ? found.label : '自动'
})

const applyTextColor = (value: string | null) => {
  if (!isEditorReady.value) return
  ;(props.editor as any)?.chain().focus().setTextColor(value).run()
}

const applyFontSize = (value: string | null) => {
  if (!isEditorReady.value) return
  ;(props.editor as any)?.chain().focus().setFontSize(value).run()
}

const handleCodeThemeClick = ({ key }: any) => {
  if (!isEditorReady.value) {
    return
  }
  ;(props.editor as any)
    ?.chain()
    .focus()
    .updateAttributes('codeBlock', { theme: String(key) })
    .run()
}

const handleCodeLanguageClick = ({ key }: any) => {
  if (!isEditorReady.value) {
    return
  }
  ;(props.editor as any)
    ?.chain()
    .focus()
    .updateAttributes('codeBlock', { language: String(key) })
    .run()
}

const confirmCustomTextColor = () => {
  if (!isEditorReady.value) return
  const trimmed = customTextColorInput.value.trim()
  if (!trimmed) {
    applyTextColor(null)
    return
  }
  applyTextColor(trimmed)
}

const confirmCustomFontSize = () => {
  if (!isEditorReady.value) return
  const trimmed = customFontSizeInput.value.trim()
  if (!trimmed) {
    applyFontSize(null)
    return
  }
  applyFontSize(trimmed)
}

const handleTextColorClick = ({ key }: any) => {
  if (!isEditorReady.value) return
  if (key === '__default__') {
    applyTextColor(null)
    return
  }
  if (key === '__custom__') return
  applyTextColor(String(key))
}

const handleFontSizeClick = ({ key }: any) => {
  if (!isEditorReady.value) return
  if (key === '__default__') {
    applyFontSize(null)
    return
  }
  if (key === '__custom__') return
  applyFontSize(String(key))
}

const toggleSuperscript = () => {
  if (!isEditorReady.value) return
  ;(props.editor as any)?.chain().focus().toggleSuperscript().run()
}

const toggleSubscript = () => {
  if (!isEditorReady.value) return
  ;(props.editor as any)?.chain().focus().toggleSubscript().run()
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

const showImageModal = ref(false)
const uploadingImage = ref(false)
const selectedImageFile = ref<File | null>(null)

const showTableModal = ref(false)
const tableForm = ref({
  rows: 3,
  cols: 3,
  withHeaderRow: true,
})

const handleBeforeUpload = (file: File) => {
  selectedImageFile.value = file
  return false
}

const resetImageState = () => {
  uploadingImage.value = false
  selectedImageFile.value = null
}

const handleImageCancel = () => {
  showImageModal.value = false
  resetImageState()
}

const handleImageConfirm = async () => {
  if (!props.editor) {
    return
  }

  if (!selectedImageFile.value) {
    message.error('请选择要上传的图片')
    return
  }

  const docId = props.documentId
  if (!docId || docId <= 0) {
    message.error('文档ID无效，无法上传图片')
    return
  }

  try {
    uploadingImage.value = true
    const res = await documentApi.uploadDocumentImage(docId, selectedImageFile.value)
    if (!res || res.code !== 200 || !res.data || !res.data.url) {
      message.error(res?.message || '上传图片失败')
      return
    }
    props.editor.chain().focus().setImage({ src: res.data.url }).run()
    showImageModal.value = false
    resetImageState()
  } catch (error: any) {
    message.error(error?.message || '上传图片失败')
  } finally {
    uploadingImage.value = false
  }
}

const setImageWidth = (width: string) => {
  if (!isEditorReady.value) {
    return
  }
  props.editor?.chain().focus().updateAttributes('image', { width }).run()
}

const imageWidthPercent = computed(() => {
  if (!isEditorReady.value) {
    return 100
  }
  try {
    const attrs = props.editor!.getAttributes('image') as any
    const width = attrs?.width as string | undefined
    if (!width) return 100
    if (width.endsWith('%')) {
      const num = Number(width.slice(0, -1))
      if (Number.isFinite(num) && num > 0) {
        return Math.min(100, Math.max(10, Math.round(num)))
      }
    }
    return 100
  } catch {
    return 100
  }
})

const handleImageSliderChange = (value: number) => {
  if (!isEditorReady.value) {
    return
  }
  const safe = Math.min(100, Math.max(10, Math.round(value)))
  props.editor?.chain().focus().updateAttributes('image', { width: `${safe}%` }).run()
}

const normalizeHref = (input: string) => {
  const value = input.trim()
  if (!value) return ''
  if (value.startsWith('#')) return value
  if (value.startsWith('/')) return value
  if (/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(value)) return value
  return `https://${value}`
}

// 添加链接
const addLink = () => {
  if (!isEditorReady.value) {
    return
  }

  const { empty, from } = props.editor!.state.selection
  const previousUrl = (props.editor!.getAttributes('link') as any)?.href || ''
  const url = window.prompt('请输入链接地址:', previousUrl)
  
  if (url === null) {
    return
  }
  
  const normalized = normalizeHref(url)
  if (!normalized) {
    props.editor?.chain().focus().extendMarkRange('link').unsetLink().run()
  } else {
    const chain = props.editor!.chain().focus()
    if (empty) {
      chain
        .insertContent(normalized)
        .setTextSelection({ from, to: from + normalized.length })
        .setLink({ href: normalized })
        .setTextSelection(from + normalized.length)
        .run()
    } else {
      chain.extendMarkRange('link').setLink({ href: normalized }).run()
    }
  }
}

// 添加图片
const addImage = () => {
  if (!isEditorReady.value) {
    return
  }
  showImageModal.value = true
}

// 添加表格
const addTable = () => {
  if (!isEditorReady.value) {
    return
  }

  showTableModal.value = true
}

const insertCodeBlock = () => {
  if (!isEditorReady.value) {
    return
  }

  const chain = props.editor!.chain().focus()
  if (props.editor!.isActive('codeBlock')) {
    chain.toggleCodeBlock().run()
  } else {
    ;(chain as any).setCodeBlock().run()
  }
}

const handleTableCancel = () => {
  showTableModal.value = false
}

const handleTableConfirm = () => {
  if (!isEditorReady.value) {
    return
  }

  const rows = Number(tableForm.value.rows)
  const cols = Number(tableForm.value.cols)
  if (!Number.isFinite(rows) || !Number.isFinite(cols) || rows < 1 || cols < 1 || rows > 20 || cols > 20) {
    message.error('行数/列数不合法')
    return
  }

  props.editor?.chain().focus().insertTable({
    rows: Math.round(rows),
    cols: Math.round(cols),
    withHeaderRow: !!tableForm.value.withHeaderRow,
  }).run()
  showTableModal.value = false
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

.color-indicator {
  width: 12px;
  height: 12px;
  border-radius: 2px;
  border: 1px solid rgba(0, 0, 0, 0.15);
  display: inline-block;
}

.color-swatch {
  width: 12px;
  height: 12px;
  border-radius: 2px;
  border: 1px solid rgba(0, 0, 0, 0.15);
  display: inline-block;
  margin-right: 8px;
  vertical-align: middle;
}

.font-size-indicator {
  min-width: 32px;
  text-align: left;
}

.custom-input-item {
  cursor: default;
}

.custom-input-row {
  display: flex;
  align-items: center;
  gap: 4px;
}

.custom-input-row :deep(.ant-input) {
  width: 120px;
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
