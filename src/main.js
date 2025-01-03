import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import App from './App.vue'
import router from './router'
import { useThemeStore } from '@/store/theme'
import './index.css'
import icons from './plugins/icons'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(ElementPlus)
app.use(icons)

// 初始化主题
const themeStore = useThemeStore()
themeStore.initTheme()

app.mount('#app') 