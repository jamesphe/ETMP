<template>
  <div class="register min-h-screen flex items-center justify-center bg-gray-100">
    <el-card class="w-96">
      <template #header>
        <h2 class="text-xl font-bold text-center">注册账号</h2>
      </template>
      <el-form :model="registerForm" @submit.prevent="handleRegister">
        <el-form-item>
          <el-input v-model="registerForm.email" placeholder="邮箱" />
        </el-form-item>
        <el-form-item>
          <el-input 
            v-model="registerForm.password" 
            type="password" 
            placeholder="密码（至少6位，包含大小写字母和数字）" 
          />
        </el-form-item>
        <el-button type="primary" class="w-full" :loading="loading" @click="handleRegister">
          注册
        </el-button>
        <div class="text-center mt-4">
          <router-link to="/login" class="text-blue-500">已有账号？去登录</router-link>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/services/supabase'
import { ElMessage } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const registerForm = ref({
  email: '',
  password: ''
})

const validatePassword = (password) => {
  const hasUpperCase = /[A-Z]/.test(password)
  const hasLowerCase = /[a-z]/.test(password)
  const hasNumbers = /\d/.test(password)
  const hasMinLength = password.length >= 6
  return hasUpperCase && hasLowerCase && hasNumbers && hasMinLength
}

const handleRegister = async () => {
  if (!registerForm.value.email || !registerForm.value.password) {
    ElMessage.warning('请输入邮箱和密码')
    return
  }

  if (!validatePassword(registerForm.value.password)) {
    ElMessage.warning('密码必须至少6位，包含大小写字母和数字')
    return
  }

  try {
    loading.value = true
    const { data, error } = await supabase.auth.signUp({
      email: registerForm.value.email,
      password: registerForm.value.password
    })
    
    if (error) throw error
    
    ElMessage.success('注册成功，请登录')
    router.push('/login')
  } catch (error) {
    console.error('注册失败:', error.message)
    ElMessage.error(error.message)
  } finally {
    loading.value = false
  }
}
</script> 