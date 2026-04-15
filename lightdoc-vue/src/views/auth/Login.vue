<template>
  <div class="login-container">
    <!-- 左侧：品牌展示区 -->
    <div class="login-brand-section">
      <div class="brand-content">
        <div class="brand-logo">
          <FileTextOutlined class="logo-icon" />
          <span class="logo-text">LightDoc</span>
        </div>
        <h1 class="brand-title">让协作更高效</h1>
        <p class="brand-desc">
          实时多人协作编辑<br>
          随时随地开启文档创作之旅
        </p>
        <div class="feature-list">
          <div class="feature-item">
            <TeamOutlined />
            <span>多人实时协作</span>
          </div>
          <div class="feature-item">
            <HistoryOutlined />
            <span>版本历史记录</span>
          </div>
          <div class="feature-item">
            <SafetyOutlined />
            <span>安全权限管理</span>
          </div>
        </div>
      </div>
      <div class="brand-decoration">
        <div class="decoration-card card-1"></div>
        <div class="decoration-card card-2"></div>
        <div class="decoration-card card-3"></div>
      </div>
    </div>

    <!-- 右侧：登录表单区 -->
    <div class="login-form-section">
      <div class="form-wrapper">
        <div class="form-header">
          <h2>欢迎回来</h2>
          <p>登录您的账号，开始协作编辑</p>
        </div>

        <a-form
          :model="formState"
          :rules="rules"
          @finish="handleLogin"
          class="login-form"
        >
          <a-form-item name="username">
            <a-input
              v-model:value="formState.username"
              placeholder="请输入用户名"
              size="large"
            >
              <template #prefix>
                <UserOutlined class="input-icon" />
              </template>
            </a-input>
          </a-form-item>

          <a-form-item name="password">
            <a-input-password
              v-model:value="formState.password"
              placeholder="请输入密码"
              size="large"
            >
              <template #prefix>
                <LockOutlined class="input-icon" />
              </template>
            </a-input-password>
          </a-form-item>

          <div class="form-options">
            <a-checkbox v-model:checked="rememberMe">记住我</a-checkbox>
            <a class="forgot-link">忘记密码？</a>
          </div>

          <a-form-item>
            <a-button
              type="primary"
              html-type="submit"
              size="large"
              :loading="loading"
              block
              class="login-btn"
            >
              登 录
            </a-button>
          </a-form-item>
        </a-form>

        <div class="register-hint">
          <span>还没有账号？</span>
          <a @click="goToRegister">立即注册</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import {
  UserOutlined,
  LockOutlined,
  FileTextOutlined,
  TeamOutlined,
  HistoryOutlined,
  SafetyOutlined
} from '@ant-design/icons-vue'
import { authApi } from '@/api/auth'
import { storage } from '@/utils/storage'
import type { LoginForm } from '@/types'

const router = useRouter()
const loading = ref(false)
const rememberMe = ref(false)

const formState = reactive<LoginForm>({
  username: '',
  password: ''
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  loading.value = true
  try {
    const response = await authApi.login(formState)
    if (response.code === 200 && response.data) {
      storage.setToken(response.data.token)
      storage.setUser(response.data.user)
      storage.setLoginTime()
      message.success('登录成功')
      router.push('/home/dashboard')
    } else {
      message.error(response.message || '登录失败')
    }
  } catch (error) {
    message.error('登录失败，请检查网络连接')
  } finally {
    loading.value = false
  }
}

const goToRegister = () => {
  router.push('/register')
}
</script>

<style scoped>
.login-container {
  display: flex;
  min-height: 100vh;
}

/* 左侧品牌区 */
.login-brand-section {
  flex: 1;
  background: linear-gradient(135deg, #1a3a5c 0%, #2d5a87 50%, #1a3a5c 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  padding: 60px;
}

.brand-content {
  position: relative;
  z-index: 2;
  color: white;
  max-width: 480px;
}

.brand-logo {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 48px;
}

.logo-icon {
  font-size: 42px;
  color: #64b5f6;
}

.logo-text {
  font-size: 32px;
  font-weight: 700;
  letter-spacing: 2px;
}

.brand-title {
  font-size: 48px;
  font-weight: 700;
  margin-bottom: 20px;
  line-height: 1.2;
}

.brand-desc {
  font-size: 18px;
  opacity: 0.85;
  line-height: 1.8;
  margin-bottom: 48px;
}

.feature-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 16px;
  opacity: 0.9;
}

.feature-item :deep(.anticon) {
  font-size: 22px;
  color: #64b5f6;
}

/* 装饰卡片 */
.brand-decoration {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.decoration-card {
  position: absolute;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.15);
}

.card-1 {
  width: 280px;
  height: 180px;
  top: 15%;
  left: 10%;
  transform: rotate(-8deg);
}

.card-2 {
  width: 200px;
  height: 140px;
  bottom: 20%;
  left: 5%;
  transform: rotate(5deg);
}

.card-3 {
  width: 160px;
  height: 100px;
  top: 25%;
  right: 15%;
  transform: rotate(-12deg);
  background: rgba(100, 181, 246, 0.15);
}

/* 右侧表单区 */
.login-form-section {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8fafc;
  padding: 40px;
}

.form-wrapper {
  width: 100%;
  max-width: 420px;
}

.form-header {
  margin-bottom: 40px;
}

.form-header h2 {
  font-size: 28px;
  font-weight: 600;
  color: #1a1a2e;
  margin-bottom: 8px;
}

.form-header p {
  font-size: 15px;
  color: #6b7280;
}

.login-form :deep(.ant-input-affix-wrapper) {
  border-radius: 8px;
  padding: 12px 16px;
}

.login-form :deep(.ant-input) {
  font-size: 15px;
}

.input-icon {
  color: #9ca3af;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.forgot-link {
  font-size: 14px;
  color: #3b82f6;
  cursor: pointer;
}

.forgot-link:hover {
  color: #2563eb;
}

.login-btn {
  height: 48px;
  font-size: 16px;
  font-weight: 500;
  background: linear-gradient(135deg, #1a3a5c 0%, #2d5a87 100%);
  border: none;
  border-radius: 8px;
  transition: all 0.3s;
}

.login-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(26, 58, 92, 0.35);
}

.register-hint {
  text-align: center;
  margin-top: 32px;
  font-size: 14px;
  color: #6b7280;
}

.register-hint a {
  color: #3b82f6;
  font-weight: 500;
  margin-left: 4px;
  cursor: pointer;
}

.register-hint a:hover {
  color: #2563eb;
  text-decoration: underline;
}

/* 响应式适配 */
@media (max-width: 1024px) {
  .login-brand-section {
    display: none;
  }

  .login-form-section {
    flex: none;
    width: 100%;
  }
}

@media (max-width: 480px) {
  .login-form-section {
    padding: 24px;
  }

  .form-wrapper {
    padding: 0;
  }
}
</style>
