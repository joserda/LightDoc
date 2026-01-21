<template>
  <div class="send-notification-container">
    <a-card class="send-notification-card">
      <template #title>
        <span>发送通知</span>
      </template>

      <a-form
        :model="formState"
        :rules="rules"
        layout="vertical"
        @finish="handleSubmit"
      >
        <a-form-item label="通知类型" name="type">
          <a-select v-model:value="formState.type" placeholder="请选择通知类型" @change="handleTypeChange">
            <a-select-option value="system_notice">系统通知</a-select-option>
            <a-select-option value="doc_invite">文档邀请</a-select-option>
            <a-select-option value="kb_invite">知识库邀请</a-select-option>
            <a-select-option value="comment_mention">评论提及</a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="接收用户" name="userId">
          <a-input
            v-model:value="formState.userId"
            placeholder="请输入用户ID"
            type="number"
          />
          <template #extra>
            <span class="form-extra">提示：输入要接收通知的用户ID</span>
          </template>
        </a-form-item>

        <a-form-item
          v-if="formState.type === 'doc_invite'"
          label="文档ID"
          name="relatedId"
        >
          <a-input
            v-model:value="formState.relatedId"
            placeholder="请输入文档ID"
            type="number"
          />
        </a-form-item>

        <a-form-item
          v-if="formState.type === 'kb_invite'"
          label="知识库ID"
          name="relatedId"
        >
          <a-input
            v-model:value="formState.relatedId"
            placeholder="请输入知识库ID"
            type="number"
          />
        </a-form-item>

        <a-form-item
          v-if="formState.type === 'comment_mention'"
          label="评论ID"
          name="relatedId"
        >
          <a-input
            v-model:value="formState.relatedId"
            placeholder="请输入评论ID"
            type="number"
          />
        </a-form-item>

        <a-form-item label="通知标题" name="title">
          <a-input
            v-model:value="formState.title"
            placeholder="请输入通知标题"
            maxlength="200"
            show-count
          />
        </a-form-item>

        <a-form-item label="通知内容" name="content">
          <a-textarea
            v-model:value="formState.content"
            placeholder="请输入通知内容"
            :rows="4"
            maxlength="500"
            show-count
          />
        </a-form-item>

        <a-form-item>
          <a-space>
            <a-button type="primary" html-type="submit" :loading="submitting">
              发送通知
            </a-button>
            <a-button @click="handleReset">重置</a-button>
          </a-space>
        </a-form-item>
      </a-form>

      <a-divider />

      <div class="batch-send-section">
        <h3>批量发送通知</h3>
        <p class="section-desc">一次向多个用户发送相同的通知</p>

        <a-form
          :model="batchFormState"
          :rules="batchRules"
          layout="vertical"
          @finish="handleBatchSubmit"
        >
          <a-form-item label="通知类型" name="type">
            <a-select v-model:value="batchFormState.type" placeholder="请选择通知类型">
              <a-select-option value="system_notice">系统通知</a-select-option>
              <a-select-option value="doc_invite">文档邀请</a-select-option>
              <a-select-option value="kb_invite">知识库邀请</a-select-option>
              <a-select-option value="comment_mention">评论提及</a-select-option>
            </a-select>
          </a-form-item>

          <a-form-item label="接收用户ID列表" name="userIds">
            <a-textarea
              v-model:value="batchFormState.userIdsText"
              placeholder="请输入用户ID，多个ID用逗号分隔，如：1,2,3"
              :rows="3"
            />
            <template #extra>
              <span class="form-extra">提示：多个用户ID用英文逗号分隔</span>
            </template>
          </a-form-item>

          <a-form-item label="通知标题" name="title">
            <a-input
              v-model:value="batchFormState.title"
              placeholder="请输入通知标题"
              maxlength="200"
              show-count
            />
          </a-form-item>

          <a-form-item label="通知内容" name="content">
            <a-textarea
              v-model:value="batchFormState.content"
              placeholder="请输入通知内容"
              :rows="4"
              maxlength="500"
              show-count
            />
          </a-form-item>

          <a-form-item>
            <a-space>
              <a-button type="primary" html-type="submit" :loading="batchSubmitting">
                批量发送
              </a-button>
              <a-button @click="handleBatchReset">重置</a-button>
            </a-space>
          </a-form-item>
        </a-form>
      </div>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/zh-cn'
import { notificationApi, type CreateNotificationDTO } from '@/api/notifications'

// 配置dayjs
dayjs.extend(relativeTime)
dayjs.locale('zh-cn')

// 表单状态
const formState = reactive<CreateNotificationDTO>({
  userId: 0,
  type: '',
  title: '',
  content: '',
  relatedType: '',
  relatedId: undefined
})

// 批量发送表单状态
const batchFormState = reactive({
  type: '',
  userIdsText: '',
  title: '',
  content: ''
})

// 提交状态
const submitting = ref(false)
const batchSubmitting = ref(false)

// 表单验证规则
const rules = {
  userId: [{ required: true, message: '请输入用户ID', type: 'number' }],
  type: [{ required: true, message: '请选择通知类型' }],
  title: [{ required: true, message: '请输入通知标题', min: 1, max: 200 }],
  content: [{ required: true, message: '请输入通知内容', min: 1, max: 500 }]
}

// 批量发送表单验证规则
const batchRules = {
  type: [{ required: true, message: '请选择通知类型' }],
  userIdsText: [{ required: true, message: '请输入用户ID列表' }],
  title: [{ required: true, message: '请输入通知标题', min: 1, max: 200 }],
  content: [{ required: true, message: '请输入通知内容', min: 1, max: 500 }]
}

// 通知类型变化处理
const handleTypeChange = (value: string) => {
  // 根据类型设置relatedType
  switch (value) {
    case 'doc_invite':
      formState.relatedType = 'document'
      break
    case 'kb_invite':
      formState.relatedType = 'knowledge_base'
      break
    case 'comment_mention':
      formState.relatedType = 'comment'
      break
    default:
      formState.relatedType = 'system'
      break
  }
}

// 提交单个通知
const handleSubmit = async () => {
  submitting.value = true
  try {
    const response = await notificationApi.createNotification(formState)
    if (response.code === 200) {
      message.success('通知发送成功')
      handleReset()
    } else {
      message.error(response.message || '发送失败')
    }
  } catch (error) {
    console.error('发送通知失败:', error)
    message.error('发送通知失败')
  } finally {
    submitting.value = false
  }
}

// 提交批量通知
const handleBatchSubmit = async () => {
  batchSubmitting.value = true
  try {
    // 解析用户ID列表
    const userIds = batchFormState.userIdsText
      .split(',')
      .map(id => parseInt(id.trim()))
      .filter(id => !isNaN(id))

    if (userIds.length === 0) {
      message.error('请输入有效的用户ID')
      batchSubmitting.value = false
      return
    }

    // 构建批量通知DTO
    const dtos: CreateNotificationDTO[] = userIds.map(userId => {
      let relatedType = 'system'
      switch (batchFormState.type) {
        case 'doc_invite':
          relatedType = 'document'
          break
        case 'kb_invite':
          relatedType = 'knowledge_base'
          break
        case 'comment_mention':
          relatedType = 'comment'
          break
      }

      return {
        userId,
        type: batchFormState.type,
        title: batchFormState.title,
        content: batchFormState.content,
        relatedType,
        relatedId: undefined
      }
    })

    const response = await notificationApi.createNotificationsBatch(dtos)
    if (response.code === 200) {
      message.success(`成功发送 ${response.data} 条通知`)
      handleBatchReset()
    } else {
      message.error(response.message || '发送失败')
    }
  } catch (error) {
    console.error('批量发送通知失败:', error)
    message.error('批量发送通知失败')
  } finally {
    batchSubmitting.value = false
  }
}

// 重置表单
const handleReset = () => {
  formState.userId = 0
  formState.type = ''
  formState.title = ''
  formState.content = ''
  formState.relatedType = ''
  formState.relatedId = undefined
}

// 重置批量表单
const handleBatchReset = () => {
  batchFormState.type = ''
  batchFormState.userIdsText = ''
  batchFormState.title = ''
  batchFormState.content = ''
}
</script>

<style scoped>
.send-notification-container {
  padding: 0;
}

.send-notification-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  max-width: 800px;
  margin: 0 auto;
}

.form-extra {
  color: rgba(0, 0, 0, 0.45);
  font-size: 12px;
}

.batch-send-section {
  margin-top: 32px;
}

.batch-send-section h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
}

.section-desc {
  margin: 0 0 24px 0;
  color: rgba(0, 0, 0, 0.65);
  font-size: 14px;
}
</style>