<template>
  <el-container class="layout-container">
    <el-aside :width="isCollapse ? '64px' : '240px'" class="aside">
      <div class="logo">
        <h1 v-show="!isCollapse">实训管理平台</h1>
        <el-icon v-show="isCollapse"><School /></el-icon>
      </div>
      <el-menu
        :default-active="activeMenu"
        router
        :collapse="isCollapse"
        class="border-none font-medium"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <template v-for="item in menuItems" :key="item.path || item.title">
          <template v-if="item.children">
            <el-sub-menu :index="item.path || item.title">
              <template #title>
                <el-icon>
                  <component :is="ElementPlusIconsVue[item.icon]" />
                </el-icon>
                <span>{{ item.title }}</span>
              </template>
              
              <template v-for="subItem in item.children" :key="subItem.path || subItem.title">
                <el-sub-menu 
                  v-if="subItem.children" 
                  :index="subItem.path || subItem.title"
                >
                  <template #title>
                    <el-icon>
                      <component :is="ElementPlusIconsVue[subItem.icon]" />
                    </el-icon>
                    <span>{{ subItem.title }}</span>
                  </template>
                  
                  <el-menu-item 
                    v-for="child in subItem.children"
                    :key="child.path"
                    :index="child.path"
                  >
                    <el-icon>
                      <component :is="ElementPlusIconsVue[child.icon]" />
                    </el-icon>
                    <span>{{ child.title }}</span>
                  </el-menu-item>
                </el-sub-menu>
                
                <el-menu-item
                  v-else
                  :index="subItem.path"
                >
                  <el-icon>
                    <component :is="ElementPlusIconsVue[subItem.icon]" />
                  </el-icon>
                  <span>{{ subItem.title }}</span>
                </el-menu-item>
              </template>
            </el-sub-menu>
          </template>
          
          <el-menu-item 
            v-else 
            :index="item.path"
          >
            <el-icon>
              <component :is="ElementPlusIconsVue[item.icon]" />
            </el-icon>
            <span>{{ item.title }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>
    
    <el-container>
      <el-header>
        <div class="header-left">
          <el-button type="text" @click="toggleCollapse">
            <el-icon :size="20">
              <component :is="ElementPlusIconsVue[isCollapse ? 'Expand' : 'Fold']" />
            </el-icon>
          </el-button>
          <breadcrumb />
        </div>
        <div class="header-right">
          <user-dropdown />
        </div>
      </el-header>
      
      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { menuItems } from '@/config/menuConfig'
import Breadcrumb from '@/components/Breadcrumb.vue'
import UserDropdown from '@/components/UserDropdown.vue'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import { h } from 'vue'

// 创建图标组件渲染函数
const Icon = (props) => {
  const { icon } = props
  return h(ElementPlusIconsVue[icon])
}

const route = useRoute()
const isCollapse = ref(false)
const activeMenu = computed(() => route.path)

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

const handleSelect = (index) => {
  activeMenu.value = index
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.aside {
  background-color: #304156;
  transition: width 0.3s;
  display: flex;
  flex-direction: column;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #2b3648;
  color: #fff;
  padding: 0 20px;
  overflow: hidden;
}

.logo h1 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  white-space: nowrap;
}

.el-menu {
  border-right: none;
  --el-menu-item-height: 48px;
}

.menu-item {
  margin: 4px 0;
  border-radius: 6px;
}

.el-menu-item.is-active {
  font-weight: 600;
}

.el-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #fff;
  border-bottom: 1px solid #dcdfe6;
  padding: 0 20px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-right {
  display: flex;
  align-items: center;
}

/* 修复菜单图标对齐问题 */
:deep(.el-menu--collapse) {
  .el-sub-menu__title span,
  .el-menu-item span {
    display: none;
  }
  
  .el-menu-item .el-icon,
  .el-sub-menu__title .el-icon {
    margin: 0;
  }
}
</style> 