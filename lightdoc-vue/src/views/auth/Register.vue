<template>
  <div class="register-container">
    <div class="register-form-wrapper">
      <div class="register-header">
        <h1>LightDoc</h1>
        <p>创建您的账户</p>
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
            placeholder="用户名"
            size="large"
          >
            <template #prefix>
              <UserOutlined />
            </template>
          </a-input>
        </a-form-item>
        
        <a-form-item name="email">
          <a-input
            v-model:value="formState.email"
            placeholder="邮箱"
            size="large"
          >
            <template #prefix>
              <MailOutlined />
            </template>
          </a-input>
        </a-form-item>
        
        <a-form-item name="password">
          <a-input-password
            v-model:value="formState.password"
            placeholder="密码"
            size="large"
          >
            <template #prefix>
              <LockOutlined />
            </template>
          </a-input-password>
        </a-form-item>
        
        <a-form-item name="confirmPassword">
          <a-input-password
            v-model:value="formState.confirmPassword"
            placeholder="确认密码"
            size="large"
          >
            <template #prefix>
              <LockOutlined />
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
          >
            注册
          </a-button>
        </a-form-item>
      </a-form>
      
      <div class="register-footer">
        <span>已有账号？</span>
        <a @click="goToLogin">立即登录</a>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { UserOutlined, LockOutlined, MailOutlined } from '@ant-design/icons-vue'
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
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.register-form-wrapper {
  width: 100%;
  max-width: 400px;
  padding: 40px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.register-header {
  text-align: center;
  margin-bottom: 40px;
}

.register-header h1 {
  font-size: 32px;
  font-weight: bold;
  color: #1890ff;
  margin-bottom: 8px;
}

.register-header p {
  font-size: 14px;
  color: #666;
}

.register-form {
  margin-bottom: 24px;
}

.register-footer {
  text-align: center;
  font-size: 14px;
  color: #666;
}

.register-footer a {
  color: #1890ff;
  cursor: pointer;
}

.register-footer a:hover {
  text-decoration: underline;
}
</style>
