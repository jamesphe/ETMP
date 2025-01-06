import { defineStore } from 'pinia'
import { ref } from 'vue'
import { trainingBaseService } from '@/services/trainingBase'

export const useTrainingBaseStore = defineStore('trainingBase', () => {
  const baseList = ref([])
  const total = ref(0)
  const loading = ref(false)

  // 获取基地列表
  const fetchList = async (params) => {
    loading.value = true
    try {
      const { data, total: totalCount } = await trainingBaseService.getBaseList(params)
      baseList.value = data
      total.value = totalCount
    } catch (error) {
      console.error('获取实训基地列表失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  // 更新基地状态
  const updateBaseStatus = async (params) => {
    await trainingBaseService.updateBaseStatus(params)
  }

  // 删除基地
  const deleteBase = async (id) => {
    await trainingBaseService.deleteBase(id)
  }

  return {
    baseList,
    total,
    loading,
    fetchList,
    updateBaseStatus,
    deleteBase
  }
})