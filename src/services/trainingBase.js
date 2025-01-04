import { supabase } from '@/supabase'

export const trainingBaseService = {
  // 获取实训基地列表
  async getList() {
    const { data, error } = await supabase
      .from('training_bases')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (error) throw error
    return data
  },

  // 获取单个实训基地
  async getById(id) {
    try {
      const { data, error } = await supabase
        .from('training_bases')
        .select('*')
        .eq('id', id)
        .single()
        
      if (error) throw error
      return data
    } catch (error) {
      console.error('获取实训基地详情失败:', error)
      throw error
    }
  },

  // 创建实训基地
  async create(baseData) {
    // 生成基地编号
    const baseCode = `BASE${Date.now()}`
    
    const { data, error } = await supabase
      .from('training_bases')
      .insert([{
        base_code: baseCode,
        base_name: baseData.name,
        dept_code: baseData.deptCode || 'DEFAULT',
        dept_name: baseData.deptName || '默认部门',
        establish_date: new Date().toISOString(),
        support_unit: baseData.supportUnit || '默认依托单位',
        major_names: baseData.majorNames || [],
        partner_companies: baseData.partnerCompanies || [],
        base_type: baseData.baseType || 'internal',
        contact_person: baseData.contact,
        contact_phone: baseData.phone,
        remarks: baseData.description
      }])
      .select()
    
    if (error) throw error
    return data[0]
  },

  // 更新实训基地
  async update(id, baseData) {
    const { data, error } = await supabase
      .from('training_bases')
      .update({
        base_name: baseData.name,
        dept_name: baseData.deptName,
        support_unit: baseData.supportUnit,
        major_names: baseData.majorNames,
        partner_companies: baseData.partnerCompanies,
        base_type: baseData.baseType,
        contact_person: baseData.contact,
        contact_phone: baseData.phone,
        remarks: baseData.description
      })
      .eq('id', id)
      .select()
    
    if (error) throw error
    return data[0]
  },

  // 删除实训基地
  async delete(id) {
    const { error } = await supabase
      .from('training_bases')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  }
} 