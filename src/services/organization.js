import { supabase } from '@/supabase'

export const organizationService = {
  // 获取组织机构树
  async getOrgTree() {
    try {
      const { data, error } = await supabase
        .from('organization')
        .select('*')
        .order('sort_order', { ascending: true })

      if (error) {
        console.error('Error fetching organization tree:', error)
        throw error
      }
      return this.buildTree(data)
    } catch (e) {
      console.error('Unexpected error in getOrgTree:', e)
      throw e
    }
  },

  // 获取单个组织机构详情
  async getOrgById(id) {
    try {
      const { data, error } = await supabase
        .from('organization')
        .select('*')
        .eq('id', id)
        .single()

      if (error) {
        console.error(`Error fetching organization with id ${id}:`, error)
        throw error
      }
      return data
    } catch (e) {
      console.error('Unexpected error in getOrgById:', e)
      throw e
    }
  },

  // 创建组织机构
  async createOrg(org) {
    try {
      const { data, error } = await supabase
        .from('organization')
        .insert(org)
        .select()
        .single()

      if (error) {
        console.error('Error creating organization:', error)
        throw error
      }
      return data
    } catch (e) {
      console.error('Unexpected error in createOrg:', e)
      throw e
    }
  },

  // 更新组织机构
  async updateOrg(id, updates) {
    try {
      const { data, error } = await supabase
        .from('organization')
        .update(updates)
        .eq('id', id)

      if (error) {
        console.error(`Error updating organization with id ${id}:`, error)
        throw error
      }
      return data
    } catch (e) {
      console.error('Unexpected error in updateOrg:', e)
      throw e
    }
  },

  // 删除组织机构
  async deleteOrg(id) {
    try {
      const { data, error } = await supabase
        .from('organization')
        .delete()
        .eq('id', id)

      if (error) {
        console.error(`Error deleting organization with id ${id}:`, error)
        throw error
      }
      return data
    } catch (e) {
      console.error('Unexpected error in deleteOrg:', e)
      throw e
    }
  },

  // 添加构建树形结构的方法
  buildTree(data, parentId = null) {
    return data
      .filter(item => item.parent_id === parentId)
      .map(item => ({
        ...item,
        children: this.buildTree(data, item.id)
      }))
  }
} 