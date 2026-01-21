<template>
  <div class="login-container">
    <div class="login-form-wrapper">
      <div class="login-header">
        <h1>LightDoc</h1>
        <p>在线文档协同编辑平台</p>
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
            placeholder="用户名"
            size="large"
          >
            <template #prefix>
              <UserOutlined />
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
        
        <a-form-item>
          <a-button
            type="primary"
            html-type="submit"
            size="large"
            :loading="loading"
            block
          >
            登录
          </a-button>
        </a-form-item>
      </a-form>
      
      <div class="login-footer">
        <span>还没有账号？</span>
        <a @click="goToRegister">立即注册</a>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { UserOutlined, LockOutlined } from '@ant-design/icons-vue'
import { authApi } from '@/api/auth'
import { storage } from '@/utils/storage'
import type { LoginForm } from '@/types'

const router = useRouter()
const loading = ref(false)

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
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-form-wrapper {
  width: 100%;
  max-width: 400px;
  padding: 40px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.login-header h1 {
  font-size: 32px;
  font-weight: bold;
  color: #1890ff;
  margin-bottom: 8px;
}

.login-header p {
  font-size: 14px;
  color: #666;
}

.login-form {
  margin-bottom: 24px;
}

.login-footer {
  text-align: center;
  font-size: 14px;
  color: #666;
}

.login-footer a {
  color: #1890ff;
  cursor: pointer;
}

.login-footer a:hover {
  text-decoration: underline;
}
</style>
