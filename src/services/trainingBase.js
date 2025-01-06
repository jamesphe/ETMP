import { supabase } from './supabase'

export const trainingBaseService = {
  // 获取实训基地列表
  async getBaseList(params) {
    const {
      page = 1,
      pageSize = 10,
      baseName,
      deptName,
      baseType
    } = params

    let query = supabase
      .from('training_bases')
      .select('*', { count: 'exact' })

    // 添加查询条件
    if (baseName) {
      query = query.ilike('base_name', `%${baseName}%`)
    }
    if (deptName) {
      query = query.ilike('dept_name', `%${deptName}%`)
    }
    if (baseType) {
      query = query.eq('base_type', baseType)
    }

    // 分页
    const from = (page - 1) * pageSize
    const to = from + pageSize - 1
    
    const { data, error, count } = await query
      .order('created_at', { ascending: false })
      .range(from, to)

    if (error) {
      console.error('查询错误:', error)
      throw error
    }

    // 转换数据格式
    const formattedData = data?.map(item => ({
      id: item.id,
      baseName: item.base_name,
      deptName: item.dept_name,
      supportUnit: item.support_unit,
      contactPerson: item.contact_person,
      contactPhone: item.contact_phone,
      baseType: item.base_type,
      status: item.status,
      remark: item.remark,
      createdAt: item.created_at,
      updatedAt: item.updated_at
    })) || []

    return {
      data: formattedData,
      total: count || 0
    }
  },

  // 更新实训基地状态
  async updateBaseStatus(params) {
    const { id, status } = params
    const { error } = await supabase
      .from('training_bases')
      .update({
        status,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)

    if (error) throw error
  },

  // 删除实训基地
  async deleteBase(id) {
    const { error } = await supabase
      .from('training_bases')
      .delete()
      .eq('id', id)

    if (error) throw error
  }
} 