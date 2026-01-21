<template>
  <div class="notifications-container">
    <a-card class="notifications-card">
      <template #title>
        <div class="card-title">
          <a-tabs v-model:activeKey="activeTab" @change="handleTabChange" class="notification-tabs">
            <a-tab-pane key="received" tab="我的通知">
              <a-tag :color="unreadCount > 0 ? 'red' : 'default'">
                {{ unreadCount > 0 ? `${unreadCount} 条未读` : '全部已读' }}
              </a-tag>
            </a-tab-pane>
            <a-tab-pane key="sent" tab="已发送">
              <a-tag :color="sentUnreadCount > 0 ? 'orange' : 'default'">
                {{ sentUnreadCount > 0 ? `${sentUnreadCount} 条未读` : '全部已读' }}
              </a-tag>
            </a-tab-pane>
          </a-tabs>
        </div>
      </template>

      <template #extra>
        <a-space>
          <a-button v-if="activeTab === 'received'" type="primary" @click="openSendModal">
            <template #icon><SendOutlined /></template>
            发送通知
          </a-button>
          <a-button @click="refreshCurrentTab" :loading="loading" title="刷新" type="text" size="large" style="padding: 4px 8px;">
            <template #icon><ReloadOutlined /></template>
          </a-button>
          <a-button v-if="activeTab === 'received' && selectedRowKeys.length > 0" type="link" @click="handleBatchMarkAsRead" :loading="batchMarking">
            标记选中为已读 ({{ selectedRowKeys.length }})
          </a-button>
          <a-button v-if="selectedRowKeys.length > 0" type="link" danger @click="handleBatchDelete" :loading="batchDeleting">
            删除选中 ({{ selectedRowKeys.length }})
          </a-button>
          <a-button v-if="activeTab === 'received' && unreadCount > 0" type="link" @click="handleMarkAllAsRead" :loading="markingAllAsRead">
            全部标为已读
          </a-button>
          <a-select v-model:value="filterType" style="width: 120px" @change="refreshCurrentTab">
            <a-select-option :value="undefined">全部</a-select-option>
            <a-select-option :value="0">未读</a-select-option>
            <a-select-option :value="1">已读</a-select-option>
          </a-select>
          <a-select v-model:value="filterNotificationType" style="width: 140px" @change="refreshCurrentTab" placeholder="通知类型">
            <a-select-option :value="undefined">全部类型</a-select-option>
            <a-select-option value="system_notice">系统通知</a-select-option>
            <a-select-option value="doc_invite">文档邀请</a-select-option>
            <a-select-option value="kb_invite">知识库邀请</a-select-option>
            <a-select-option value="comment_mention">评论提及</a-select-option>
          </a-select>
          <a-select v-model:value="sortBy" style="width: 120px" @change="refreshCurrentTab">
            <a-select-option value="createdAt">按时间</a-select-option>
            <a-select-option value="type">按类型</a-select-option>
          </a-select>
          <a-button type="text" size="small" @click="toggleSortOrder">
            <template #icon>
              <SortAscendingOutlined v-if="sortOrder === 'asc'" />
              <SortDescendingOutlined v-else />
            </template>
          </a-button>
        </a-space>
      </template>

      <a-list :data-source="currentNotifications" :loading="loading" class="notifications-list">
        <template #header>
          <div v-if="selectedRowKeys.length > 0" style="margin-bottom: 16px;">
            <a-alert :message="`已选择 ${selectedRowKeys.length} 条通知`" type="info" closable @close="selectedRowKeys = []">
              <template #action>
                <a-space>
                  <a-button size="small" @click="handleSelectAll">全选当前页</a-button>
                  <a-button size="small" @click="selectedRowKeys = []">取消选择</a-button>
                </a-space>
              </template>
            </a-alert>
          </div>
        </template>
        <template #renderItem="{ item }">
          <a-list-item :class="['notification-item', { unread: item.isRead === 0 }]" @click="handleNotificationClick(item)">
            <a-list-item-meta>
              <template #avatar>
                <div class="notification-icon">
                  <BellOutlined v-if="item.type === 'system_notice'" />
                  <FileTextOutlined v-else-if="item.type === 'doc_invite'" />
                  <FolderOutlined v-else-if="item.type === 'kb_invite'" />
                  <MessageOutlined v-else-if="item.type === 'comment_mention'" />
                  <BellOutlined v-else />
                </div>
              </template>
              <template #title>
                <div class="notification-title">
                  <span>{{ item.title }}</span>
                  <span class="notification-time">{{ formatTime(item.createdAt) }}</span>
                </div>
              </template>
              <template #description>
                <div class="notification-content">{{ item.content || '暂无内容' }}</div>
                <div class="notification-tags">
                  <!-- 已读/未读状态标签 -->
                  <a-tag :color="item.isRead === 0 ? 'orange' : 'green'" size="small">
                    {{ item.isRead === 0 ? '未读' : '已读' }}
                  </a-tag>
                  <!-- 消息类型标签 -->
                  <a-tag size="small">
                    {{ getNotificationTypeName(item.type) }}
                  </a-tag>
                </div>
                <div v-if="activeTab === 'sent' && item.senderName" class="notification-sender">
                  发送给: {{ item.senderName }}
                </div>
              </template>
            </a-list-item-meta>
            <template #actions>
              <a-space>
                <a-checkbox :checked="selectedRowKeys.includes(item.id)" @change="handleCheckboxChange(item.id, $event)" @click.stop />
                <!-- 文档邀请类型的通知显示接受/拒绝按钮 -->
                <template v-if="activeTab === 'received' && item.type === 'doc_invite' && item.isRead === 0">
                  <a-button type="link" size="small" @click.stop="handleAcceptInvite(item)">
                    <template #icon><CheckOutlined /></template>
                    接受
                  </a-button>
                  <a-button type="link" size="small" danger @click.stop="handleRejectInvite(item)">
                    <template #icon><CloseOutlined /></template>
                    拒绝
                  </a-button>
                </template>
                <!-- 其他通知类型显示标为已读按钮 -->
                <a-button v-else-if="activeTab === 'received' && item.isRead === 0" type="link" size="small" @click.stop="handleMarkAsRead(item.id)">标为已读</a-button>
                <a-popconfirm title="确定要删除这条通知吗？" @confirm="handleDelete(item.id)" @click.stop>
                  <a-button type="link" size="small" danger>删除</a-button>
                </a-popconfirm>
              </a-space>
            </template>
          </a-list-item>
        </template>
        <template #empty>
          <a-empty description="暂无通知" />
        </template>
      </a-list>
      
      <!-- 独立的分页组件 -->
      <div class="pagination-container">
        <a-pagination
          v-model:current="pagination.current"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          :show-size-changer="pagination.showSizeChanger"
          :show-quick-jumper="pagination.showQuickJumper"
          :show-total="pagination.showTotal"
          @change="handlePageChange"
        />
      </div>
    </a-card>

    <a-modal v-model:open="showSendModal" title="发送通知" :confirm-loading="sending" @ok="handleSendNotification" @cancel="resetSendForm" width="600px">
      <a-form :model="sendForm" :label-col="{ span: 5 }" :wrapper-col="{ span: 18 }">
        <a-form-item label="接收用户" required>
          <a-input v-model:value="sendForm.userId" placeholder="请输入接收通知的用户ID" :disabled="sendForm.isBatch" />
        </a-form-item>
        <a-form-item label="批量发送">
          <a-switch v-model:checked="sendForm.isBatch" />
          <span style="margin-left: 8px; color: #999;">开启后可发送给多个用户（用逗号分隔）</span>
        </a-form-item>
        <a-form-item v-if="sendForm.isBatch" label="用户ID列表" required>
          <a-textarea v-model:value="sendForm.userIds" placeholder="请输入多个用户ID，用逗号分隔，如：1,2,3" :rows="3" />
        </a-form-item>
        <a-form-item label="通知类型" required>
          <a-select v-model:value="sendForm.type" placeholder="请选择通知类型">
            <a-select-option value="system_notice"><BellOutlined /> 系统通知</a-select-option>
            <a-select-option value="doc_invite"><FileTextOutlined /> 文档邀请</a-select-option>
            <a-select-option value="kb_invite"><FolderOutlined /> 知识库邀请</a-select-option>
            <a-select-option value="comment_mention"><MessageOutlined /> 评论提及</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item v-if="sendForm.type === 'doc_invite'" label="文档ID" required>
          <a-input v-model:value="sendForm.relatedId" placeholder="请输入文档ID" />
        </a-form-item>
        <a-form-item v-if="sendForm.type === 'kb_invite'" label="知识库ID" required>
          <a-input v-model:value="sendForm.relatedId" placeholder="请输入知识库ID" />
        </a-form-item>
        <a-form-item v-if="sendForm.type === 'comment_mention'" label="评论ID" required>
          <a-input v-model:value="sendForm.relatedId" placeholder="请输入评论ID" />
        </a-form-item>
        <a-form-item label="通知标题" required>
          <a-input v-model:value="sendForm.title" placeholder="请输入通知标题" maxlength="100" show-count />
        </a-form-item>
        <a-form-item label="通知内容" required>
          <a-textarea v-model:value="sendForm.content" placeholder="请输入通知内容" :rows="4" maxlength="500" show-count />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted, computed } from 'vue'
import { message } from 'ant-design-vue'
import { notificationApi, type NotificationDTO, type CreateNotificationDTO } from '@/api/notifications'
import { documentInviteApi } from '@/api/documentInvites'
import { BellOutlined, FileTextOutlined, FolderOutlined, MessageOutlined, SendOutlined, ReloadOutlined, SortAscendingOutlined, SortDescendingOutlined, CheckOutlined, CloseOutlined } from '@ant-design/icons-vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/zh-cn'

dayjs.extend(relativeTime)
dayjs.locale('zh-cn')

const loading = ref(false)
const notifications = ref<NotificationDTO[]>([])
const sentNotifications = ref<NotificationDTO[]>([])
const unreadCount = ref(0)
const sentUnreadCount = ref(0)
const activeTab = ref<'received' | 'sent'>('received')
const filterType = ref<number | undefined>(undefined)
const filterNotificationType = ref<string | undefined>(undefined)
const sortBy = ref<'createdAt' | 'type'>('createdAt')
const sortOrder = ref<'desc' | 'asc'>('desc')
const markingAllAsRead = ref(false)
const selectedRowKeys = ref<number[]>([])
const batchMarking = ref(false)
const batchDeleting = ref(false)
const showSendModal = ref(false)
const sending = ref(false)
const sendForm = reactive({
  userId: '',
  userIds: '',
  isBatch: false,
  type: '',
  title: '',
  content: '',
  relatedId: ''
})

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共 ${total} 条`
})

// 计算属性：根据当前Tab显示对应的通知列表
const currentNotifications = computed(() => {
  return activeTab.value === 'received' ? notifications.value : sentNotifications.value
})

let refreshTimer: NodeJS.Timeout | null = null

onMounted(() => {
  loadNotifications()
  loadUnreadCount()
  refreshTimer = setInterval(() => {
    loadUnreadCount()
  }, 30000)
})

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
  }
})

const loadNotifications = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.current,
      size: pagination.pageSize,
      isRead: filterType.value
    }
    const response = await notificationApi.getUserNotifications(params)
    if (response.code === 200 && response.data) {
      let filteredNotifications = response.data.records
      if (filterNotificationType.value) {
        filteredNotifications = filteredNotifications.filter(n => n.type === filterNotificationType.value)
      }
      filteredNotifications.sort((a, b) => {
        let comparison = 0
        if (sortBy.value === 'createdAt') {
          const dateA = new Date(a.createdAt).getTime()
          const dateB = new Date(b.createdAt).getTime()
          comparison = sortOrder.value === 'asc' ? dateA - dateB : dateB - dateA
        } else if (sortBy.value === 'type') {
          comparison = sortOrder.value === 'asc' ? a.type.localeCompare(b.type) : b.type.localeCompare(a.type)
        }
        return comparison
      })
      notifications.value = filteredNotifications
      pagination.total = filterNotificationType.value ? filteredNotifications.length : response.data.total
    } else {
      message.error(response.message || '加载通知失败')
    }
  } catch (error) {
    console.error('加载通知失败:', error)
    message.error('加载通知失败')
  } finally {
    loading.value = false
  }
}

const loadUnreadCount = async () => {
  try {
    const response = await notificationApi.getUnreadCount()
    if (response.code === 200) {
      unreadCount.value = response.data
    }
  } catch (error) {
    console.error('加载未读数量失败:', error)
  }
}

const handleTabChange = (key: string) => {
  activeTab.value = key as 'received' | 'sent'
  selectedRowKeys.value = []
  pagination.current = 1
  pagination.total = 0
  if (key === 'received') {
    loadNotifications()
  } else {
    loadSentNotifications()
  }
}

const refreshCurrentTab = () => {
  if (activeTab.value === 'received') {
    loadNotifications()
  } else {
    loadSentNotifications()
  }
}

const loadSentNotifications = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.current,
      size: pagination.pageSize,
      isRead: filterType.value
    }
    const response = await notificationApi.getSentNotifications(params)
    if (response.code === 200 && response.data) {
      let filteredNotifications = response.data.records
      if (filterNotificationType.value) {
        filteredNotifications = filteredNotifications.filter(n => n.type === filterNotificationType.value)
      }
      filteredNotifications.sort((a, b) => {
        let comparison = 0
        if (sortBy.value === 'createdAt') {
          const dateA = new Date(a.createdAt).getTime()
          const dateB = new Date(b.createdAt).getTime()
          comparison = sortOrder.value === 'asc' ? dateA - dateB : dateB - dateA
        } else if (sortBy.value === 'type') {
          comparison = sortOrder.value === 'asc' ? a.type.localeCompare(b.type) : b.type.localeCompare(a.type)
        }
        return comparison
      })
      sentNotifications.value = filteredNotifications
      pagination.total = filterNotificationType.value ? filteredNotifications.length : response.data.total
      // 加载未读数量
      loadSentUnreadCount()
    } else {
      message.error(response.message || '加载发送通知失败')
    }
  } catch (error) {
    console.error('加载发送通知失败:', error)
    message.error('加载发送通知失败')
  } finally {
    loading.value = false
  }
}

const loadSentUnreadCount = async () => {
  try {
    const response = await notificationApi.getSentUnreadCount()
    if (response.code === 200) {
      sentUnreadCount.value = response.data
    }
  } catch (error) {
    console.error('加载发送通知未读数量失败:', error)
  }
}

const handlePageChange = (page: number, pageSize: number) => {
  pagination.current = page
  pagination.pageSize = pageSize
  refreshCurrentTab()
}

const handleSelectChange = (notificationId: number, checked: boolean) => {
  if (checked) {
    selectedRowKeys.value.push(notificationId)
  } else {
    const index = selectedRowKeys.value.indexOf(notificationId)
    if (index > -1) {
      selectedRowKeys.value.splice(index, 1)
    }
  }
}

const handleCheckboxChange = (notificationId: number, e: any) => {
  handleSelectChange(notificationId, Boolean(e?.target?.checked))
}

const handleSelectAll = () => {
  const currentPageIds = notifications.value.map(n => n.id)
  selectedRowKeys.value = [...new Set([...selectedRowKeys.value, ...currentPageIds])]
}

const toggleSortOrder = () => {
  sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  loadNotifications()
}

const handleBatchMarkAsRead = async () => {
  if (selectedRowKeys.value.length === 0) {
    message.warning('请先选择要标记的通知')
    return
  }
  batchMarking.value = true
  try {
    const response = await notificationApi.markAsReadBatch(selectedRowKeys.value)
    if (response.code === 200) {
      message.success(`成功标记 ${response.data} 条通知为已读`)
      selectedRowKeys.value = []
      loadNotifications()
      loadUnreadCount()
    } else {
      message.error(response.message || '批量标记失败')
    }
  } catch (error) {
    console.error('批量标记为已读失败:', error)
    message.error('批量标记为已读失败')
  } finally {
    batchMarking.value = false
  }
}

const handleBatchDelete = async () => {
  if (selectedRowKeys.value.length === 0) {
    message.warning('请先选择要删除的通知')
    return
  }
  batchDeleting.value = true
  try {
    const response = await notificationApi.deleteNotificationsBatch(selectedRowKeys.value)
    if (response.code === 200) {
      message.success(`成功删除 ${response.data} 条通知`)
      selectedRowKeys.value = []
      loadNotifications()
      loadUnreadCount()
    } else {
      message.error(response.message || '批量删除失败')
    }
  } catch (error) {
    console.error('批量删除通知失败:', error)
    message.error('批量删除通知失败')
  } finally {
    batchDeleting.value = false
  }
}

const handleMarkAsRead = async (notificationId: number) => {
  try {
    const response = await notificationApi.markAsRead(notificationId)
    if (response.code === 200) {
      message.success('已标记为已读')
      loadNotifications()
      loadUnreadCount()
    } else {
      message.error(response.message || '标记失败')
    }
  } catch (error) {
    console.error('标记为已读失败:', error)
    message.error('标记为已读失败')
  }
}

/**
 * 接受文档邀请
 */
const handleAcceptInvite = async (notification: NotificationDTO) => {
  if (!notification.relatedId) {
    message.error('文档ID无效')
    return
  }

  try {
    const response = await documentInviteApi.acceptInvite(notification.relatedId)
    if (response.code === 200) {
      message.success('已接受邀请')
      // 标记通知为已读
      await notificationApi.markAsRead(notification.id)
      loadNotifications()
      loadUnreadCount()
    } else {
      message.error(response.message || '接受邀请失败')
    }
  } catch (error) {
    console.error('接受邀请失败:', error)
    message.error('接受邀请失败')
  }
}

/**
 * 拒绝文档邀请
 */
const handleRejectInvite = async (notification: NotificationDTO) => {
  if (!notification.relatedId) {
    message.error('文档ID无效')
    return
  }

  try {
    const response = await documentInviteApi.rejectInvite(notification.relatedId)
    if (response.code === 200) {
      message.success('已拒绝邀请')
      // 标记通知为已读
      await notificationApi.markAsRead(notification.id)
      loadNotifications()
      loadUnreadCount()
    } else {
      message.error(response.message || '拒绝邀请失败')
    }
  } catch (error) {
    console.error('拒绝邀请失败:', error)
    message.error('拒绝邀请失败')
  }
}

const handleMarkAllAsRead = async () => {
  markingAllAsRead.value = true
  try {
    const response = await notificationApi.markAllAsRead()
    if (response.code === 200) {
      message.success('已全部标记为已读')
      loadNotifications()
      loadUnreadCount()
    } else {
      message.error(response.message || '标记失败')
    }
  } catch (error) {
    console.error('全部标记为已读失败:', error)
    message.error('全部标记为已读失败')
  } finally {
    markingAllAsRead.value = false
  }
}

const handleDelete = async (notificationId: number) => {
  try {
    const response = await notificationApi.deleteNotification(notificationId)
    if (response.code === 200) {
      message.success('删除成功')
      loadNotifications()
      loadUnreadCount()
    } else {
      message.error(response.message || '删除失败')
    }
  } catch (error) {
    console.error('删除通知失败:', error)
    message.error('删除通知失败')
  }
}

const handleNotificationClick = (notification: NotificationDTO) => {
  // 只在"我的通知"标签页中才标记为已读
  if (activeTab.value === 'received' && notification.isRead === 0) {
    handleMarkAsRead(notification.id)
  }
  if (notification.relatedType === 'document' && notification.relatedId) {
    window.location.href = `/document/${notification.relatedId}/edit`
  } else if (notification.relatedType === 'knowledge_base' && notification.relatedId) {
    window.location.href = `/home/knowledge-base/${notification.relatedId}`
  }
}

const formatTime = (dateString: string) => {
  return dayjs(dateString).fromNow()
}

const getNotificationTypeName = (type: string): string => {
  const typeMap: Record<string, string> = {
    'system_notice': '系统通知',
    'doc_invite': '文档邀请',
    'kb_invite': '知识库邀请',
    'comment_mention': '评论提及'
  }
  return typeMap[type] || type
}

const openSendModal = () => {
  showSendModal.value = true
}

const resetSendForm = () => {
  sendForm.userId = ''
  sendForm.userIds = ''
  sendForm.isBatch = false
  sendForm.type = ''
  sendForm.title = ''
  sendForm.content = ''
  sendForm.relatedId = ''
}

const handleSendNotification = async () => {
  if (!sendForm.isBatch && !sendForm.userId) {
    message.error('请输入接收用户ID')
    return
  }
  if (sendForm.isBatch && !sendForm.userIds) {
    message.error('请输入用户ID列表')
    return
  }
  if (!sendForm.type) {
    message.error('请选择通知类型')
    return
  }
  if (!sendForm.title) {
    message.error('请输入通知标题')
    return
  }
  if (!sendForm.content) {
    message.error('请输入通知内容')
    return
  }
  if ((sendForm.type === 'doc_invite' || sendForm.type === 'kb_invite' || sendForm.type === 'comment_mention') && !sendForm.relatedId) {
    message.error('请输入相关ID')
    return
  }
  sending.value = true
  try {
    if (sendForm.isBatch) {
      const userIdList = sendForm.userIds.split(',').map((id) => id.trim()).filter((id) => id)
      if (userIdList.length === 0) {
        message.error('请输入有效的用户ID')
        sending.value = false
        return
      }
      const dtos: CreateNotificationDTO[] = userIdList.map((userId) => ({
        userId: parseInt(userId),
        type: sendForm.type,
        title: sendForm.title,
        content: sendForm.content,
        relatedType: getRelatedType(sendForm.type),
        relatedId: sendForm.relatedId ? parseInt(sendForm.relatedId) : undefined
      }))
      const response = await notificationApi.createNotificationsBatch(dtos)
      if (response.code === 200) {
        message.success(`成功发送 ${response.data} 条通知`)
        showSendModal.value = false
        resetSendForm()
      } else {
        message.error(response.message || '发送失败')
      }
    } else {
      const dto: CreateNotificationDTO = {
        userId: parseInt(sendForm.userId),
        type: sendForm.type,
        title: sendForm.title,
        content: sendForm.content,
        relatedType: getRelatedType(sendForm.type),
        relatedId: sendForm.relatedId ? parseInt(sendForm.relatedId) : undefined
      }
      const response = await notificationApi.createNotification(dto)
      if (response.code === 200) {
        message.success('通知发送成功')
        showSendModal.value = false
        resetSendForm()
      } else {
        message.error(response.message || '发送失败')
      }
    }
  } catch (error) {
    console.error('发送通知失败:', error)
    message.error('发送通知失败')
  } finally {
    sending.value = false
  }
}

const getRelatedType = (type: string): string => {
  switch (type) {
    case 'doc_invite':
      return 'document'
    case 'kb_invite':
      return 'knowledge_base'
    case 'comment_mention':
      return 'comment'
    default:
      return 'system'
  }
}
</script>

<style scoped>
.notifications-container {
  padding: 0;
}

.notifications-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.card-title {
  display: flex;
  align-items: center;
  gap: 12px;
}

.notifications-list {
  min-height: 400px;
}

.notification-item {
  padding: 16px;
  border-radius: 4px;
  transition: background-color 0.3s;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-item:hover {
  background-color: #f5f5f5;
}

.notification-item.unread {
  background-color: #e6f7ff;
}

.notification-item.unread:hover {
  background-color: #bae7ff;
}

.notification-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: #1890ff;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  flex-shrink: 0;
}

.notification-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.notification-title span:first-child {
  font-weight: 500;
  font-size: 14px;
  color: rgba(0, 0, 0, 0.88);
}

.notification-time {
  font-size: 12px;
  color: rgba(0, 0, 0, 0.45);
}

.notification-content {
  font-size: 14px;
  color: rgba(0, 0, 0, 0.65);
  line-height: 1.5;
}

.notification-sender {
  font-size: 12px;
  color: rgba(0, 0, 0, 0.45);
  margin-top: 4px;
}

.notification-tags {
  display: flex;
  gap: 8px;
  margin-top: 8px;
  align-items: center;
}

.notification-tabs :deep(.ant-tabs-nav) {
  margin-bottom: 0;
}

.notification-tabs :deep(.ant-tabs-tab) {
  padding: 8px 16px;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 24px;
  padding: 16px 0;
}
</style>
