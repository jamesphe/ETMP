import { supabase } from './supabase'

export const organizationService = {
  // 获取组织架构树
  async getOrgTree() {
    const { data, error } = await supabase
      .from('organization')
      .select('*')
      .order('org_code')

    if (error) throw error
    return data || []
  },

  // 获取院系列表
  async getDepartments() {
    console.log('开始获取院系列表...')
    const { data, error } = await supabase
      .from('organization')
      .select('org_code, org_name')
      .eq('org_type', 'academic')
      .eq('status', 1)
      .order('org_code')

    if (error) {
      console.error('获取院系列表数据库错误:', error)
      throw error
    }
    
    console.log('原始院系数据:', data)
    const departments = data?.map(dept => ({
      orgCode: dept.org_code,
      orgName: dept.org_name
    })) || []
    console.log('转换后的院系数据:', departments)
    
    return departments
  }
} 