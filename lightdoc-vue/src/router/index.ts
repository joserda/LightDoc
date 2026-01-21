import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/home',
    component: () => import('@/views/home/HomeLayout.vue'),
    meta: {
      requiresAuth: true
    },
    children: [
      {
        path: '',
        name: 'Home',
        redirect: '/home/dashboard'
      },
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/home/Dashboard.vue'),
        meta: {
          requiresAuth: true
        }
      },
      {
        path: 'notifications',
        name: 'Notifications',
        component: () => import('@/views/home/Notifications.vue'),
        meta: {
          requiresAuth: true
        }
      },
      {
        path: 'my-documents',
        name: 'MyDocuments',
        component: () => import('@/views/document/MyDocuments.vue'),
        meta: {
          requiresAuth: true
        }
      },
      {
        path: 'all-documents',
        name: 'AllDocuments',
        component: () => import('@/views/document/MyDocuments.vue'),
        meta: {
          requiresAuth: true
        }
      },
      {
        path: 'shared-documents',
        name: 'SharedDocuments',
        component: () => import('@/views/document/MyDocuments.vue'),
        meta: {
          requiresAuth: true
        }
      },
      {
        path: 'favorites',
        name: 'Favorites',
        component: () => import('@/views/document/MyDocuments.vue'),
        meta: {
          requiresAuth: true
        }
      },
      {
        path: 'trash',
        name: 'Trash',
        component: () => import('@/views/document/MyDocuments.vue'),
        meta: {
          requiresAuth: true
        }
      },
      {
        path: 'knowledge-bases',
        name: 'KnowledgeBases',
        component: () => import('@/views/knowledge-base/List.vue'),
        meta: {
          requiresAuth: true
        }
      },
      {
        path: 'knowledge-base/:id',
        name: 'KnowledgeBaseDetail',
        component: () => import('@/views/knowledge-base/Detail.vue'),
        meta: {
          requiresAuth: true
        }
      }
    ]
  },
  {
    path: '/document/:id/edit',
    name: 'DocumentEditor',
    component: () => import('@/views/document/Editor.vue'),
    meta: {
      requiresAuth: true
    }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/Login.vue'),
    meta: {
      requiresAuth: false
    }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/auth/Register.vue'),
    meta: {
      requiresAuth: false
    }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, _from, next) => {
  const token = localStorage.getItem('token')
  const loginTime = localStorage.getItem('loginTime')
  
  // 检查是否在1小时内登录过（必须有token）
  if (loginTime && token) {
    const lastLogin = parseInt(loginTime)
    const now = Date.now()
    const oneHour = 60 * 60 * 1000
    
    if (now - lastLogin < oneHour) {
      // 在1小时内登录过，自动登录
      if (to.path === '/login' || to.path === '/register' || to.path === '/') {
        next('/home/dashboard')
        return
      }
    } else {
      // 超过1小时，清除登录时间
      localStorage.removeItem('loginTime')
    }
  }
  
  // 需要认证但没有token，跳转到登录页
  if (to.meta.requiresAuth && !token) {
    next('/login')
  } 
  // 已登录用户访问登录/注册页，跳转到首页
  else if ((to.path === '/login' || to.path === '/register') && token) {
    next('/home/dashboard')
  } 
  // 根路径处理
  else if (to.path === '/') {
    if (token) {
      next('/home/dashboard')
    } else {
      next('/login')
    }
  } 
  // 其他情况正常放行
  else {
    next()
  }
})

export default router
