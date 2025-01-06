<template>
  <el-config-provider :locale="zhCn">
    <router-view v-slot="{ Component }">
      <transition name="fade" mode="out-in">
        <component :is="Component" />
      </transition>
    </router-view>
  </el-config-provider>
</template>

<script setup>
import { ElConfigProvider } from 'element-plus'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import { provide } from 'vue'
import { getSupabaseClient } from './supabase'

// 提供 supabase 实例给所有子组件
provide('supabase', getSupabaseClient())
</script>

<style>
@import 'element-plus/dist/index.css';
@tailwind base;
@tailwind components;
@tailwind utilities;
</style> 