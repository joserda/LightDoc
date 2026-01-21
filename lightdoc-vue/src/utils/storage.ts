export const storage = {
  setToken(token: string) {
    localStorage.setItem('token', token)
  },
  
  getToken() {
    return localStorage.getItem('token')
  },
  
  removeToken() {
    localStorage.removeItem('token')
  },
  
  setUser(user: any) {
    localStorage.setItem('user', JSON.stringify(user))
  },
  
  getUser() {
    const user = localStorage.getItem('user')
    if (!user || user === 'undefined') {
      return null
    }
    try {
      return JSON.parse(user)
    } catch (error) {
      console.error('解析用户信息失败:', error)
      return null
    }
  },
  
  removeUser() {
    localStorage.removeItem('user')
  },
  
  setLoginTime() {
    localStorage.setItem('loginTime', Date.now().toString())
  },
  
  getLoginTime() {
    const loginTime = localStorage.getItem('loginTime')
    return loginTime ? parseInt(loginTime) : null
  },
  
  removeLoginTime() {
    localStorage.removeItem('loginTime')
  },
  
  clear() {
    localStorage.clear()
  }
}
