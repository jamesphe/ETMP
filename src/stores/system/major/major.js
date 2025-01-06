import { defineStore } from 'pinia'
import { ref } from 'vue'
import { majorService } from '@/services/major'
import { organizationService } from '@/services/organization'

export const useMajorStore = defineStore('major', () => {
  // 状态
  const loading = ref(false)
  const majorList = ref([])
  const total = ref(0)

  // 获取专业列表
  const getMajorList = async (params) => {
    loading.value = true
    try {
      const { data, total: totalCount } = await majorService.getMajorList(params)
      majorList.value = data
      total.value = totalCount
      return { data, total: totalCount }
    } catch (error) {
      console.error('获取专业列表失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  // 获取院系列表
  const getDeptList = async () => {
    try {
      console.log('major store 开始获取院系列表...')
      const departments = await organizationService.getDepartments()
      console.log('major store 获取到院系列表:', departments)
      return departments
    } catch (error) {
      console.error('获取院系列表失败:', error)
      return []
    }
  }

  // 创建专业
  const createMajor = async (majorData) => {
    try {
      await majorService.createMajor(majorData)
    } catch (error) {
      console.error('创建专业失败:', error)
      throw error
    }
  }

  // 更新专业
  const updateMajor = async (majorData) => {
    try {
      await majorService.updateMajor(majorData)
    } catch (error) {
      console.error('更新专业失败:', error)
      throw error
    }
  }

  // 更新专业状态
  const updateMajorStatus = async (params) => {
    try {
      await majorService.updateMajorStatus(params)
    } catch (error) {
      console.error('更新专业状态失败:', error)
      throw error
    }
  }

  return {
    loading,
    majorList,
    total,
    getMajorList,
    getDeptList,
    createMajor,
    updateMajor,
    updateMajorStatus
  }
}) 