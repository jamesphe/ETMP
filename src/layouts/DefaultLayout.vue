<template>
  <el-container class="layout-container">
    <el-aside width="200px">
      <el-menu
        :default-active="activeMenu"
        router
        :collapse="isCollapse"
      >
        <template v-for="(item, index) in menuItems" :key="index">
          <!-- 有子菜单的情况 -->
          <el-sub-menu v-if="item.children" :index="item.path || String(index)">
            <template #title>
              <el-icon>
                <component :is="item.icon" />
              </el-icon>
              <span>{{ item.title }}</span>
            </template>
            <el-menu-item 
              v-for="child in item.children"
              :key="child.path"
              :index="child.path"
            >
              <el-icon>
                <component :is="child.icon" />
              </el-icon>
              <span>{{ child.title }}</span>
            </el-menu-item>
          </el-sub-menu>
          
          <!-- 没有子菜单的情况 -->
          <el-menu-item v-else :index="item.path">
            <el-icon>
              <component :is="item.icon" />
            </el-icon>
            <span>{{ item.title }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>
    
    <el-container>
      <el-header>
        <div class="header-left">
          <el-button @click="toggleCollapse">
            <el-icon>
              <component :is="isCollapse ? 'Expand' : 'Fold'" />
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

const route = useRoute()
const isCollapse = ref(false)
const activeMenu = computed(() => route.path)

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.el-aside {
  background-color: #304156;
}

.el-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #fff;
  border-bottom: 1px solid #dcdfe6;
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
</style> 