import { defineStore } from 'pinia'
import { ref } from 'vue'
import { classService } from '@/services/class'

export const useClassStore = defineStore('class', () => {
  // 状态
  const loading = ref(false)
  const classList = ref([])
  const total = ref(0)

  // 获取班级列表
  const getClassList = async (params) => {
    loading.value = true
    try {
      const { data, total: totalCount } = await classService.getClassList(params)
      classList.value = data
      total.value = totalCount
      return { data, total: totalCount }
    } catch (error) {
      console.error('获取班级列表失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  // 创建班级
  const createClass = async (classData) => {
    try {
      await classService.createClass(classData)
    } catch (error) {
      console.error('创建班级失败:', error)
      throw error
    }
  }

  // 更新班级
  const updateClass = async (classData) => {
    try {
      await classService.updateClass(classData)
    } catch (error) {
      console.error('更新班级失败:', error)
      throw error
    }
  }

  // 更新班级状态
  const updateClassStatus = async (params) => {
    try {
      await classService.updateClassStatus(params)
    } catch (error) {
      console.error('更新班级状态失败:', error)
      throw error
    }
  }

  // 获取班级详情
  const getClassDetail = async (classCode) => {
    try {
      return await classService.getClassDetail(classCode)
    } catch (error) {
      console.error('获取班级详情失败:', error)
      throw error
    }
  }

  // 获取班级学生列表
  const getClassStudents = async (params) => {
    try {
      return await classService.getClassStudents(params)
    } catch (error) {
      console.error('获取班级学生列表失败:', error)
      throw error
    }
  }

  // 批量导入学生
  const importStudents = async (classCode, students) => {
    try {
      await classService.importStudents(classCode, students)
    } catch (error) {
      console.error('批量导入学生失败:', error)
      throw error
    }
  }

  // 移除学生
  const removeStudent = async (params) => {
    try {
      await classService.removeStudent(params)
    } catch (error) {
      console.error('移除学生失败:', error)
      throw error
    }
  }

  return {
    loading,
    classList,
    total,
    getClassList,
    createClass,
    updateClass,
    updateClassStatus,
    getClassDetail,
    getClassStudents,
    importStudents,
    removeStudent
  }
}) 