export interface LoginForm {
  username: string
  password: string
}

export interface RegisterForm {
  username: string
  email: string
  password: string
  confirmPassword: string
}

export interface User {
  id: number
  username: string
  email: string
  nickname?: string
  avatar?: string
  status?: number
  role?: string
}

export interface LoginResponse {
  token: string
  user: User
}

export interface ApiResponse<T = any> {
  code: number
  message: string
  data?: T
}