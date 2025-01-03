<template>
  <el-container class="h-screen">
    <el-header class="bg-white border-b">
      <div class="flex justify-between items-center h-full">
        <h1 class="text-xl font-bold">实训管理平台</h1>
        <el-dropdown @command="handleCommand">
          <span class="cursor-pointer">
            {{ user?.email }}
            <el-icon class="el-icon--right"><arrow-down /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </el-header>
    <slot></slot>
  </el-container>
</template>

<script setup>
import { ArrowDown } from '@element-plus/icons-vue'
import { useMainStore } from '@/store'
import { useRouter } from 'vue-router'
import { supabase } from '@/services/supabase'
import { storeToRefs } from 'pinia'

const store = useMainStore()
const router = useRouter()
const { user } = storeToRefs(store)

const handleCommand = async (command) => {
  if (command === 'logout') {
    await supabase.auth.signOut()
    store.setUser(null)
    localStorage.removeItem('user')
    router.push('/login')
  }
}
</script> 