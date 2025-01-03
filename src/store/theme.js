import { defineStore } from 'pinia'
import { applyTheme } from '@/styles/theme'

export const useThemeStore = defineStore('theme', {
  state: () => ({
    currentTheme: localStorage.getItem('theme') || 'light'
  }),
  
  actions: {
    setTheme(theme) {
      this.currentTheme = theme
      localStorage.setItem('theme', theme)
      applyTheme(theme)
    },
    
    initTheme() {
      applyTheme(this.currentTheme)
    }
  }
}) 