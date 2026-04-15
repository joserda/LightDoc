<template>
  <div class="document-editor-container">
    <!-- 第一行：导航栏 -->
    <div class="editor-navbar">
      <div class="navbar-left">
        <a-button type="text" @click="goBack" class="nav-button show-text">
          <ArrowLeftOutlined />
          <span>退出</span>
        </a-button>
        <a-button 
          type="text" 
          @click="toggleToc" 
          class="nav-button" 
          :class="{ active: isTocVisible }"
        >
          <MenuFoldOutlined v-if="isTocVisible" />
          <MenuUnfoldOutlined v-else />
        </a-button>
        <a-button 
          type="text" 
          @click="toggleRightSidebar" 
          class="nav-button" 
          :class="{ active: isRightSidebarVisible }"
        >
          <RightOutlined v-if="!isRightSidebarVisible" />
          <LeftOutlined v-else />
        </a-button>
        <a-input
          v-model:value="documentTitle"
          :maxlength="100"
          class="document-title-input"
          placeholder="请输入文档标题"
          :bordered="false"
        />
      </div>      
      <div class="navbar-center">
        <div class="document-status">
           <a-tag color="blue">协同编辑</a-tag>
        </div>
        <div class="collaboration-info">
          <span class="online-count">{{ onlineCount }} 人在线</span>
        </div>
      </div>
      
      <div class="navbar-right">
        <a-space>
          <a-button type="text" v-if="isOwner || canManageMembers" @click="openSettings">
            <template #icon><SettingOutlined /></template>
          </a-button>
          <a-dropdown>
            <a-button>
              导出
            </a-button>
            <template #overlay>
              <a-menu>
                <a-menu-item key="export-json" @click="exportAsJson">
                  导出为 JSON
                </a-menu-item>
                <a-menu-item key="export-markdown" @click="exportAsMarkdown">
                  导出为 Markdown
                </a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
          <a-button type="primary" @click="handleSave">
            <template #icon><SaveOutlined /></template>
            <span>保存</span>
          </a-button>
        </a-space>
      </div>
    </div>
    
    <!-- 第二行：编辑器菜单栏 -->
    <div v-if="editorInstance" class="editor-menubar">
      <EditorMenuBar :editor="editorInstance" :document-id="Number(documentId)" />
    </div>

    <!-- 第三行：编辑器内容区 -->
    <div class="editor-main-layout">
      <!-- 左侧目录侧边栏 -->
      <div v-if="isTocVisible" class="toc-sidebar">
        <div class="toc-header">
          <FileTextOutlined />
          <span>目录</span>
        </div>
        <div class="toc-content">
          <template v-if="tocItems.length">
            <div
              v-for="item in tocItems"
              :key="item.id"
              class="toc-item"
              :class="{ active: item.id === activeTocId }"
              :style="{ paddingLeft: `${(item.level - 1) * 12}px` }"
              @click="scrollToHeading(item)"
            >
              <span class="toc-item-text">{{ item.text }}</span>
            </div>
          </template>
          <div v-else class="toc-empty">暂无目录</div>
        </div>
      </div>

      <!-- 编辑器内容区 -->
      <div class="editor-content-area">
        <div class="tiptap-editor-wrapper">
          <EditorContent v-if="editorInstance" :editor="editorInstance" class="editor-content" />
        </div>
      </div>

      <!-- 右侧工具栏 -->
      <div v-if="isRightSidebarVisible" class="right-sidebar">
        <div class="right-sidebar-tabs">
          <div
            :class="['tab-item', { active: activeRightTab === 'team' }]"
            @click="switchRightTab('team')"
          >
            <TeamOutlined />
            <span>团队成员</span>
          </div>
          <div
            :class="['tab-item', { active: activeRightTab === 'history' }]"
            @click="switchRightTab('history')"
          >
            <HistoryOutlined />
            <span>版本历史</span>
          </div>
          <div
            :class="['tab-item', { active: activeRightTab === 'comments' }]"
            @click="switchRightTab('comments')"
          >
            <MessageOutlined />
            <span>在线评论</span>
          </div>
        </div>

        <div class="right-sidebar-content">
          <div v-if="activeRightTab === 'team'" class="panel-content">
            <div class="panel-header">
              <span>团队成员</span>
              <a-button type="text" size="small" @click="handleOpenInvite">
                <template #icon><UserAddOutlined /></template>
                邀请
              </a-button>
            </div>
            <div class="team-list">
              <template v-if="sortedMembers.length">
                <div
                  v-for="member in sortedMembers"
                  :key="member.userId"
                  class="team-member-item"
                >
                  <a-avatar
                    :src="member.avatar"
                    class="member-avatar-clickable"
                    @click="openMemberDetail(member)"
                  >
                    {{ (member.nickname || member.username || '').charAt(0).toUpperCase() }}
                  </a-avatar>
                  <div class="member-info">
                    <div class="member-main">
                      <div class="member-name">
                        {{ member.nickname || member.username }}
                      </div>
                      <div class="member-permission-row">
                        <div
                          class="member-permission"
                          :style="{
                            color:
                              member.userId === documentOwnerId
                                ? getPermissionColor(3)
                                : getPermissionColor(member.permissionLevel),
                          }"
                        >
                          {{
                            member.userId === documentOwnerId
                              ? '所有者'
                              : getPermissionLabel(member.permissionLevel)
                          }}
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="member-status">
                    <span
                      class="status-dot"
                      :style="{ backgroundColor: member.online ? '#52c41a' : '#d9d9d9' }"
                    ></span>
                    <span class="status-text">{{ member.online ? '在线' : '离线' }}</span>
                  </div>
                </div>
              </template>
              <a-empty v-else description="暂无成员" />
            </div>
          </div>

          <div v-if="activeRightTab === 'history'" class="panel-content">
            <div class="panel-header">
              <span>版本历史</span>
              <a-button
                v-if="canSaveVersion"
                type="primary"
                size="small"
                @click="openCreateVersion"
              >
                创建版本
              </a-button>
            </div>
            <a-list
              :data-source="versions"
              :loading="versionsLoading"
              :locale="{ emptyText: '暂无历史版本' }"
              item-layout="horizontal"
            >
              <template #renderItem="{ item }">
                <a-list-item>
                  <a-list-item-meta>
                    <template #title>
                      <span class="version-title-main">版本 {{ item.versionNumber }}</span>
                    </template>
                    <template #description>
                      <div class="version-meta">
                        <div class="version-meta-row">
                          <span class="version-time">{{ item.createdAt }}</span>
                          <span
                            v-if="getVersionCreatorName(item)"
                            class="version-creator"
                          >
                            · {{ getVersionCreatorName(item) }}
                          </span>
                        </div>
                        <div
                          v-if="item.changeDescription"
                          class="version-description"
                        >
                          {{ item.changeDescription }}
                        </div>
                      </div>
                    </template>
                  </a-list-item-meta>
                  <template #actions>
                    <a-dropdown v-if="canEdit" placement="bottomRight">
                      <a-button type="link" size="small">
                        更多
                      </a-button>
                      <template #overlay>
                        <a-menu>
                          <a-menu-item key="preview" @click="handlePreviewVersion(item)">
                            预览此版本
                          </a-menu-item>
                          <a-menu-item key="compare" @click="handleCompareWithCurrent(item)">
                            与当前版本比对
                          </a-menu-item>
                          <a-menu-divider />
                          <a-menu-item key="rollback">
                            <a-popconfirm
                              title="确定要将文档回滚到该版本吗？"
                              ok-text="回滚"
                              cancel-text="取消"
                              @confirm="() => handleRollbackVersion(item)"
                            >
                              <span>回滚到此版本</span>
                            </a-popconfirm>
                          </a-menu-item>
                        </a-menu>
                      </template>
                    </a-dropdown>
                  </template>
                </a-list-item>
              </template>
            </a-list>
          </div>

          <div v-if="activeRightTab === 'comments'" class="panel-content">
            <div class="panel-header">
              <span>在线评论</span>
            </div>
            <div class="comments-section">
              <a-spin :spinning="commentsLoading">
                <div v-if="!comments.length && !commentsLoading" class="comments-empty">
                  <a-empty description="暂无评论" />
                </div>
                <div
                  v-else
                  ref="commentsListRef"
                  class="comments-list"
                >
                  <div
                    v-for="comment in comments"
                    :key="comment.id"
                    class="comment-thread"
                  >
                    <a-dropdown
                      :trigger="['contextmenu']"
                      :overlay-style="{ minWidth: '120px' }"
                    >
                      <div
                        :class="['chat-message', { 'is-self': isSelfComment(comment) }]"
                      >
                        <div class="chat-avatar">
                          {{ getCommentInitial(comment) }}
                        </div>
                        <div class="chat-bubble-wrapper">
                          <div class="chat-meta">
                            <template v-if="isSelfComment(comment)">
                              <span class="chat-time">
                                {{ formatCommentTime(comment.createdAt) }}
                              </span>
                              <span class="chat-author">
                                {{ getCommentDisplayName(comment) }}
                              </span>
                            </template>
                            <template v-else>
                              <span class="chat-author">
                                {{ getCommentDisplayName(comment) }}
                              </span>
                              <span class="chat-time">
                                {{ formatCommentTime(comment.createdAt) }}
                              </span>
                            </template>
                          </div>
                          <div class="chat-bubble">
                            {{ comment.content }}
                          </div>
                        </div>
                      </div>
                      <template #overlay>
                        <a-menu>
                          <a-menu-item
                            v-if="canComment"
                            @click="toggleReplyInput(comment.id!)"
                          >
                            回复
                          </a-menu-item>
                          <a-menu-item
                            v-if="canDeleteComment(comment)"
                            danger
                            @click="handleDeleteComment(comment.id!)"
                          >
                            删除
                          </a-menu-item>
                        </a-menu>
                      </template>
                    </a-dropdown>

                    <div
                      v-if="replyContentMap[comment.id!]"
                      class="chat-reply-editor"
                    >
                      <a-textarea
                        v-model:value="replyContentMap[comment.id!]"
                        :rows="2"
                        placeholder="输入回复内容..."
                      />
                      <div class="chat-reply-actions">
                        <a-button
                          size="small"
                          style="margin-right: 8px"
                          @click="cancelReply(comment.id!)"
                        >
                          取消
                        </a-button>
                        <a-button
                          type="primary"
                          size="small"
                          :loading="submittingReplyId === comment.id"
                          @click="handleSubmitReply(comment.id!)"
                        >
                          发送回复
                        </a-button>
                      </div>
                    </div>

                    <div
                      v-if="comment.replies && comment.replies.length"
                      class="comment-replies"
                    >
                      <div
                        v-for="reply in comment.replies"
                        :key="reply.id"
                      >
                        <a-dropdown
                          :trigger="['contextmenu']"
                          :overlay-style="{ minWidth: '120px' }"
                        >
                          <div
                            :class="['chat-message', 'chat-reply', { 'is-self': isSelfComment(reply) }]"
                          >
                            <div class="chat-avatar chat-avatar-small">
                              {{ getCommentInitial(reply) }}
                            </div>
                            <div class="chat-bubble-wrapper">
                              <div class="chat-meta">
                                <template v-if="isSelfComment(reply)">
                                  <span class="chat-time">
                                    {{ formatCommentTime(reply.createdAt) }}
                                  </span>
                                  <span class="chat-author">
                                    {{ getCommentDisplayName(reply) }}
                                  </span>
                                </template>
                                <template v-else>
                                  <span class="chat-author">
                                    {{ getCommentDisplayName(reply) }}
                                  </span>
                                  <span class="chat-time">
                                    {{ formatCommentTime(reply.createdAt) }}
                                  </span>
                                </template>
                              </div>
                              <div class="chat-bubble chat-bubble-reply">
                                {{ reply.content }}
                              </div>
                            </div>
                          </div>
                          <template #overlay>
                            <a-menu>
                              <a-menu-item
                                v-if="canDeleteComment(reply)"
                                danger
                                @click="handleDeleteComment(reply.id!)"
                              >
                                删除
                              </a-menu-item>
                            </a-menu>
                          </template>
                        </a-dropdown>
                      </div>
                    </div>
                  </div>
                </div>
              </a-spin>
              <div v-if="canComment" class="comment-editor">
                <a-textarea
                  v-model:value="newCommentContent"
                  :rows="3"
                  placeholder="输入评论内容..."
                />
                <div class="comment-editor-actions">
                  <a-button
                    type="primary"
                    size="small"
                    :loading="submittingComment"
                    @click="handleSubmitComment"
                  >
                    发表评论
                  </a-button>
                </div>
              </div>
              <div v-else class="comment-no-permission">
                当前权限不支持评论
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <a-modal
      v-model:open="showInviteModal"
      title="邀请成员"
      :footer="null"
    >
      <a-input-search
        v-model:value="searchKeyword"
        placeholder="搜索用户名或邮箱..."
        @search="handleUserSearch"
        :loading="searchLoading"
        allow-clear
        style="margin-bottom: 16px;"
      />
      <a-list
        :data-source="searchResults"
        :loading="searchLoading"
        :locale="{ emptyText: '请输入关键字搜索用户' }"
      >
        <template #renderItem="{ item }">
          <a-list-item>
            <a-list-item-meta>
              <template #avatar>
                <a-avatar :src="item.avatar">
                  {{ (item.nickname || item.username || '').charAt(0).toUpperCase() }}
                </a-avatar>
              </template>
              <template #title>{{ item.nickname || item.username }}</template>
              <template #description>{{ item.email }}</template>
            </a-list-item-meta>
            <a-button
              type="primary"
              size="small"
              :loading="invitingUserIds.includes(item.id)"
              @click="handleInviteUser(item.id)"
            >
              邀请
            </a-button>
          </a-list-item>
        </template>
      </a-list>
    </a-modal>
    <a-modal
      v-model:open="memberDetailVisible"
      :footer="null"
      width="360px"
    >
      <div v-if="memberDetail" class="member-detail">
        <div class="member-detail-header">
          <a-avatar :src="memberDetail.avatar" size="large">
            {{ (memberDetail.nickname || memberDetail.username || '').charAt(0).toUpperCase() }}
          </a-avatar>
          <div class="member-detail-main">
            <div class="member-detail-name">
              {{ memberDetail.nickname || memberDetail.username }}
            </div>
            <div class="member-detail-status">
              <span
                class="status-dot"
                :style="{ backgroundColor: memberDetail.online ? '#52c41a' : '#d9d9d9' }"
              ></span>
              <span class="status-text">
                {{ memberDetail.online ? '在线' : '离线' }}
              </span>
            </div>
          </div>
        </div>
        <div class="member-detail-body">
          <div class="member-detail-row">
            <span class="label">用户名</span>
            <span class="value">{{ memberDetail.username }}</span>
          </div>
          <div
            v-if="memberDetail.nickname && memberDetail.nickname !== memberDetail.username"
            class="member-detail-row"
          >
            <span class="label">昵称</span>
            <span class="value">{{ memberDetail.nickname }}</span>
          </div>
          <div
            v-if="memberDetail.email"
            class="member-detail-row"
          >
            <span class="label">邮箱</span>
            <span class="value">{{ memberDetail.email }}</span>
          </div>
          <div class="member-detail-row">
            <span class="label">加入时间</span>
            <span class="value">{{ memberDetail.joinedAt }}</span>
          </div>
          <div class="member-detail-row">
            <span class="label">权限</span>
            <span class="value">
              <template v-if="memberDetail.userId === documentOwnerId">
                <span :style="{ color: getPermissionColor(3) }">所有者</span>
              </template>
              <template v-else>
                <a-select
                  v-if="canManageMembers"
                  size="small"
                  class="member-detail-permission-select"
                  :value="memberDetailPermission ?? memberDetail.permissionLevel"
                  style="width: 120px"
                  @change="handleMemberDetailPermissionChange"
                >
                  <a-select-option :value="0">只读</a-select-option>
                  <a-select-option :value="1">评论</a-select-option>
                  <a-select-option :value="2">编辑</a-select-option>
                  <a-select-option :value="3">管理</a-select-option>
                </a-select>
                <span
                  v-else
                  :style="{ color: getPermissionColor(memberDetail.permissionLevel) }"
                >
                  {{ getPermissionLabel(memberDetail.permissionLevel) }}
                </span>
              </template>
            </span>
          </div>
        </div>
        <div
          v-if="canManageMembers && memberDetail.userId !== documentOwnerId"
          class="member-detail-footer"
        >
          <a-button
            type="primary"
            block
            @click="saveMemberDetailPermission"
          >
            保存权限
          </a-button>
        </div>
      </div>
    </a-modal>
    <a-modal
      v-model:open="showCreateVersionModal"
      title="创建版本"
      :confirm-loading="creatingVersion"
      @ok="createVersion"
    >
      <a-textarea
        v-model:value="newVersionDescription"
        :rows="3"
        placeholder="请输入本次版本的说明（可选）"
      />
    </a-modal>
    <a-modal
      v-model:open="showSettingsModal"
      title="文档设置"
      :confirm-loading="savingSettings"
      @ok="saveSettings"
    >
      <a-form :model="settingsForm" layout="vertical">
        <a-form-item label="启用版本历史">
          <a-switch v-model:checked="settingsForm.versioningEnabled" />
        </a-form-item>
        <a-form-item label="最大保留版本数量">
          <a-input-number
            v-model:value="settingsForm.maxVersionCount"
            :min="1"
            :max="500"
            style="width: 100%"
          />
        </a-form-item>
        <a-form-item label="启用自动保存">
          <a-switch v-model:checked="settingsForm.autosaveEnabled" />
        </a-form-item>
        <a-form-item label="自动保存间隔（秒）">
          <a-input-number
            v-model:value="settingsForm.autosaveIntervalSeconds"
            :min="1"
            :max="600"
            style="width: 100%"
          />
        </a-form-item>
      </a-form>
    </a-modal>
    <a-modal
      v-model:open="versionPreviewVisible"
      :title="versionPreviewTitle"
      :footer="null"
      width="80%"
    >
      <a-spin :spinning="versionPreviewLoading">
        <div class="version-preview-wrapper">
          <div v-if="previewVersionEditor" class="version-preview-editor">
            <EditorContent
              :editor="previewVersionEditor"
              class="editor-content readonly-preview"
            />
          </div>
          <div v-else class="preview-empty">
            暂无内容
          </div>
        </div>
      </a-spin>
    </a-modal>
    <a-modal
      v-model:open="versionCompareVisible"
      :title="versionCompareTitle"
      :footer="null"
      width="90%"
    >
      <a-spin :spinning="versionCompareLoading">
        <div class="version-compare-container">
          <div class="version-compare-column">
            <div class="version-compare-header">历史版本</div>
            <div v-if="compareVersionEditor" class="version-compare-editor">
              <EditorContent
                :editor="compareVersionEditor"
                class="editor-content readonly-preview"
              />
            </div>
            <div v-else class="preview-empty">
              暂无内容
            </div>
          </div>
          <div class="version-compare-column">
            <div class="version-compare-header">当前版本</div>
            <div v-if="currentVersionSnapshotEditor" class="version-compare-editor">
              <EditorContent
                :editor="currentVersionSnapshotEditor"
                class="editor-content readonly-preview"
              />
            </div>
            <div v-else class="preview-empty">
              暂无内容
            </div>
          </div>
        </div>
      </a-spin>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, shallowRef, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  ArrowLeftOutlined,
  SaveOutlined,
  MenuUnfoldOutlined,
  MenuFoldOutlined,
  FileTextOutlined,
  TeamOutlined,
  HistoryOutlined,
  MessageOutlined,
  RightOutlined,
  LeftOutlined,
  UserAddOutlined,
  SettingOutlined,
} from '@ant-design/icons-vue'
import { EditorContent, Editor } from '@tiptap/vue-3'
import { Extension, Mark } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import CodeBlock from '@tiptap/extension-code-block'
import Image from '@tiptap/extension-image'
import Link from '@tiptap/extension-link'
import Underline from '@tiptap/extension-underline'
import TextAlign from '@tiptap/extension-text-align'
import { Table } from '@tiptap/extension-table'
import { TableRow } from '@tiptap/extension-table-row'
import { TableHeader } from '@tiptap/extension-table-header'
import { TableCell } from '@tiptap/extension-table-cell'
import { ySyncPlugin, yCursorPlugin } from 'y-prosemirror'
import EditorMenuBar from '@/components/editor/EditorMenuBar.vue'
import { WebsocketProvider } from 'y-websocket'
import * as Y from 'yjs'
import { Awareness } from 'y-protocols/awareness'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import { storage } from '@/utils/storage'
import { documentApi, type DocumentSettingsDTO, type DocumentVersionDTO } from '@/api/documents'
import { documentInviteApi, type MemberDTO } from '@/api/documentInvites'
import { authApi, type UserInfo } from '@/api/auth'
import { commentApi, type CommentDTO } from '@/api/comments'
import { Plugin, PluginKey, TextSelection } from 'prosemirror-state'
import { Decoration, DecorationSet } from 'prosemirror-view'

const CustomImage = Image.extend({
  addAttributes() {
    return {
      ...this.parent?.(),
      width: {
        default: null,
        renderHTML: attributes => {
          if (!attributes.width) return {}
          return { style: `width: ${attributes.width}` }
        },
        parseHTML: element =>
          (element as any).style?.width || (element as any).getAttribute?.('width'),
      },
    }
  },
  addNodeView() {
    return ({ node, editor, getPos }: any) => {
      let currentNode = node

      const dom = document.createElement('span')
      dom.classList.add('resizable-image-wrapper')
      dom.setAttribute('data-type', 'resizable-image')
      dom.style.display = 'inline-block'
      dom.style.position = 'relative'

      const img = document.createElement('img')
      img.src = currentNode.attrs.src || ''
      img.alt = currentNode.attrs.alt || ''
      img.title = currentNode.attrs.title || ''
      if (currentNode.attrs.width) {
        img.style.width = currentNode.attrs.width
      }
      img.style.display = 'block'
      img.draggable = false
      dom.appendChild(img)

      const handle = document.createElement('span')
      handle.classList.add('resizable-image-handle')
      dom.appendChild(handle)

      const updateHandlePosition = () => {
        const wrapperRect = dom.getBoundingClientRect()
        const imgRect = img.getBoundingClientRect()
        const left = imgRect.right - wrapperRect.left - handle.offsetWidth / 2
        const top = imgRect.bottom - wrapperRect.top - handle.offsetHeight / 2
        handle.style.left = `${left}px`
        handle.style.top = `${top}px`
      }

      let startX = 0
      let startWidth = 0

      const onMouseMove = (event: MouseEvent) => {
        const diff = event.clientX - startX
        let newWidthPx = startWidth + diff

        const editorDom = editor.view.dom as HTMLElement
        const editorRect = editorDom.getBoundingClientRect()
        const parentRect = dom.parentElement
          ? dom.parentElement.getBoundingClientRect()
          : editorRect
        const containerWidth = parentRect.width || newWidthPx || 1

        if (newWidthPx < 20) {
          newWidthPx = 20
        }
        if (newWidthPx > containerWidth) {
          newWidthPx = containerWidth
        }

        const percent = Math.round((newWidthPx / containerWidth) * 100)
        img.style.width = `${percent}%`
        updateHandlePosition()
      }

      const onMouseUp = () => {
        window.removeEventListener('mousemove', onMouseMove)
        window.removeEventListener('mouseup', onMouseUp)

        const width = img.style.width || null
        const pos = typeof getPos === 'function' ? getPos() : null
        if (typeof pos === 'number') {
          editor.commands.command(({ tr }: any) => {
            tr.setNodeMarkup(pos, undefined, {
              ...currentNode.attrs,
              width,
            })
            return true
          })
        }
      }

      const onMouseDown = (event: MouseEvent) => {
        event.preventDefault()
        event.stopPropagation()
        startX = event.clientX
        startWidth = img.getBoundingClientRect().width
        updateHandlePosition()
        window.addEventListener('mousemove', onMouseMove)
        window.addEventListener('mouseup', onMouseUp)
      }

      handle.addEventListener('mousedown', onMouseDown)

      return {
        dom,
        selectNode() {
          dom.classList.add('has-selection')
        },
        deselectNode() {
          dom.classList.remove('has-selection')
        },
        update(updatedNode: any) {
          if (updatedNode.type !== currentNode.type) {
            return false
          }
          currentNode = updatedNode
          if (updatedNode.attrs.src && updatedNode.attrs.src !== img.src) {
            img.src = updatedNode.attrs.src
          }
          img.alt = updatedNode.attrs.alt || ''
          img.title = updatedNode.attrs.title || ''
          if (updatedNode.attrs.width) {
            img.style.width = updatedNode.attrs.width
          } else {
            img.style.removeProperty('width')
          }
          updateHandlePosition()
          return true
        },
        destroy() {
          handle.removeEventListener('mousedown', onMouseDown)
        },
      }
    }
  },
})

const CodeBlockWithTheme = CodeBlock.extend({
  addAttributes() {
    return {
      ...this.parent?.(),
      language: {
        default: 'plaintext',
        parseHTML: element => {
          const value = (element as HTMLElement).getAttribute('data-language') || ''
          return value || 'plaintext'
        },
        renderHTML: attributes => {
          const language = (attributes as any)?.language || 'plaintext'
          return {
            'data-language': language,
          }
        },
      },
      theme: {
        default: 'dark',
        parseHTML: element => {
          const value = (element as HTMLElement).getAttribute('data-code-theme') || ''
          return value || 'dark'
        },
        renderHTML: attributes => {
          const theme = (attributes as any)?.theme || 'dark'
          return {
            'data-code-theme': theme,
          }
        },
      },
    }
  },
})

const CodeBlockLineNumbersExtension = Extension.create({
  name: 'codeBlockLineNumbers',
  addProseMirrorPlugins() {
    return [
      new Plugin({
        key: new PluginKey('codeBlockLineNumbers'),
        props: {
          decorations(state) {
            const { doc } = state
            const decorations: Decoration[] = []

            doc.descendants((node, pos) => {
              if (node.type.name !== 'codeBlock') {
                return
              }
              const text = node.textContent || ''
              const lines = text.split('\n').length || 1
              const safeLines = lines > 0 ? lines : 1
              const numbers = Array.from({ length: safeLines }, (_, index) =>
                String(index + 1),
              ).join('\n')

              decorations.push(
                Decoration.node(pos, pos + node.nodeSize, {
                  'data-line-numbers': numbers,
                  'data-line-count': String(safeLines),
                }),
              )
            })

            if (!decorations.length) {
              return null
            }

            return DecorationSet.create(doc, decorations)
          },
        },
      }),
    ]
  },
})

const TextStyleMark = Mark.create({
  name: 'textStyle',
  addAttributes() {
    return {
      color: {
        default: null,
        parseHTML: element => (element as HTMLElement).style.color || null,
        renderHTML: () => ({}),
      },
      fontSize: {
        default: null,
        parseHTML: element => (element as HTMLElement).style.fontSize || null,
        renderHTML: () => ({}),
      },
    }
  },
  parseHTML() {
    return [
      {
        tag: 'span[style]',
      },
    ]
  },
  renderHTML({ HTMLAttributes }) {
    const attrs = HTMLAttributes as any
    const color = attrs.color as string | null | undefined
    const fontSize = attrs.fontSize as string | null | undefined
    const { color: _c, fontSize: _f, ...rest } = attrs
    const styles: string[] = []
    if (rest.style) {
      styles.push(String(rest.style))
    }
    if (color) {
      styles.push(`color: ${color};`)
    }
    if (fontSize) {
      styles.push(`font-size: ${fontSize};`)
    }
    const mergedStyle = styles.filter(Boolean).join(' ')
    return ['span', { ...rest, ...(mergedStyle ? { style: mergedStyle } : {}) }, 0]
  },
  addCommands() {
    return {
      setTextColor:
        (color: string | null) =>
        ({ chain, editor }: any) => {
          const current = (editor.getAttributes('textStyle') as any) || {}
          const next = {
            color,
            fontSize: current.fontSize ?? null,
          }
          let c = chain().setMark('textStyle', next)
          if (!next.color && !next.fontSize) {
            c = c.unsetMark('textStyle')
          }
          return c.run()
        },
      setFontSize:
        (fontSize: string | null) =>
        ({ chain, editor }: any) => {
          const current = (editor.getAttributes('textStyle') as any) || {}
          const next = {
            color: current.color ?? null,
            fontSize,
          }
          let c = chain().setMark('textStyle', next)
          if (!next.color && !next.fontSize) {
            c = c.unsetMark('textStyle')
          }
          return c.run()
        },
      unsetTextColor:
        () =>
        ({ chain, editor }: any) => {
          const current = (editor.getAttributes('textStyle') as any) || {}
          const next = {
            color: null,
            fontSize: current.fontSize ?? null,
          }
          let c = chain().setMark('textStyle', next)
          if (!next.color && !next.fontSize) {
            c = c.unsetMark('textStyle')
          }
          return c.run()
        },
      unsetFontSize:
        () =>
        ({ chain, editor }: any) => {
          const current = (editor.getAttributes('textStyle') as any) || {}
          const next = {
            color: current.color ?? null,
            fontSize: null,
          }
          let c = chain().setMark('textStyle', next)
          if (!next.color && !next.fontSize) {
            c = c.unsetMark('textStyle')
          }
          return c.run()
        },
    } as any
  },
})

const SuperscriptMark = Mark.create({
  name: 'superscript',
  parseHTML() {
    return [
      {
        tag: 'sup',
      },
    ]
  },
  renderHTML() {
    return ['sup', 0]
  },
  addCommands() {
    return {
      toggleSuperscript:
        () =>
        ({ chain }: any) => {
          return chain().unsetMark('subscript').toggleMark('superscript').run()
        },
    } as any
  },
})

const SubscriptMark = Mark.create({
  name: 'subscript',
  parseHTML() {
    return [
      {
        tag: 'sub',
      },
    ]
  },
  renderHTML() {
    return ['sub', 0]
  },
  addCommands() {
    return {
      toggleSubscript:
        () =>
        ({ chain }: any) => {
          return chain().unsetMark('superscript').toggleMark('subscript').run()
        },
    } as any
  },
})

// ==================== 路由和基础状态 ====================
const router = useRouter()
const route = useRoute()
const documentId = computed(() => route.params.id as string)
const documentTitle = ref('未命名文档')
const currentUser = ref(storage.getUser())
const token = storage.getToken()

const pickColorByUserId = (id: number) => {
  const colors = ['#958DF1', '#F98181', '#FBBC88', '#FAF594', '#70CFF8', '#94FADB', '#B9F18D']
  const safeId = Number.isFinite(id) ? id : 0
  const idx = Math.abs(safeId) % colors.length
  return colors[idx]
}

// 当前用户光标信息
const user = computed(() => ({
  name: currentUser.value?.nickname || currentUser.value?.username || '匿名用户',
  color: pickColorByUserId(Number(currentUser.value?.id || 0)),
}))

// ==================== Tiptap 编辑器 ====================
const editor = shallowRef<Editor | null>(null)
const editorInstance = computed(() => editor.value)

interface TocItem {
  id: string
  level: number
  text: string
  pos: number
}

// ==================== 能力与成员与在线状态 ====================
const canView = ref(false)
const canComment = ref(false)
const canEdit = ref(false)
const canSaveVersion = ref(false)
const canLock = ref(false)
const canManageMembers = ref(false)
const canChangeVisibility = ref(false)
const isOwner = ref(false)

interface MemberWithOnline extends MemberDTO {
  online: boolean
}

const members = ref<MemberWithOnline[]>([])
const onlineUserIds = ref<number[]>([])

const onlineCount = computed(() => onlineUserIds.value.length)

const sortedMembers = computed(() => {
  return [...members.value].sort((a, b) => {
    if (a.online === b.online) {
      const nameA = (a.nickname || a.username || '').toLowerCase()
      const nameB = (b.nickname || b.username || '').toLowerCase()
      return nameA.localeCompare(nameB)
    }
    return a.online ? -1 : 1
  })
})

const formatCommentTime = (value?: string) => {
  if (!value) return ''
  return dayjs(value).format('YYYY-MM-DD HH:mm:ss')
}

const memberDetailVisible = ref(false)
const memberDetail = ref<MemberWithOnline | null>(null)
const memberDetailPermission = ref<number | null>(null)

const getPermissionLabel = (level?: number) => {
  if (level === 3) return '管理'
  if (level === 2) return '编辑'
  if (level === 1) return '评论'
  if (level === 0) return '只读'
  return '成员'
}

const getPermissionColor = (level?: number) => {
  if (level === 3) return '#fa541c'
  if (level === 2) return '#1890ff'
  if (level === 1) return '#13c2c2'
  if (level === 0) return '#8c8c8c'
  return '#8c8c8c'
}

const openMemberDetail = (member: MemberWithOnline) => {
  memberDetail.value = { ...member }
  memberDetailPermission.value =
    member.userId === documentOwnerId.value ? 3 : member.permissionLevel ?? 0
  memberDetailVisible.value = true
}

const handleMemberDetailPermissionChange = (value: number) => {
  if (!memberDetail.value) return
  if (memberDetail.value.userId === documentOwnerId.value) {
    memberDetailPermission.value = 3
    return
  }
  memberDetailPermission.value = value
}

const saveMemberDetailPermission = async () => {
  if (!memberDetail.value || memberDetailPermission.value == null) return
  if (!canManageMembers.value) {
    message.error('没有权限修改成员权限')
    return
  }
  if (memberDetail.value.userId === documentOwnerId.value) {
    memberDetailVisible.value = false
    return
  }
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  try {
    const res = await documentInviteApi.updateMemberPermission(
      docId,
      memberDetail.value.userId,
      memberDetailPermission.value
    )
    if (res.code === 200 && res.data) {
      message.success('权限已更新')
      memberDetailVisible.value = false
      await loadMembersAndOnline()
    } else {
      message.error(res.message || '权限更新失败')
    }
  } catch (e) {
    console.error('更新成员权限失败', e)
    message.error('更新成员权限失败')
  }
}

// ==================== Yjs 协同相关 ====================
// 使用普通变量存储 Yjs 对象，避免 Vue 响应式代理带来的问题
let ydoc: Y.Doc | null = null
let provider: WebsocketProvider | null = null

const isConnected = ref(false)
let hasSynced = false
let autosaveTimer: ReturnType<typeof setTimeout> | null = null
let autosaveInFlight = false
let membersRefreshTimer: ReturnType<typeof setInterval> | null = null
const wsUrl = computed(() => {
  const apiUrl = ((import.meta as any).env?.VITE_API_BASE_URL as string | undefined) || 'http://localhost:8080/api'
  // 将 http/https 转换为 ws/wss
  let wsBase = apiUrl.replace(/^http/, 'ws')
  // 去除末尾斜杠
  if (wsBase.endsWith('/')) {
    wsBase = wsBase.slice(0, -1)
  }
  // 拼接 WebSocket 路径
  return `${wsBase}/ws/collaborate/${documentId.value}`
})

// ==================== UI 状态 ====================
const isTocVisible = ref(true)
const isRightSidebarVisible = ref(true)
const activeRightTab = ref<string>('team')
const documentOwnerId = ref<number | null>(null)
const tocItems = ref<TocItem[]>([])
const activeTocId = ref('')
let tocUpdateTimer: ReturnType<typeof setTimeout> | null = null

const showInviteModal = ref(false)
const searchKeyword = ref('')
const searchLoading = ref(false)
const searchResults = ref<UserInfo[]>([])
const invitingUserIds = ref<number[]>([])

const versions = ref<DocumentVersionDTO[]>([])
const versionsLoading = ref(false)
const showCreateVersionModal = ref(false)
const creatingVersion = ref(false)
const newVersionDescription = ref('')

const versionPreviewVisible = ref(false)
const versionPreviewLoading = ref(false)
const previewVersionEditor = shallowRef<Editor | null>(null)
const versionPreviewTitle = ref('')

const versionCompareVisible = ref(false)
const versionCompareLoading = ref(false)
const compareVersionEditor = shallowRef<Editor | null>(null)
const currentVersionSnapshotEditor = shallowRef<Editor | null>(null)
const versionCompareTitle = ref('')

const comments = ref<CommentDTO[]>([])
const commentsLoading = ref(false)
const newCommentContent = ref('')
const submittingComment = ref(false)
const replyContentMap = ref<Record<number, string>>({})
const submittingReplyId = ref<number | null>(null)
const deletingCommentId = ref<number | null>(null)
const commentsListRef = ref<HTMLElement | null>(null)

const showSettingsModal = ref(false)
const savingSettings = ref(false)
const settingsForm = ref<DocumentSettingsDTO>({
  versioningEnabled: true,
  maxVersionCount: 50,
  autosaveEnabled: true,
  autosaveIntervalSeconds: 5,
})

const applyAutosaveSettings = () => {
  if (!settingsForm.value.autosaveEnabled) {
    if (autosaveTimer) {
      clearTimeout(autosaveTimer)
      autosaveTimer = null
    }
  }
}

const updateActiveToc = () => {
  const instance = editor.value
  if (!instance || !tocItems.value.length) {
    activeTocId.value = ''
    return
  }
  const from = instance.state.selection.from
  let currentId = ''
  for (const item of tocItems.value) {
    if (item.pos <= from) {
      currentId = item.id
    } else {
      break
    }
  }
  activeTocId.value = currentId
}

const buildToc = () => {
  const instance = editor.value
  if (!instance) {
    tocItems.value = []
    activeTocId.value = ''
    return
  }
  const items: TocItem[] = []
  instance.state.doc.descendants((node, pos) => {
    if (node.type.name !== 'heading') return
    const text = node.textContent?.trim() || ''
    if (!text) return
    const level = Number(node.attrs?.level || 1)
    const id = node.attrs?.id ? String(node.attrs.id) : `heading-${documentId.value}-${pos}`
    items.push({
      id,
      level: Number.isFinite(level) ? level : 1,
      text,
      pos,
    })
  })
  tocItems.value = items
  updateActiveToc()
}

const scheduleTocBuild = () => {
  if (tocUpdateTimer) {
    clearTimeout(tocUpdateTimer)
  }
  tocUpdateTimer = setTimeout(() => {
    tocUpdateTimer = null
    buildToc()
  }, 200)
}

const scrollToHeading = (item: TocItem) => {
  const instance = editor.value
  if (!instance) return
  const pos = Math.min(item.pos + 1, instance.state.doc.content.size)
  instance.commands.focus()
  instance.view.dispatch(
    instance.state.tr.setSelection(TextSelection.create(instance.state.doc, pos)).scrollIntoView()
  )
}

const loadMembersAndOnline = async () => {
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return

  try {
    const [membersRes, onlineRes] = await Promise.all([
      documentInviteApi.getDocumentMembers(docId),
      documentInviteApi.getDocumentOnlineUsers(docId),
    ])

    if (membersRes.code === 200 && membersRes.data) {
      const onlineIds = onlineRes.code === 200 && onlineRes.data ? onlineRes.data : []
      onlineUserIds.value = onlineIds
      members.value = membersRes.data.map((m) => ({
        ...m,
        online: onlineIds.includes(m.userId),
      }))
    } else {
      message.error(membersRes.message || '加载成员列表失败')
    }
  } catch (e) {
    console.error('加载成员和在线状态失败', e)
  }
}

const loadComments = async () => {
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  commentsLoading.value = true
  try {
    const res = await commentApi.getDocumentComments(docId)
    if (res.code === 200 && res.data) {
      comments.value = [...res.data].sort((a, b) => {
        const tA = a.createdAt ? dayjs(a.createdAt).valueOf() : 0
        const tB = b.createdAt ? dayjs(b.createdAt).valueOf() : 0
        return tA - tB
      })
      await nextTick()
      if (commentsListRef.value) {
        commentsListRef.value.scrollTop = commentsListRef.value.scrollHeight
      }
    } else {
      message.error(res.message || '加载评论失败')
    }
  } catch (e) {
    console.error('加载评论失败', e)
    message.error('加载评论失败')
  } finally {
    commentsLoading.value = false
  }
}

const handleSubmitComment = async () => {
  const content = newCommentContent.value.trim()
  if (!content) {
    message.warning('请输入评论内容')
    return
  }
  if (!canComment.value) {
    message.error('没有权限发表评论')
    return
  }
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  submittingComment.value = true
  try {
    const res = await commentApi.createComment({
      documentId: docId,
      content,
    })
    if (res.code === 200 && res.data) {
      message.success('评论已发布')
      newCommentContent.value = ''
      await loadComments()
    } else {
      message.error(res.message || '发表评论失败')
    }
  } catch (e) {
    console.error('发表评论失败', e)
    message.error('发表评论失败')
  } finally {
    submittingComment.value = false
  }
}

const toggleReplyInput = (commentId: number) => {
  if (!commentId) return
  if (replyContentMap.value[commentId] !== undefined) {
    delete replyContentMap.value[commentId]
  } else {
    replyContentMap.value[commentId] = ''
  }
}

const cancelReply = (commentId: number) => {
  if (!commentId) return
  if (replyContentMap.value[commentId] !== undefined) {
    delete replyContentMap.value[commentId]
  }
}

const handleSubmitReply = async (commentId: number) => {
  if (!commentId) return
  const content = (replyContentMap.value[commentId] || '').trim()
  if (!content) {
    message.warning('请输入回复内容')
    return
  }
  if (!canComment.value) {
    message.error('没有权限发表评论')
    return
  }
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  submittingReplyId.value = commentId
  try {
    const res = await commentApi.replyComment(commentId, {
      documentId: docId,
      content,
    })
    if (res.code === 200 && res.data) {
      message.success('回复已发布')
      delete replyContentMap.value[commentId]
      await loadComments()
    } else {
      message.error(res.message || '回复失败')
    }
  } catch (e) {
    console.error('回复失败', e)
    message.error('回复失败')
  } finally {
    submittingReplyId.value = null
  }
}

const canDeleteComment = (comment: CommentDTO) => {
  if (!comment) return false
  const currentId = Number(currentUser.value?.id || 0)
  if (!Number.isFinite(currentId) || currentId <= 0) return false
  if (comment.userId && Number(comment.userId) === currentId) {
    return true
  }
  if (documentOwnerId.value && Number(documentOwnerId.value) === currentId) {
    return true
  }
  return false
}

const isSelfComment = (comment: CommentDTO) => {
  if (!comment) return false
  const currentId = Number(currentUser.value?.id || 0)
  if (!Number.isFinite(currentId) || currentId <= 0) return false
  if (!comment.userId) return false
  return Number(comment.userId) === currentId
}

const getCommentDisplayName = (comment: CommentDTO) => {
  if (!comment.userId) return '匿名用户'
  const member = members.value.find((m) => m.userId === comment.userId)
  if (member) {
    if (member.nickname && member.nickname.trim()) return member.nickname
    if (member.username && member.username.trim()) return member.username
  }
  return `用户 ${comment.userId}`
}

const getCommentInitial = (comment: CommentDTO) => {
  const name = getCommentDisplayName(comment)
  if (!name) return '用'
  return name.charAt(0).toUpperCase()
}

const handleDeleteComment = async (commentId: number) => {
  if (!commentId) return
  deletingCommentId.value = commentId
  try {
    const res = await commentApi.deleteComment(commentId)
    if (res.code === 200) {
      message.success('删除成功')
      await loadComments()
    } else {
      message.error(res.message || '删除评论失败')
    }
  } catch (e) {
    console.error('删除评论失败', e)
    message.error('删除评论失败')
  } finally {
    deletingCommentId.value = null
  }
}

const handleOpenInvite = () => {
  if (!canManageMembers.value) {
    message.error('没有权限邀请成员')
    return
  }
  showInviteModal.value = true
  searchKeyword.value = ''
  searchResults.value = []
}

const handleUserSearch = async () => {
  const keyword = searchKeyword.value.trim()
  if (!keyword) {
    searchResults.value = []
    return
  }

  searchLoading.value = true
  try {
    const excludeIds = [
      ...new Set([
        ...members.value.map((m) => m.userId),
        Number(currentUser.value?.id || 0),
      ]),
    ].filter((id) => Number.isFinite(id) && id > 0) as number[]

    const params: { keyword: string; excludeIds?: string } = { keyword }
    if (excludeIds.length) {
      params.excludeIds = excludeIds.join(',')
    }

    const res = await authApi.searchUsers(params)
    if (res.code === 200 && res.data) {
      searchResults.value = res.data
    } else {
      message.error(res.message || '搜索用户失败')
    }
  } catch (e) {
    console.error('搜索用户失败', e)
    message.error('搜索用户失败')
  } finally {
    searchLoading.value = false
  }
}

const handleInviteUser = async (userId: number) => {
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  if (invitingUserIds.value.includes(userId)) return

  invitingUserIds.value.push(userId)
  try {
    const res = await documentInviteApi.inviteUser(docId, {
      userId,
      permissionLevel: 0,
    })
    if (res.code === 200 && res.data) {
      message.success('邀请已发送')
      searchResults.value = searchResults.value.filter((u) => u.id !== userId)
      await loadMembersAndOnline()
    } else {
      message.error(res.message || '邀请失败')
    }
  } catch (e) {
    console.error('邀请失败', e)
    message.error('邀请失败')
  } finally {
    invitingUserIds.value = invitingUserIds.value.filter((id) => id !== userId)
  }
}

const loadVersions = async () => {
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  versionsLoading.value = true
  try {
    const res = await documentApi.listDocumentVersions(docId)
    if (res.code === 200 && res.data) {
      versions.value = res.data
    } else {
      message.error(res.message || '加载版本历史失败')
    }
  } catch (e) {
    console.error('加载版本历史失败', e)
    message.error('加载版本历史失败')
  } finally {
    versionsLoading.value = false
  }
}

const getVersionCreatorName = (item: DocumentVersionDTO) => {
  if (!item) return ''
  const nickname = (item.creatorNickname || '').trim()
  if (nickname) return nickname
  if (!item.createdBy) return ''
  const currentId = Number(currentUser.value?.id || 0)
  if (Number.isFinite(currentId) && currentId > 0 && currentId === item.createdBy) {
    return currentUser.value?.nickname || currentUser.value?.username || '我'
  }
  return ''
}

const handleRollbackVersion = async (item: DocumentVersionDTO) => {
  if (!canEdit.value) {
    message.error('没有权限回滚此文档')
    return
  }
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  try {
    const res = await documentApi.rollbackDocumentToVersion(docId, item.versionNumber)
    if (res.code === 200 && res.data) {
      message.success('回滚成功，将刷新页面以加载该版本')
      setTimeout(() => {
        window.location.reload()
      }, 500)
    } else {
      message.error(res.message || '回滚失败')
    }
  } catch (e) {
    console.error('回滚失败', e)
    message.error('回滚失败')
  }
}

const openCreateVersion = () => {
  if (!canSaveVersion.value) {
    message.error('没有权限保存版本')
    return
  }
  newVersionDescription.value = ''
  showCreateVersionModal.value = true
}

const createVersion = async () => {
  if (!ydoc) {
    message.error('文档尚未初始化')
    return
  }
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  creatingVersion.value = true
  try {
    const stateUpdate = Y.encodeStateAsUpdate(ydoc)
    const base64State = uint8ArrayToBase64(stateUpdate)
    const res = await documentApi.createDocumentVersion(docId, {
      yjsState: base64State,
      description: newVersionDescription.value || undefined,
    })
    if (res.code === 200 && res.data) {
      message.success('版本已创建')
      showCreateVersionModal.value = false
      await loadVersions()
    } else {
      message.error(res.message || '创建版本失败')
    }
  } catch (e) {
    console.error('创建版本失败', e)
    message.error('创建版本失败')
  } finally {
    creatingVersion.value = false
  }
}

const openSettings = async () => {
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  try {
    const res = await documentApi.getDocumentSettings(docId)
    if (res.code === 200 && res.data) {
      settingsForm.value = {
        versioningEnabled: res.data.versioningEnabled ?? true,
        maxVersionCount: res.data.maxVersionCount ?? 50,
        autosaveEnabled: res.data.autosaveEnabled ?? true,
        autosaveIntervalSeconds: res.data.autosaveIntervalSeconds ?? 5,
      }
      applyAutosaveSettings()
      showSettingsModal.value = true
    } else {
      message.error(res.message || '加载文档设置失败')
    }
  } catch (e) {
    console.error('加载文档设置失败', e)
    message.error('加载文档设置失败')
  }
}

const saveSettings = async () => {
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return

  savingSettings.value = true
  try {
    const payload: DocumentSettingsDTO = {
      versioningEnabled: settingsForm.value.versioningEnabled,
      maxVersionCount: settingsForm.value.maxVersionCount,
      autosaveEnabled: settingsForm.value.autosaveEnabled,
      autosaveIntervalSeconds: settingsForm.value.autosaveIntervalSeconds,
    }
    const res = await documentApi.updateDocumentSettings(docId, payload)
    if (res.code === 200 && res.data) {
      settingsForm.value = {
        versioningEnabled: res.data.versioningEnabled ?? true,
        maxVersionCount: res.data.maxVersionCount ?? 50,
        autosaveEnabled: res.data.autosaveEnabled ?? true,
        autosaveIntervalSeconds: res.data.autosaveIntervalSeconds ?? 5,
      }
      applyAutosaveSettings()
      message.success('设置已保存')
      showSettingsModal.value = false
    } else {
      message.error(res.message || '保存文档设置失败')
    }
  } catch (e) {
    console.error('保存文档设置失败', e)
    message.error('保存文档设置失败')
  } finally {
    savingSettings.value = false
  }
}

// ==================== 生命周期 ====================
onMounted(async () => {
  await loadMembersAndOnline()

  const _ydoc = new Y.Doc()
  const _awareness = new Awareness(_ydoc)
  ydoc = _ydoc

  console.log('正在连接 WebSocket:', wsUrl.value)
  const _provider = new WebsocketProvider(
    wsUrl.value,
    '',
    _ydoc,
    {
      connect: true,
      awareness: _awareness,
      params: {
        userId: String(currentUser.value?.id || 0),
        token: token || ''
      }
    }
  )
  provider = _provider

  // 监听连接状态
  _provider.on('status', (event: any) => {
    console.log('WebSocket 状态:', event.status)
    isConnected.value = event.status === 'connected'
    if (event.status === 'connected') {
      message.success('已连接到协同服务器')
      loadMembersAndOnline()
      if (!membersRefreshTimer) {
        membersRefreshTimer = setInterval(() => {
          loadMembersAndOnline()
        }, 10000)
      }
    } else {
      message.warning('连接已断开')
      if (membersRefreshTimer) {
        clearInterval(membersRefreshTimer)
        membersRefreshTimer = null
      }
    }
  })

  _provider.on('connection-error', (event: any) => {
    console.error('WebSocket 连接错误:', event)
    message.error('连接服务器失败')
  })

  _provider.awareness.setLocalStateField('user', user.value)

  const cursorBuilder = (remoteUser: any) => {
    const cursor = document.createElement('span')
    cursor.classList.add('ProseMirror-yjs-cursor')
    cursor.style.borderColor = remoteUser?.color || '#1890ff'

    const label = document.createElement('div')
    label.classList.add('ProseMirror-yjs-cursor__label')
    label.appendChild(document.createTextNode(remoteUser?.name || ''))

    cursor.appendChild(label)
    return cursor
  }

  const yXmlFragment = _ydoc.getXmlFragment('prosemirror')
  const yjsProseMirror = Extension.create({
    name: 'yjsProseMirror',
    addProseMirrorPlugins() {
      return [ySyncPlugin(yXmlFragment), yCursorPlugin(_provider.awareness, { cursorBuilder })]
    },
  })

  await loadMembersAndOnline()

  let initialContent: any = null
  try {
    const result = await documentApi.getDocumentDetail(Number(documentId.value))

    if (result.code === 200 && result.data) {
      const data = result.data
      documentTitle.value = data.title || '未命名文档'
      documentOwnerId.value = data.ownerId ?? null
      canView.value = !!data.canView
      canComment.value = !!data.canComment
      canEdit.value = !!data.canEdit
      canSaveVersion.value = !!data.canSaveVersion
      canLock.value = !!data.canLock
      canManageMembers.value = !!data.canManageMembers
      canChangeVisibility.value = !!data.canChangeVisibility
      isOwner.value = !!data.isOwner
      if (data.proseMirrorJson) {
        try {
          initialContent = JSON.parse(data.proseMirrorJson)
        } catch (e) {
          console.error('解析文档内容失败', e)
        }
      }
    }
  } catch (e) {
    console.error('加载文档详情失败', e)
    message.error('加载文档详情失败')
  }

  const editorInstance = new Editor({
    extensions: [
      StarterKit.configure({
        undoRedo: false,
        codeBlock: false,
      }),
      CodeBlockWithTheme,
      CodeBlockLineNumbersExtension,
      Underline,
      TextStyleMark,
      SuperscriptMark,
      SubscriptMark,
      yjsProseMirror,
      Link.configure({
        openOnClick: false,
        linkOnPaste: true,
        autolink: true,
        HTMLAttributes: {
          target: '_blank',
          rel: 'noopener noreferrer',
        },
      }),
      CustomImage.configure({
        inline: true,
        allowBase64: true,
      }),
      TextAlign.configure({
        types: ['heading', 'paragraph'],
      }),
      Table.configure({
        resizable: true,
      }),
      TableRow,
      TableHeader,
      TableCell,
    ],
    content: '',
    editorProps: {
      attributes: {
        class: 'tiptap-editor-content',
      },
      handlePaste(_, event) {
        const clipboardData = event.clipboardData
        if (!clipboardData) {
          return false
        }

        const imageFiles: File[] = []
        const items = clipboardData.items
        for (let i = 0; i < items.length; i++) {
          const item = items[i]
          if (item.kind === 'file') {
            const file = item.getAsFile()
            if (file && file.type.startsWith('image/')) {
              imageFiles.push(file)
            }
          }
        }

        const html = clipboardData.getData('text/html')
        const dataUrlMatches: string[] = []
        if (html && html.includes('data:image')) {
          const regex = /<img[^>]+src=["'](data:image\/[^"']+)["']/gi
          let match: RegExpExecArray | null
          while ((match = regex.exec(html)) !== null) {
            if (match[1]) {
              dataUrlMatches.push(match[1])
            }
          }
        }

        if (!imageFiles.length && !dataUrlMatches.length) {
          return false
        }

        event.preventDefault()

        const docId = Number(documentId.value)
        if (!Number.isFinite(docId) || docId <= 0) {
          message.error('文档ID无效，无法上传粘贴的图片')
          return true
        }

        const uploadFile = async (file: File) => {
          try {
            const res = await documentApi.uploadDocumentImage(docId, file)
            if (res && res.code === 200 && res.data && res.data.url) {
              editorInstance.chain().focus().setImage({ src: res.data.url }).run()
            } else {
              message.error(res?.message || '上传粘贴图片失败')
            }
          } catch (error: any) {
            message.error(error?.message || '上传粘贴图片失败')
          }
        }

        imageFiles.forEach(file => {
          uploadFile(file)
        })

        dataUrlMatches.forEach(dataUrl => {
          fetch(dataUrl)
            .then(response => response.blob())
            .then(blob => {
              const file = new File([blob], 'pasted-image.png', {
                type: blob.type || 'image/png',
              })
              return uploadFile(file)
            })
            .catch(() => {
              message.error('解析粘贴的图片失败')
            })
        })

        return true
      },
    },
  })

  editor.value = editorInstance
  editorInstance.on('update', scheduleTocBuild)
  editorInstance.on('selectionUpdate', updateActiveToc)

  let seeded = false
  let seedRetry = 0
  let seedScheduled = false
  const trySeed = () => {
    if (seeded) return
    if (yXmlFragment.toString().length !== 0) return

    const clientIds = Array.from(_awareness.getStates().keys())
    if (clientIds.length === 1 && seedRetry === 0) {
      seedRetry = 1
      setTimeout(trySeed, 1500)
      return
    }

    const leaderClientId = clientIds.length > 0 ? Math.min(...clientIds) : _awareness.clientID
    if (_awareness.clientID !== leaderClientId) return

    seeded = true
    if (initialContent) {
      editorInstance.commands.setContent(initialContent)
    } else {
      editorInstance.commands.setContent('<h2>欢迎使用 Light Doc</h2><p>开始编辑您的文档...</p>')
    }
    scheduleTocBuild()
  }
  _provider.on('synced', (isSynced: boolean) => {
    if (isSynced) {
      hasSynced = true
    }
    if (!isSynced || seeded || seedScheduled) return
    seedScheduled = true
    setTimeout(() => {
      seedScheduled = false
      trySeed()
    }, 2000)
  })

  _ydoc.on('update', () => {
    scheduleAutosave()
  })
})

onUnmounted(() => {
  if (autosaveTimer) {
    clearTimeout(autosaveTimer)
    autosaveTimer = null
  }
  if (tocUpdateTimer) {
    clearTimeout(tocUpdateTimer)
    tocUpdateTimer = null
  }
  if (editor.value) {
    editor.value.destroy()
  }
  if (provider) {
    provider.destroy()
  }
  if (ydoc) {
    ydoc.destroy()
  }
  if (membersRefreshTimer) {
    clearInterval(membersRefreshTimer)
    membersRefreshTimer = null
  }
})

// ==================== 交互函数 ====================
const goBack = () => {
  router.back()
}

const toggleToc = () => {
  isTocVisible.value = !isTocVisible.value
}

const toggleRightSidebar = () => {
  isRightSidebarVisible.value = !isRightSidebarVisible.value
}

const switchRightTab = (tab: string) => {
  activeRightTab.value = tab
  if (tab === 'history') {
    loadVersions()
  } else if (tab === 'comments') {
    loadComments()
  }
}

const uint8ArrayToBase64 = (bytes: Uint8Array) => {
  let binary = ''
  const chunkSize = 0x8000
  for (let i = 0; i < bytes.length; i += chunkSize) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunkSize))
  }
  return btoa(binary)
}

const base64ToUint8Array = (base64: string) => {
  const binary = atob(base64)
  const len = binary.length
  const bytes = new Uint8Array(len)
  for (let i = 0; i < len; i++) {
    bytes[i] = binary.charCodeAt(i)
  }
  return bytes
}

const saveYjsSnapshot = async () => {
  if (!ydoc || autosaveInFlight) return
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return

  autosaveInFlight = true
  try {
    const stateUpdate = Y.encodeStateAsUpdate(ydoc)
    const base64State = uint8ArrayToBase64(stateUpdate)
    await documentApi.saveDocumentYjsState(docId, base64State)
  } finally {
    autosaveInFlight = false
  }
}

const scheduleAutosave = () => {
  if (!hasSynced) return
  if (autosaveTimer) {
    clearTimeout(autosaveTimer)
  }
  const intervalSeconds = settingsForm.value.autosaveEnabled
    ? settingsForm.value.autosaveIntervalSeconds || 5
    : 0
  if (!intervalSeconds || intervalSeconds <= 0) {
    return
  }
  autosaveTimer = setTimeout(() => {
    autosaveTimer = null
    saveYjsSnapshot()
  }, intervalSeconds * 1000)
}

const handleSave = async () => {
  if (!canEdit.value) {
    message.error('没有权限编辑此文档')
    return
  }
  if (!editor.value) return
  
  const proseMirrorJson = JSON.stringify(editor.value.getJSON())
  
  try {
    const docId = Number(documentId.value)

    if (ydoc) {
      const stateUpdate = Y.encodeStateAsUpdate(ydoc)
      const base64State = uint8ArrayToBase64(stateUpdate)
      const yjsResult = await documentApi.saveDocumentYjsState(docId, base64State)
      if (yjsResult.code !== 200) {
        message.error(yjsResult.message || '保存协同状态失败')
        return
      }
    }

    const result = await documentApi.updateDocumentJson(docId, proseMirrorJson)

    if (result.code === 200) {
      message.success('保存成功')
    } else {
      message.error(result.message || '保存失败')
    }
  } catch (e) {
    console.error('保存失败', e)
    message.error('保存发生错误')
  }
}

const downloadFile = (content: string, mime: string, extension: string) => {
  const encoder = new TextEncoder()
  const blob = new Blob([encoder.encode(content)], { type: `${mime};charset=utf-8` })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  const title = (documentTitle.value || '文档').trim() || '文档'
  link.href = url
  link.download = `${title}.${extension}`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

const exportAsJson = () => {
  if (!editor.value) return
  const json = editor.value.getJSON()
  const content = JSON.stringify(json, null, 2)
  downloadFile(content, 'application/json', 'json')
}

const serializeTextNodeToMarkdown = (node: any): string => {
  let text = String(node.text || '')
  const marks = node.marks || []

  for (const mark of marks) {
    const type = mark?.type
    if (type === 'code') {
      text = `\`${text}\``
    } else if (type === 'bold') {
      text = `**${text}**`
    } else if (type === 'italic') {
      text = `*${text}*`
    } else if (type === 'strike') {
      text = `~~${text}~~`
    } else if (type === 'link' && mark.attrs?.href) {
      const href = String(mark.attrs.href)
      text = `[${text}](${href})`
    }
  }

  return text
}

const serializeNodesToMarkdown = (nodes: any[] | undefined, parentType?: string): string => {
  if (!nodes || !nodes.length) return ''
  const parts: string[] = []

  for (const node of nodes) {
    if (!node) continue
    const type = node.type

    if (type === 'text') {
      parts.push(serializeTextNodeToMarkdown(node))
    } else if (type === 'paragraph') {
      const inner = serializeNodesToMarkdown(node.content || [], 'paragraph')
      parts.push(inner.trim())
    } else if (type === 'heading') {
      const level = Number(node.attrs?.level || 1)
      const hashes = '#'.repeat(Math.min(6, Math.max(1, level)))
      const inner = serializeNodesToMarkdown(node.content || [], 'heading').trim()
      parts.push(`${hashes} ${inner}`)
      parts.push('')
    } else if (type === 'bulletList') {
      for (const item of node.content || []) {
        if (!item || item.type !== 'listItem') continue
        const line = serializeNodesToMarkdown(item.content || [], 'listItem').trim()
        const lines = line.split('\n')
        if (!lines.length) continue
        parts.push(`- ${lines[0]}`)
        for (let i = 1; i < lines.length; i++) {
          parts.push(`  ${lines[i]}`)
        }
      }
      parts.push('')
    } else if (type === 'orderedList') {
      let index = Number(node.attrs?.start || 1)
      for (const item of node.content || []) {
        if (!item || item.type !== 'listItem') continue
        const line = serializeNodesToMarkdown(item.content || [], 'listItem').trim()
        const lines = line.split('\n')
        if (!lines.length) continue
        parts.push(`${index}. ${lines[0]}`)
        for (let i = 1; i < lines.length; i++) {
          parts.push(`   ${lines[i]}`)
        }
        index++
      }
      parts.push('')
    } else if (type === 'blockquote') {
      const inner = serializeNodesToMarkdown(node.content || [], 'blockquote')
      const lines = inner.split('\n')
      for (const line of lines) {
        if (line.trim()) {
          parts.push(`> ${line}`)
        } else {
          parts.push('>')
        }
      }
      parts.push('')
    } else if (type === 'codeBlock') {
      const language = String(node.attrs?.language || '').trim()
      const fence = '```'
      const codeText = (node.content || [])
        .map((c: any) => (c.type === 'text' ? String(c.text || '') : ''))
        .join('')
      const lines = codeText.split('\n')
      parts.push(language ? `${fence}${language}` : fence)
      for (const line of lines) {
        parts.push(line)
      }
      parts.push(fence)
      parts.push('')
    } else if (type === 'horizontalRule') {
      parts.push('---')
      parts.push('')
    } else if (type === 'image') {
      const src = String(node.attrs?.src || '').trim()
      const alt = String(node.attrs?.alt || '').trim()
      if (src) {
        parts.push(`![${alt}](${src})`)
        parts.push('')
      }
    } else if (type === 'hardBreak') {
      parts.push('')
    } else if (type === 'table') {
      for (const row of node.content || []) {
        if (!row || row.type !== 'tableRow') continue
        const cells: string[] = []
        for (const cell of row.content || []) {
          const cellText = serializeNodesToMarkdown(cell.content || [], 'tableCell').trim()
          cells.push(cellText.replace(/\|/g, '\\|'))
        }
        if (cells.length) {
          parts.push(`| ${cells.join(' | ')} |`)
        }
      }
      parts.push('')
    } else {
      const inner = serializeNodesToMarkdown(node.content || [], type)
      if (inner) {
        parts.push(inner)
        if (!parentType) {
          parts.push('')
        }
      }
    }
  }

  let result = parts.join('\n')
  result = result.replace(/\n{3,}/g, '\n\n')
  return result.trimEnd()
}

const exportAsMarkdown = () => {
  if (!editor.value) return
  const json = editor.value.getJSON()
  const markdown = serializeNodesToMarkdown(json.content || [], 'doc')
  downloadFile(markdown, 'text/markdown', 'md')
}

const createEditorFromSnapshot = (base64State: string) => {
  const doc = new Y.Doc()
  const update = base64ToUint8Array(base64State)
  Y.applyUpdate(doc, update)
  const yXmlFragment = doc.getXmlFragment('prosemirror')
  const yPlugin = Extension.create({
    name: 'yjsPreviewProseMirror',
    addProseMirrorPlugins() {
      return [ySyncPlugin(yXmlFragment)]
    },
  })

  return new Editor({
    extensions: [
      StarterKit.configure({
        undoRedo: false,
        codeBlock: false,
      }),
      CodeBlockWithTheme,
      CodeBlockLineNumbersExtension,
      Underline,
      TextStyleMark,
      SuperscriptMark,
      SubscriptMark,
      yPlugin,
      Link.configure({
        openOnClick: false,
        linkOnPaste: true,
        autolink: true,
        HTMLAttributes: {
          target: '_blank',
          rel: 'noopener noreferrer',
        },
      }),
      CustomImage.configure({
        inline: true,
        allowBase64: true,
      }),
      TextAlign.configure({
        types: ['heading', 'paragraph'],
      }),
      Table.configure({
        resizable: true,
      }),
      TableRow,
      TableHeader,
      TableCell,
    ],
    content: '',
    editable: false,
    editorProps: {
      attributes: {
        class: 'tiptap-editor-content',
      },
    },
  })
}

const handlePreviewVersion = async (item: DocumentVersionDTO) => {
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  versionPreviewTitle.value = `版本 ${item.versionNumber} 预览`
  versionPreviewVisible.value = true
  versionPreviewLoading.value = true

  if (previewVersionEditor.value) {
    previewVersionEditor.value.destroy()
    previewVersionEditor.value = null
  }

  try {
    const res = await documentApi.getDocumentVersionSnapshot(docId, item.versionNumber)
    if (res.code === 200 && res.data) {
      previewVersionEditor.value = createEditorFromSnapshot(res.data)
    } else {
      message.error(res.message || '加载版本内容失败')
    }
  } catch (e) {
    console.error('加载版本内容失败', e)
    message.error('加载版本内容失败')
  } finally {
    versionPreviewLoading.value = false
  }
}

const handleCompareWithCurrent = async (item: DocumentVersionDTO) => {
  const docId = Number(documentId.value)
  if (!Number.isFinite(docId) || docId <= 0) return
  if (!editor.value) {
    message.error('文档尚未初始化')
    return
  }

  versionCompareTitle.value = `版本 ${item.versionNumber} 与当前版本对比`
  versionCompareVisible.value = true
  versionCompareLoading.value = true

  if (compareVersionEditor.value) {
    compareVersionEditor.value.destroy()
    compareVersionEditor.value = null
  }
  if (currentVersionSnapshotEditor.value) {
    currentVersionSnapshotEditor.value.destroy()
    currentVersionSnapshotEditor.value = null
  }

  try {
    const snapshotRes = await documentApi.getDocumentVersionSnapshot(docId, item.versionNumber)
    if (snapshotRes.code === 200 && snapshotRes.data) {
      compareVersionEditor.value = createEditorFromSnapshot(snapshotRes.data)
    } else {
      message.error(snapshotRes.message || '加载历史版本内容失败')
      return
    }

    const currentJson = editor.value.getJSON()
    currentVersionSnapshotEditor.value = new Editor({
      extensions: [
        StarterKit.configure({
          undoRedo: false,
          codeBlock: false,
        }),
        CodeBlockWithTheme,
        CodeBlockLineNumbersExtension,
        Underline,
        TextStyleMark,
        SuperscriptMark,
        SubscriptMark,
        Link.configure({
          openOnClick: false,
          linkOnPaste: true,
          autolink: true,
          HTMLAttributes: {
            target: '_blank',
            rel: 'noopener noreferrer',
          },
        }),
        CustomImage.configure({
          inline: true,
          allowBase64: true,
        }),
        TextAlign.configure({
          types: ['heading', 'paragraph'],
        }),
        Table.configure({
          resizable: true,
        }),
        TableRow,
        TableHeader,
        TableCell,
      ],
      content: currentJson,
      editable: false,
      editorProps: {
        attributes: {
          class: 'tiptap-editor-content',
        },
      },
    })
  } catch (e) {
    console.error('加载对比内容失败', e)
    message.error('加载对比内容失败')
  } finally {
    versionCompareLoading.value = false
  }
}

watch(versionPreviewVisible, visible => {
  if (!visible && previewVersionEditor.value) {
    previewVersionEditor.value.destroy()
    previewVersionEditor.value = null
  }
})

watch(versionCompareVisible, visible => {
  if (!visible) {
    if (compareVersionEditor.value) {
      compareVersionEditor.value.destroy()
      compareVersionEditor.value = null
    }
    if (currentVersionSnapshotEditor.value) {
      currentVersionSnapshotEditor.value.destroy()
      currentVersionSnapshotEditor.value = null
    }
  }
})
</script>

<style scoped>
.document-editor-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #fff;
}

.editor-navbar {
  height: 56px;
  border-bottom: 1px solid #eee;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  background: #fff;
  z-index: 100;
}

.navbar-left, .navbar-center, .navbar-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.navbar-center {
  flex: 1;
  justify-content: center;
}

.nav-button {
  color: #666;
}

.nav-button.active {
  color: #1890ff;
  background: #e6f7ff;
}

.document-title-input {
  width: 300px;
  font-size: 16px;
  font-weight: 500;
  margin-left: 8px;
}

.editor-menubar {
  border-bottom: 1px solid #eee;
  background: #fcfcfc;
  z-index: 99;
  padding: 8px 0;
}

.editor-main-layout {
  flex: 1;
  display: flex;
  overflow: hidden;
  position: relative;
}

.toc-sidebar {
  width: 240px;
  border-right: 1px solid #eee;
  background: #fafafa;
  display: flex;
  flex-direction: column;
}

.toc-header {
  padding: 12px 16px;
  font-weight: 600;
  border-bottom: 1px solid #eee;
  display: flex;
  align-items: center;
  gap: 8px;
}

.toc-content {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
}

.toc-empty {
  color: #999;
  text-align: center;
  margin-top: 40px;
  font-size: 13px;
}

.toc-item {
  font-size: 13px;
  line-height: 1.6;
  color: #595959;
  padding: 4px 6px;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.2s, color 0.2s;
}

.toc-item:hover {
  background: #f0f5ff;
  color: #1677ff;
}

.toc-item.active {
  background: #e6f4ff;
  color: #1677ff;
  font-weight: 500;
}

.toc-item-text {
  display: inline-block;
  max-width: 100%;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.editor-content-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
  background: #fff;
}

.tiptap-editor-wrapper {
  flex: 1;
  overflow-y: auto;
  padding: 0;
}

.right-sidebar {
  width: 300px;
  border-left: 1px solid #eee;
  background: #fff;
  display: flex;
  flex-direction: column;
}

.right-sidebar-tabs {
  display: flex;
  border-bottom: 1px solid #eee;
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 12px 0;
  cursor: pointer;
  color: #666;
  font-size: 13px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  border-bottom: 2px solid transparent;
  transition: all 0.3s;
}

.tab-item:hover {
  color: #1890ff;
}

.tab-item.active {
  color: #1890ff;
  border-bottom-color: #1890ff;
  font-weight: 500;
}

.right-sidebar-content {
  flex: 1;
  overflow-y: auto;
  background: #fafafa;
}

.panel-content {
  padding: 16px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  font-weight: 600;
  font-size: 14px;
}

.team-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.team-member-item {
  display: flex;
  align-items: center;
  padding: 8px 0;
  gap: 12px;
}

.team-member-item + .team-member-item {
  border-top: 1px solid #f0f0f0;
}

.member-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.member-main {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.member-name {
  font-size: 13px;
  font-weight: 500;
  color: #333;
}

.member-permission-row {
  margin-top: 2px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.member-permission {
  font-size: 12px;
  color: #999;
}

.member-permission-select :deep(.ant-select-selector) {
  font-size: 12px;
  height: 22px !important;
}

.member-status {
  margin-left: 8px;
}

.member-status {
  margin-left: 8px;
  display: flex;
  align-items: center;
}

.member-avatar-clickable {
  cursor: pointer;
}

.member-detail {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.member-detail-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.member-detail-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.member-detail-name {
  font-weight: 500;
}

.member-detail-status {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #8c8c8c;
  font-size: 12px;
}

.member-detail-body {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-top: 8px;
  border-top: 1px solid #f0f0f0;
}

.member-detail-row {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
}

.member-detail-row .label {
  color: #8c8c8c;
}

.member-detail-row .value {
  color: #262626;
  max-width: 220px;
  text-align: right;
  word-break: break-all;
}

.member-detail-permission-select {
  text-align: left;
}

.member-detail-footer {
  margin-top: 8px;
}

.version-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.version-title-main {
  font-weight: 500;
}

.version-title-meta {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #8c8c8c;
  font-size: 12px;
}

.version-description {
  color: #595959;
  font-size: 13px;
  margin-top: 2px;
}

.comments-section {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.comments-list {
  flex: 1;
  overflow-y: auto;
  padding-right: 4px;
}

.comments-empty {
  padding: 40px 0;
}

.comment-thread {
  margin-bottom: 12px;
}

.chat-message {
  display: flex;
  align-items: flex-start;
  margin-bottom: 4px;
  gap: 8px;
}

.chat-message.is-self {
  flex-direction: row-reverse;
}

.chat-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: #1890ff;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  flex-shrink: 0;
}

.chat-avatar-small {
  width: 24px;
  height: 24px;
  font-size: 12px;
}

.chat-bubble-wrapper {
  max-width: 210px;
}

.chat-meta {
  display: flex;
  justify-content: flex-start;
  font-size: 12px;
  color: #8c8c8c;
}

.chat-author {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.chat-time {
  margin-left: 10px;
  margin-right: 10px;
  flex-shrink: 0;
}

.chat-bubble {
  margin-top: 2px;
  padding: 8px 10px;
  border-radius: 4px 12px 12px 12px;
  background: #f5f5f5;
  font-size: 13px;
  color: #262626;
  white-space: pre-wrap;
}

.chat-message.is-self .chat-bubble {
  background: #1890ff;
  color: #fff;
  border-radius: 12px 4px 12px 12px;
}

.chat-bubble-reply {
  background: #f0f5ff;
}

.chat-message.is-self .chat-bubble-reply {
  background: #e6f7ff;
}

.chat-actions {
  margin-top: 4px;
  text-align: left;
}

.comment-replies {
  margin-top: 8px;
  padding-left: 12px;
  border-left: 2px solid #f0f0f0;
}

.chat-reply-editor {
  margin-top: 8px;
}

.chat-reply-actions {
  margin-top: 4px;
  text-align: right;
}

.comment-editor {
  border-top: 1px solid #f0f0f0;
  padding-top: 12px;
}

.comment-editor-actions {
  margin-top: 8px;
  text-align: right;
}

.comment-no-permission {
  margin-top: 8px;
  font-size: 12px;
  color: #8c8c8c;
}

.status-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 6px;
}

.status-text {
  font-size: 12px;
  color: #666;
}

:deep(.tiptap-editor-content) {
  padding: 40px 60px;
  outline: none !important;
  min-height: 100%;
}

:deep(.ProseMirror) {
  outline: none !important;
}

:deep(.ProseMirror a) {
  color: #1890ff;
  text-decoration: underline;
}

:deep(.ProseMirror a:hover) {
  color: #1677ff;
}

:deep(.ProseMirror .tableWrapper) {
  overflow-x: auto;
}

:deep(.ProseMirror table) {
  border-collapse: collapse;
  table-layout: fixed;
  width: 100%;
  margin: 12px 0;
}

:deep(.ProseMirror td),
:deep(.ProseMirror th) {
  border: 1px solid #d9d9d9;
  padding: 6px 8px;
  vertical-align: top;
  min-width: 80px;
}

:deep(.ProseMirror th) {
  background: #fafafa;
  font-weight: 600;
}

:deep(.ProseMirror td p),
:deep(.ProseMirror th p) {
  margin: 0;
}
:deep(.ProseMirror pre) {
  position: relative;
  background-color: #0f172a;
  color: #e5e7eb;
  padding: 12px 14px 12px 44px;
  border-radius: 6px;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono',
    'Courier New', monospace;
  font-size: 13px;
  line-height: 1.6;
  overflow-x: auto;
  border: 1px solid #1e293b;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.3);
  margin: 12px 0;
}
:deep(.ProseMirror pre::before) {
  content: attr(data-line-numbers);
  position: absolute;
  top: 12px;
  bottom: 12px;
  left: 12px;
  width: 28px;
  padding-right: 6px;
  border-right: 1px solid rgba(148, 163, 184, 0.5);
  color: #64748b;
  text-align: right;
  white-space: pre;
  font-size: 12px;
  line-height: 1.6;
  pointer-events: none;
}
:deep(.ProseMirror pre::after) {
  content: attr(data-language);
  position: absolute;
  top: 8px;
  right: 12px;
  font-size: 11px;
  text-transform: uppercase;
  color: #9ca3af;
}
:deep(.ProseMirror pre[data-language='plaintext']::after) {
  content: '';
}
:deep(.ProseMirror pre[data-code-theme='light']) {
  background-color: #f5f5f5;
  color: #111827;
  border-color: #e5e7eb;
  box-shadow: none;
}
:deep(.ProseMirror pre[data-code-theme='light']::before) {
  border-right-color: rgba(148, 163, 184, 0.35);
  color: #9ca3af;
}
:deep(.ProseMirror pre[data-code-theme='bordered']) {
  background-color: #ffffff;
  color: #111827;
  border-color: #e5e7eb;
  box-shadow: none;
}
:deep(.ProseMirror pre code) {
  padding: 0;
  background: transparent;
}
:deep(.ProseMirror-yjs-cursor) {
  position: relative;
  margin-left: -1px;
  margin-right: -1px;
  border-left: 2px solid;
  border-right: 0;
  pointer-events: none;
  word-break: normal;
}

:deep(.ProseMirror-yjs-cursor__label) {
  position: absolute;
  top: -1.4em;
  left: -1px;
  font-size: 12px;
  font-weight: 700;
  line-height: 1;
  color: #000;
  background: transparent;
  padding: 0;
  border-radius: 0;
  user-select: none;
  white-space: nowrap;
  box-shadow: none;
}

:deep(.resizable-image-wrapper) {
  position: relative;
  display: inline-block;
}

:deep(.resizable-image-wrapper img) {
  display: block;
  max-width: 100%;
  height: auto;
}

:deep(.resizable-image-handle) {
  position: absolute;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #1890ff;
  border: 1px solid #fff;
  box-shadow: 0 0 0 1px rgba(24, 144, 255, 0.3);
  cursor: se-resize;
  opacity: 0;
  transition: opacity 0.15s;
}

:deep(.resizable-image-wrapper.has-selection .resizable-image-handle) {
  opacity: 1;
}

.version-preview-wrapper {
  min-height: 400px;
}

.readonly-preview :deep(.tiptap-editor-content) {
  padding: 24px 32px;
}

.version-compare-container {
  display: flex;
  gap: 16px;
  min-height: 400px;
}

.version-compare-column {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.version-compare-header {
  font-weight: 500;
  margin-bottom: 8px;
}

.version-compare-editor {
  flex: 1;
  overflow-y: auto;
}

.preview-empty {
  padding: 24px 0;
  text-align: center;
  color: #999;
}
</style>
