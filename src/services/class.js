import { supabase } from './supabase'

export const classService = {
  // 获取班级列表
  async getClassList(params) {
    const {
      page = 1,
      pageSize = 10,
      classCode,
      className,
      majorCode,
      status
    } = params

    let query = supabase
      .from('classes')
      .select(`
        *,
        major:major_code (
          major_name,
          organization:dept_code (
            org_name
          )
        )
      `, { count: 'exact' })

    // 移除 toSQL() 调试
    console.log('查询参数:', {
      page,
      pageSize,
      classCode,
      className,
      majorCode,
      status
    })

    // 添加查询条件
    if (classCode) {
      query = query.ilike('class_code', `%${classCode}%`)
    }
    if (className) {
      query = query.ilike('class_name', `%${className}%`)
    }
    if (majorCode) {
      query = query.eq('major_code', majorCode)
    }
    if (status) {
      query = query.eq('status', status)
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

    // 添加详细的数据结构调试
    console.log('原始数据结构:', {
      totalCount: count,
      firstRecord: data?.[0],
      majorRelation: data?.[0]?.major,
      departmentRelation: data?.[0]?.major?.organization
    })

    // 检查关联关系是否正确
    const hasValidRelations = data?.every(item => {
      const hasMajor = !!item.major
      const hasOrganization = !!item.major?.organization
      if (!hasMajor || !hasOrganization) {
        console.warn('发现数据关联问题:', {
          classCode: item.class_code,
          hasMajor,
          hasOrganization,
          majorData: item.major,
          organizationData: item.major?.organization
        })
      }
      return hasMajor && hasOrganization
    })

    console.log('关联关系检查结果:', hasValidRelations)

    // 转换数据格式
    const formattedData = data?.map(item => {
      const formatted = {
        classCode: item.class_code,
        className: item.class_name,
        majorCode: item.major_code,
        majorName: item.major?.major_name,
        departmentName: item.major?.organization?.org_name,
        grade: item.grade_year,
        studentCount: item.student_count || 0,
        status: item.status,
        remark: item.remarks,
        createdAt: item.created_at,
        updatedAt: item.updated_at
      }

      // 记录任何缺失的关联数据
      if (!formatted.majorName || !formatted.departmentName) {
        console.warn('数据转换警告:', {
          class: formatted.classCode,
          missingMajor: !formatted.majorName,
          missingDepartment: !formatted.departmentName,
          originalData: item
        })
      }

      return formatted
    }) || []

    return {
      data: formattedData,
      total: count || 0
    }
  },

  // 创建班级
  async createClass(classData) {
    const { error } = await supabase
      .from('classes')
      .insert({
        class_code: classData.classCode,
        class_name: classData.className,
        major_code: classData.majorCode,
        grade: classData.grade,
        remark: classData.remark,
        status: 'active'
      })

    if (error) throw error
  },

  // 更新班级
  async updateClass(classData) {
    const { error } = await supabase
      .from('classes')
      .update({
        class_name: classData.className,
        major_code: classData.majorCode,
        grade: classData.grade,
        remark: classData.remark,
        updated_at: new Date().toISOString()
      })
      .eq('class_code', classData.classCode)

    if (error) throw error
  },

  // 更新班级状态
  async updateClassStatus(params) {
    const { classCode, status } = params
    const { error } = await supabase
      .from('classes')
      .update({
        status,
        updated_at: new Date().toISOString()
      })
      .eq('class_code', classCode)

    if (error) throw error
  },

  // 获取班级详情
  async getClassDetail(classCode) {
    const { data, error } = await supabase
      .from('classes')
      .select(`
        *,
        major:major_code (
          major_name,
          organization:dept_code (
            org_name
          )
        )
      `)
      .eq('class_code', classCode)
      .single()

    if (error) throw error

    return data ? {
      classCode: data.class_code,
      className: data.class_name,
      majorCode: data.major_code,
      majorName: data.major?.major_name,
      departmentName: data.major?.organization?.org_name,
      grade: data.grade_year,
      studentCount: data.student_count || 0,
      status: data.status,
      remark: data.remarks,
      createdAt: data.created_at,
      updatedAt: data.updated_at
    } : null
  },

  // 获取班级学生列表
  async getClassStudents(params) {
    const {
      classCode,
      page = 1,
      pageSize = 10
    } = params

    const from = (page - 1) * pageSize
    const to = from + pageSize - 1

    const { data, error, count } = await supabase
      .from('student')
      .select('*', { count: 'exact' })
      .eq('class_code', classCode)
      .range(from, to)

    if (error) throw error

    return {
      data: data || [],
      total: count || 0
    }
  },

  // 批量导入学生
  async importStudents(classCode, students) {
    const { error } = await supabase
      .from('student')
      .insert(
        students.map(student => ({
          ...student,
          class_code: classCode
        }))
      )

    if (error) throw error
  },

  // 移除学生
  async removeStudent(params) {
    const { studentId, classCode } = params
    const { error } = await supabase
      .from('student')
      .update({
        class_code: null,
        updated_at: new Date().toISOString()
      })
      .eq('student_id', studentId)
      .eq('class_code', classCode)

    if (error) throw error
  }
} 