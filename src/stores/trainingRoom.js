import { defineStore } from 'pinia'
import { trainingRoomService } from '@/services/trainingRoom'

export const useTrainingRoomStore = defineStore('trainingRoom', {
  state: () => ({
    roomList: [],
    total: 0,
    currentRoom: null,
    loading: false
  }),

  actions: {
    // 获取实训室列表
    async fetchRoomList(params) {
      this.loading = true
      try {
        const { data } = await trainingRoomService.getList(params)
        
        // 处理返回的数据，添加需要的字段
        const formattedData = data.map(room => ({
          ...room,
          roomCode: room.room_code,
          roomName: room.name,
          baseName: room.base_name,
          roomType: 'mechanical', // 这里需要映射实际的类型
          manager: '待设置', // 这里需要关联负责人信息
          status: room.status === 'active' ? 'free' : room.status
        }))

        this.roomList = formattedData
        this.total = formattedData.length
        return {
          list: formattedData,
          total: formattedData.length
        }
      } finally {
        this.loading = false
      }
    },

    // 获取实训室详情
    async fetchRoomDetail(id) {
      const { data } = await trainingRoomService.getDetail(id)
      this.currentRoom = data
      return data
    },

    // 创建实训室
    async createRoom(roomData) {
      const { data } = await trainingRoomService.create(roomData)
      return data
    },

    // 更新实训室
    async updateRoom(id, roomData) {
      const { data } = await trainingRoomService.update(id, roomData)
      return data
    },

    // 删除实训室
    async deleteRoom(id) {
      const { data } = await trainingRoomService.delete(id)
      return data
    }
  }
}) 