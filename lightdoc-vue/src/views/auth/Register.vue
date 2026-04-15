<template>
  <div class="register-container">
    <!-- 左侧：品牌展示区 -->
    <div class="register-brand-section">
      <div class="brand-content">
        <div class="brand-logo">
          <FileTextOutlined class="logo-icon" />
          <span class="logo-text">LightDoc</span>
        </div>
        <h1 class="brand-title">开启协作之旅</h1>
        <p class="brand-desc">
          多人实时编辑<br>
          让创作更高效、更自由
        </p>
        <div class="feature-list">
          <div class="feature-item">
            <EditOutlined />
            <span>富文本编辑器</span>
          </div>
          <div class="feature-item">
            <CloudServerOutlined />
            <span>云端实时保存</span>
          </div>
          <div class="feature-item">
            <ShareAltOutlined />
            <span>一键分享协作</span>
          </div>
        </div>
      </div>
      <div class="brand-decoration">
        <div class="decoration-card card-1"></div>
        <div class="decoration-card card-2"></div>
        <div class="decoration-card card-3"></div>
      </div>
    </div>

    <!-- 右侧：注册表单区 -->
    <div class="register-form-section">
      <div class="form-wrapper">
        <div class="form-header">
          <h2>创建账户</h2>
          <p>加入 LightDoc，开始协作编辑</p>
        </div>

        <a-form
          :model="formState"
          :rules="rules"
          @finish="handleRegister"
          class="register-form"
        >
          <a-form-item name="username">
            <a-input
              v-model:value="formState.username"
              placeholder="请输入用户名（3-20个字符）"
              size="large"
            >
              <template #prefix>
                <UserOutlined class="input-icon" />
              </template>
            </a-input>
          </a-form-item>

          <a-form-item name="email">
            <a-input
              v-model:value="formState.email"
              placeholder="请输入邮箱地址"
              size="large"
            >
              <template #prefix>
                <MailOutlined class="input-icon" />
              </template>
            </a-input>
          </a-form-item>

          <a-form-item name="password">
            <a-input-password
              v-model:value="formState.password"
              placeholder="请输入密码（6-20个字符）"
              size="large"
            >
              <template #prefix>
                <LockOutlined class="input-icon" />
              </template>
            </a-input-password>
          </a-form-item>

          <a-form-item name="confirmPassword">
            <a-input-password
              v-model:value="formState.confirmPassword"
              placeholder="请再次输入密码"
              size="large"
            >
              <template #prefix>
                <SafetyOutlined class="input-icon" />
              </template>
            </a-input-password>
          </a-form-item>

          <a-form-item>
            <a-button
              type="primary"
              html-type="submit"
              size="large"
              :loading="loading"
              block
              class="register-btn"
            >
              注 册
            </a-button>
          </a-form-item>
        </a-form>

        <div class="login-hint">
          <span>已有账号？</span>
          <a @click="goToLogin">立即登录</a>
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
  MailOutlined,
  SafetyOutlined,
  FileTextOutlined,
  EditOutlined,
  CloudServerOutlined,
  ShareAltOutlined
} from '@ant-design/icons-vue'
import { authApi } from '@/api/auth'
import type { RegisterForm } from '@/types'

const router = useRouter()
const loading = ref(false)

const formState = reactive<RegisterForm>({
  username: '',
  email: '',
  password: '',
  confirmPassword: ''
})

const validateConfirmPassword = async (_rule: any, value: string) => {
  if (!value) {
    return Promise.reject('请确认密码')
  }
  if (value !== formState.password) {
    return Promise.reject('两次输入的密码不一致')
  }
  return Promise.resolve()
}

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在3-20个字符之间', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入有效的邮箱地址', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在6-20个字符之间', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const handleRegister = async () => {
  loading.value = true
  try {
    const response = await authApi.register(formState)
    if (response.code === 200) {
      message.success('注册成功，请登录')
      router.push('/login')
    } else {
      message.error(response.message || '注册失败')
    }
  } catch (error) {
    message.error('注册失败，请检查网络连接')
  } finally {
    loading.value = false
  }
}

const goToLogin = () => {
  router.push('/login')
}
</script>

<style scoped>
.register-container {
  display: flex;
  min-height: 100vh;
}

/* 左侧品牌区 */
.register-brand-section {
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
.register-form-section {
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
  margin-bottom: 32px;
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

.register-form :deep(.ant-input-affix-wrapper) {
  border-radius: 8px;
  padding: 12px 16px;
}

.register-form :deep(.ant-input) {
  font-size: 15px;
}

.input-icon {
  color: #9ca3af;
}

.register-btn {
  height: 48px;
  font-size: 16px;
  font-weight: 500;
  background: linear-gradient(135deg, #1a3a5c 0%, #2d5a87 100%);
  border: none;
  border-radius: 8px;
  transition: all 0.3s;
}

.register-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(26, 58, 92, 0.35);
}

.login-hint {
  text-align: center;
  margin-top: 24px;
  font-size: 14px;
  color: #6b7280;
}

.login-hint a {
  color: #3b82f6;
  font-weight: 500;
  margin-left: 4px;
  cursor: pointer;
}

.login-hint a:hover {
  color: #2563eb;
  text-decoration: underline;
}

/* 响应式适配 */
@media (max-width: 1024px) {
  .register-brand-section {
    display: none;
  }

  .register-form-section {
    flex: none;
    width: 100%;
  }
}

@media (max-width: 480px) {
  .register-form-section {
    padding: 24px;
  }

  .form-wrapper {
    padding: 0;
  }
}
</style>
