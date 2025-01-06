import { supabase } from './supabase'

export const majorService = {
  // 获取专业列表
  async getMajorList({ page = 1, pageSize = 10, majorCode, majorName, deptCode }) {
    let query = supabase
      .from('majors')
      .select('*, organization!inner(org_name)', { count: 'exact' })

    // 添加查询条件
    if (majorCode) {
      query = query.ilike('major_code', `%${majorCode}%`)
    }
    if (majorName) {
      query = query.ilike('major_name', `%${majorName}%`)
    }
    if (deptCode) {
      query = query.eq('dept_code', deptCode)
    }

    // 分页
    const from = (page - 1) * pageSize
    const to = from + pageSize - 1
    
    const { data, count, error } = await query
      .order('created_at', { ascending: false })
      .range(from, to)

    if (error) throw error

    // 处理返回数据
    return {
      data: data.map(item => ({
        id: item.id,
        majorCode: item.major_code,
        majorName: item.major_name,
        deptCode: item.dept_code,
        deptName: item.organization.org_name,
        status: item.status,
        remarks: item.remarks
      })),
      total: count
    }
  },

  // 创建专业
  async createMajor(majorData) {
    const { error } = await supabase
      .from('majors')
      .insert({
        major_code: majorData.majorCode,
        major_name: majorData.majorName,
        dept_code: majorData.deptCode,
        remarks: majorData.remarks,
        status: 'active'
      })

    if (error) throw error
  },

  // 更新专业
  async updateMajor(majorData) {
    const { error } = await supabase
      .from('majors')
      .update({
        major_code: majorData.majorCode,
        major_name: majorData.majorName,
        dept_code: majorData.deptCode,
        remarks: majorData.remarks,
        updated_at: new Date()
      })
      .eq('id', majorData.id)

    if (error) throw error
  },

  // 更新专业状态
  async updateMajorStatus({ id, status }) {
    const { error } = await supabase
      .from('majors')
      .update({
        status,
        updated_at: new Date()
      })
      .eq('id', id)

    if (error) throw error
  }
} 