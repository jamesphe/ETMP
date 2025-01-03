<template>
  <div class="login min-h-screen flex items-center justify-center bg-gray-100">
    <el-card class="w-96">
      <template #header>
        <h2 class="text-xl font-bold text-center">登录</h2>
      </template>
      <el-form :model="loginForm" @submit.prevent="handleLogin">
        <el-form-item>
          <el-input v-model="loginForm.email" placeholder="邮箱" />
        </el-form-item>
        <el-form-item v-if="!useMagicLink">
          <el-input v-model="loginForm.password" type="password" placeholder="密码" />
        </el-form-item>
        <el-button 
          v-if="!useMagicLink" 
          type="primary" 
          class="w-full mb-2" 
          :loading="loading" 
          @click="handleLogin"
        >
          密码登录
        </el-button>
        <el-button 
          type="success" 
          class="w-full" 
          :loading="loading" 
          @click="handleMagicLink"
        >
          {{ useMagicLink ? '发送登录链接' : '使用邮箱链接登录' }}
        </el-button>
        <div class="text-center mt-4">
          <a href="#" class="text-blue-500 mr-4" @click.prevent="toggleLoginMethod">
            {{ useMagicLink ? '使用密码登录' : '使用邮箱链接登录' }}
          </a>
          <router-link to="/register" class="text-blue-500">没有账号？去注册</router-link>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useMainStore } from '@/store'
import { supabase, checkSession } from '@/services/supabase'
import { ElMessage } from 'element-plus'

const router = useRouter()
const store = useMainStore()
const loading = ref(false)
const useMagicLink = ref(false)

const loginForm = ref({
  email: '',
  password: ''
})

const toggleLoginMethod = () => {
  useMagicLink.value = !useMagicLink.value
}

const handleMagicLink = async () => {
  if (!loginForm.value.email) {
    ElMessage.warning('请输入邮箱')
    return
  }

  try {
    loading.value = true
    const { error } = await supabase.auth.signInWithOtp({
      email: loginForm.value.email
    })
    
    if (error) throw error
    
    ElMessage.success('登录链接已发送到您的邮箱，请查收')
  } catch (error) {
    console.error('Magic link error:', error)
    ElMessage.error('发送登录链接失败，请稍后重试')
  } finally {
    loading.value = false
  }
}

const handleLogin = async () => {
  if (!loginForm.value.email || !loginForm.value.password) {
    ElMessage.warning('请输入邮箱和密码')
    return
  }

  try {
    loading.value = true
    store.setLoading(true)

    // 先检查当前会话
    const { session: currentSession } = await checkSession()
    if (currentSession) {
      console.log('Found existing session, signing out first')
      await supabase.auth.signOut()
    }

    console.log('Login attempt:', {
      email: loginForm.value.email,
      passwordLength: loginForm.value.password.length,
      timestamp: new Date().toISOString()
    })

    const { data, error } = await supabase.auth.signInWithPassword({
      email: loginForm.value.email,
      password: loginForm.value.password
    })
    
    if (error) {
      console.error('Login error details:', {
        message: error.message,
        status: error.status,
        name: error.name,
        timestamp: new Date().toISOString()
      })
      throw error
    }
    
    console.log('Login successful:', {
      userId: data.user?.id,
      hasSession: !!data.session,
      timestamp: new Date().toISOString()
    })
    
    store.setUser(data.user)
    localStorage.setItem('user', JSON.stringify(data.user))
    ElMessage.success('登录成功')
    router.push('/dashboard')
  } catch (error) {
    console.error('Login error:', {
      name: error.name,
      message: error.message,
      status: error?.status,
      timestamp: new Date().toISOString()
    })
    ElMessage.error(error.message === 'Invalid login credentials'
      ? '邮箱或密码错误，请确认后重试'
      : `登录失败: ${error.message}`
    )
  } finally {
    loading.value = false
    store.setLoading(false)
  }
}
</script> 