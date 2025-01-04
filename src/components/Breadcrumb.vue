<template>
  <el-breadcrumb separator="/">
    <el-breadcrumb-item v-for="item in breadcrumbs" :key="item.path" :to="item.path">
      {{ item.meta?.title || item.name }}
    </el-breadcrumb-item>
  </el-breadcrumb>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

const breadcrumbs = computed(() => {
  const matched = route.matched.filter(item => item.meta?.title || item.name)
  return matched.map(item => ({
    path: item.path,
    name: item.name,
    meta: item.meta
  }))
})
</script>

<style scoped>
.el-breadcrumb {
  line-height: 1;
}
</style> 