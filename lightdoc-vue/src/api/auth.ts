import request from '@/utils/request'
import type { LoginForm, RegisterForm, ApiResponse, LoginResponse } from '@/types'

/**
 * 用户信息接口
 */
export interface UserInfo {
  id: number
  username: string
  email: string
  nickname?: string
  avatar?: string
  status?: number
  role?: string
}

export const authApi = {
  login(data: LoginForm) {
    return request.post<ApiResponse<LoginResponse>>('/auth/login', data)
  },
  
  register(data: RegisterForm) {
    return request.post<ApiResponse>('/auth/register', data)
  },
  
  getCurrentUser() {
    return request.get<ApiResponse>('/auth/me')
  },

  /**
   * 搜索用户
   */
  searchUsers(params: {
    keyword?: string
    excludeIds?: string
  }) {
    return request.get<ApiResponse<UserInfo[]>>('/users/search', { params })
  }
}
