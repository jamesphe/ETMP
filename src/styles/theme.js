export const themes = {
  light: {
    // 主色调
    'primary': '#1890ff',
    'success': '#52c41a',
    'warning': '#faad14',
    'danger': '#ff4d4f',
    
    // 背景色系
    'bg-base': '#f0f2f5',      // 基础背景色
    'bg-container': '#ffffff', // 容器背景色
    'bg-sidebar': '#ffffff',   // 侧边栏背景色
    'bg-header': '#ffffff',    // 顶栏背景色
    
    // 文字色系
    'text-primary': '#000000d9',  // 主要文字
    'text-secondary': '#00000073', // 次要文字
    'text-disabled': '#00000040',  // 禁用文字
    'text-inverse': '#ffffff',     // 反色文字(用于深色背景)
    
    // 边框和分割线
    'border-base': '#d9d9d9',     // 基础边框色
    'border-split': '#f0f0f0',    // 分割线颜色
    
    // 特殊场景
    'shadow': '0 2px 8px #00000026',  // 阴影
    'hover': '#f5f5f5',              // 悬浮背景
    'mask': '#00000073',             // 遮罩层
    
    // 菜单专用色系
    'menu-text': '#000000d9',       // 菜单文字颜色
    'menu-active-text': '#1890ff',  // 菜单激活文字颜色
    'menu-hover-bg': '#f5f5f5',     // 菜单悬浮背景
    'menu-active-bg': '#e6f7ff',    // 菜单激活背景
  },
  
  dark: {
    // 主色调
    'primary': '#177ddc',
    'success': '#49aa19',
    'warning': '#d89614',
    'danger': '#dc4446',
    
    // 背景色系
    'bg-base': '#000000',      // 基础背景色
    'bg-container': '#141414', // 容器背景色
    'bg-sidebar': '#001529',   // 侧边栏背景色
    'bg-header': '#141414',    // 顶栏背景色
    
    // 文字色系
    'text-primary': '#ffffffd9',  // 主要文字
    'text-secondary': '#ffffff73', // 次要文字
    'text-disabled': '#ffffff40',  // 禁用文字
    'text-inverse': '#000000',     // 反色文字(用于浅色背景)
    
    // 边框和分割线
    'border-base': '#434343',     // 基础边框色
    'border-split': '#303030',    // 分割线颜色
    
    // 特殊场景
    'shadow': '0 2px 8px #ffffff26',  // 阴影
    'hover': '#ffffff1a',             // 悬浮背景
    'mask': '#ffffff73',              // 遮罩层
    
    // 菜单专用色系
    'menu-text': '#ffffff',         // 菜单文字颜色
    'menu-active-text': '#177ddc',  // 菜单激活文字颜色
    'menu-hover-bg': '#ffffff1a',   // 菜单悬浮背景
    'menu-active-bg': '#177ddc1a',  // 菜单激活背景
  }
}

// CSS 变量前缀
const prefix = '--theme-'

// 生成 CSS 变量
export function generateThemeVars(theme) {
  const vars = {}
  for (const [key, value] of Object.entries(themes[theme])) {
    vars[`${prefix}${key}`] = value
  }
  return vars
}

// 应用主题
export function applyTheme(theme) {
  const vars = generateThemeVars(theme)
  const root = document.documentElement
  
  for (const [key, value] of Object.entries(vars)) {
    root.style.setProperty(key, value)
  }
  
  // 设置 body 的主题类名
  document.body.className = `theme-${theme}`
  
  // 设置 element-plus 的内置主题变量
  setElementThemeVars(theme)
}

// 设置 Element Plus 主题变量
function setElementThemeVars(theme) {
  const vars = themes[theme]
  const root = document.documentElement
  
  // Element Plus 颜色变量映射
  root.style.setProperty('--el-color-primary', vars.primary)
  root.style.setProperty('--el-color-success', vars.success)
  root.style.setProperty('--el-color-warning', vars.warning)
  root.style.setProperty('--el-color-danger', vars.danger)
  
  // 菜单相关变量
  root.style.setProperty('--el-menu-bg-color', vars['bg-sidebar'])
  root.style.setProperty('--el-menu-text-color', vars['menu-text'])
  root.style.setProperty('--el-menu-hover-bg-color', vars['menu-hover-bg'])
  root.style.setProperty('--el-menu-active-color', vars['menu-active-text'])
  root.style.setProperty('--el-menu-item-hover-fill', vars['menu-hover-bg'])
  
  if (theme === 'dark') {
    root.style.setProperty('--el-bg-color', vars['bg-container'])
    root.style.setProperty('--el-text-color-primary', vars['text-primary'])
    root.style.setProperty('--el-border-color', vars['border-base'])
  } else {
    root.style.setProperty('--el-bg-color', vars['bg-container'])
    root.style.setProperty('--el-text-color-primary', vars['text-primary'])
    root.style.setProperty('--el-border-color', vars['border-base'])
  }
} 