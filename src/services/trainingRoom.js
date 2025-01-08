import { supabase } from './supabase'

export const trainingRoomService = {
  // 获取实训室列表
  async getList(params) {
    const { page = 1, pageSize = 10, ...filters } = params
    
    let query = supabase
      .from('training_rooms')
      .select(`
        *,
        training_bases (
          base_name
        )
      `, { count: 'exact' })
    
    // 添加过滤条件
    if (filters.roomCode) {
      query = query.ilike('room_code', `%${filters.roomCode}%`)
    }
    if (filters.roomName) {
      query = query.ilike('room_name', `%${filters.roomName}%`) 
    }
    if (filters.baseId) {
      query = query.eq('base_id', filters.baseId)
    }
    if (filters.roomType) {
      query = query.eq('room_type', filters.roomType)
    }
    if (filters.status) {
      query = query.eq('status', filters.status)
    }

    // 分页
    const from = (page - 1) * pageSize
    const to = from + pageSize - 1
    
    const { data, error, count } = await query
      .range(from, to)
      .order('created_at', { ascending: false })

    if (error) throw error

    // 处理关联数据
    const formattedData = data.map(room => ({
      ...room,
      base_name: room.training_bases?.base_name || '未关联基地'
    }))

    return {
      data: formattedData,
      total: count
    }
  },

  // 创建实训室
  async create(roomData) {
    const { data, error } = await supabase
      .from('training_rooms')
      .insert(roomData)
      .select()
      .single()

    if (error) throw error
    return data
  },

  // 更新实训室
  async update(id, roomData) {
    const { data, error } = await supabase
      .from('training_rooms')
      .update(roomData)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  },

  // 删除实训室
  async delete(id) {
    const { error } = await supabase
      .from('training_rooms')
      .delete()
      .eq('id', id)

    if (error) throw error
    return true
  }
} 