import { supabase } from './supabase'

export const trainingBaseAPI = {
  // 获取实训基地列表
  async getTrainingBases() {
    const { data, error } = await supabase
      .from('training_bases')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (error) throw error
    return data
  },

  // 添加实训基地
  async addTrainingBase(baseData) {
    const { data, error } = await supabase
      .from('training_bases')
      .insert(baseData)
      .select()
    
    if (error) throw error
    return data[0]
  },

  // 更新实训基地
  async updateTrainingBase(id, baseData) {
    const { data, error } = await supabase
      .from('training_bases')
      .update(baseData)
      .eq('id', id)
      .select()
    
    if (error) throw error
    return data[0]
  },

  // 删除实训基地
  async deleteTrainingBase(id) {
    const { error } = await supabase
      .from('training_bases')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  }
} 