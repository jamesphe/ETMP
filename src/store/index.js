import { defineStore } from 'pinia'

export const useMainStore = defineStore('main', {
  state: () => ({
    user: null,
    isAuthenticated: false,
    loading: false
  }),
  
  actions: {
    setUser(user) {
      this.user = user
      this.isAuthenticated = !!user
    },
    
    setLoading(status) {
      this.loading = status
    }
  }
}) 