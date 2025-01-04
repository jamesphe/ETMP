<template>
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