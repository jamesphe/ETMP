<template>
  <div 
    v-if="loading" 
    class="loading-overlay"
  >
    <el-icon class="loading-icon"><Loading /></el-icon>
    <span class="loading-text">{{ text }}</span>
  </div>
</template>

<script setup>
import { Loading } from '@element-plus/icons-vue'

defineProps({
  loading: {
    type: Boolean,
    default: false
  },
  text: {
    type: String,
    default: '加载中...'
  }
})
</script>

<style scoped>
.loading-overlay {
  @apply absolute inset-0 flex flex-col items-center justify-center bg-white bg-opacity-75 z-50;
  backdrop-filter: blur(2px);
}

.loading-icon {
  @apply text-3xl text-blue-500 animate-spin mb-2;
}

.loading-text {
  @apply text-sm text-gray-600;
}
</style> 