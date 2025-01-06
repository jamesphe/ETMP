<template>
  <div class="organization-list p-6">
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-xl font-bold">组织机构管理</h2>
      <el-button type="primary" @click="handleAdd">
        <el-icon><Plus /></el-icon>新增机构
      </el-button>
    </div>

    <el-card class="org-tree-card">
      <div class="flex">
        <!-- 左侧树形结构 -->
        <div class="w-1/3 border-r pr-4">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索机构"
            prefix-icon="Search"
            clearable
            class="mb-4"
          />
          <el-tree
            ref="treeRef"
            :data="orgTree"
            :props="defaultProps"
            :filter-node-method="filterNode"
            node-key="id"
            default-expand-all
            highlight-current
            draggable
            @node-click="handleNodeClick"
            @node-drag-end="handleDragEnd"
          >
            <template #default="{ node, data }">
              <div class="flex items-center justify-between w-full">
                <span>{{ node.label }}</span>
                <div class="operation-buttons">
                  <el-button-group>
                    <el-button 
                      :type="primary"
                      link
                      @click.stop="handleEdit(data)"
                    >
                      <el-icon><Edit /></el-icon>
                    </el-button>
                    <el-button 
                      :type="danger"
                      link
                      @click.stop="handleDelete(node, data)"
                    >
                      <el-icon><Delete /></el-icon>
                    </el-button>
                  </el-button-group>
                </div>
              </div>
            </template>
          </el-tree>
        </div>

        <!-- 右侧详情 -->
        <div class="w-2/3 pl-6">
          <template v-if="currentOrg">
            <h3 class="text-lg font-medium mb-4">{{ currentOrg.name }} - 详细信息</h3>
            <el-descriptions :column="2" border>
              <el-descriptions-item label="机构名称">
                {{ currentOrg.org_name }}
              </el-descriptions-item>
              <el-descriptions-item label="机构类型">
                {{ getOrgTypeName(currentOrg.org_type) }}
              </el-descriptions-item>
              <el-descriptions-item label="上级机构">
                {{ currentOrg.parent_name || '无' }}
              </el-descriptions-item>
              <el-descriptions-item label="排序号">
                {{ currentOrg.sort_order }}
              </el-descriptions-item>
              <el-descriptions-item label="创建时间" :span="2">
                {{ formatDateTime(currentOrg.created_at) }}
              </el-descriptions-item>
              <el-descriptions-item label="描述" :span="2">
                {{ currentOrg.description || '暂无描述' }}
              </el-descriptions-item>
            </el-descriptions>
          </template>
          <el-empty v-else description="请选择左侧机构查看详情" />
        </div>
      </div>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="currentOrg ? '编辑机构' : '新增机构'"
      width="500px"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="机构名称" prop="org_name">
          <el-input v-model="form.org_name" />
        </el-form-item>
        <el-form-item label="机构类型" prop="org_type">
          <el-select v-model="form.org_type" class="w-full">
            <el-option 
              v-for="type in orgTypes" 
              :key="type.value" 
              :label="type.label" 
              :value="type.value" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="上级机构" prop="parent_id">
          <el-tree-select
            v-model="form.parent_id"
            :data="orgTree"
            :props="defaultProps"
            check-strictly
            class="w-full"
          />
        </el-form-item>
        <el-form-item label="排序号" prop="sort_order">
          <el-input-number v-model="form.sort_order" :min="0" class="w-full" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="3"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Edit, Delete, Search } from '@element-plus/icons-vue'
import { supabase } from '@/services/supabase'
import { formatDateTime } from '@/utils/date'

// 组织机构类型选项
const orgTypes = [
  { label: '学校', value: 'school' },
  { label: '党群部门', value: 'party' },
  { label: '行政部门', value: 'administrative' },
  { label: '教学院系', value: 'academic' },
  { label: '教研室', value: 'teaching' },
  { label: '研究所', value: 'research' },
  { label: '教辅部门', value: 'service' },
  { label: '其他', value: 'other' }
]

// 获取机构类型名称
const getOrgTypeName = (type) => {
  const found = orgTypes.find(item => item.value === type)
  return found ? found.label : type
}

const treeRef = ref(null)
const formRef = ref(null)
const dialogVisible = ref(false)
const searchKeyword = ref('')
const orgTree = ref([])
const currentOrg = ref(null)

const defaultProps = {
  children: 'children',
  label: 'org_name'
}

const form = ref({
  org_name: '',
  org_type: '',
  parent_id: null,
  sort_order: 0,
  description: ''
})

const rules = {
  org_name: [{ required: true, message: '请输入机构名称', trigger: 'blur' }],
  org_type: [{ required: true, message: '请选择机构类型', trigger: 'change' }],
  sort_order: [{ required: true, message: '请输入排序号', trigger: 'blur' }]
}

// 监听搜索关键词变化
watch(searchKeyword, (val) => {
  treeRef.value?.filter(val)
})

// 树节点过滤方法
const filterNode = (value, data) => {
  if (!value) return true
  return data.org_name.toLowerCase().includes(value.toLowerCase())
}

// 获取组织机构树数据
const fetchOrgTree = async () => {
  try {
    const { data, error } = await supabase
      .from('organization')
      .select('*')
      .order('sort_order', { ascending: true })
    
    if (error) throw error
    
    // 构建树形结构
    orgTree.value = buildTree(data)
  } catch (error) {
    ElMessage.error('获取组织机构数据失败：' + error.message)
  }
}

// 修改构建树形结构的方法
const buildTree = (data) => {
  const map = {}
  const result = []

  // 首先创建所有节点的映射
  data.forEach(item => {
    map[item.id] = { ...item, children: [] }
  })

  // 构建树形结构
  data.forEach(item => {
    const node = map[item.id]
    if (item.parent_id && map[item.parent_id]) {
      // 如果有父节点，将当前节点添加到父节点的children中
      map[item.parent_id].children.push(node)
    } else {
      // 如果没有父节点，则作为根节点
      result.push(node)
    }
  })

  // 对每个节点的子节点按照org_type进行排序
  const sortByOrgType = (nodes) => {
    // 按照orgTypes中定义的顺序进行排序
    nodes.sort((a, b) => {
      const typeAIndex = orgTypes.findIndex(t => t.value === a.org_type)
      const typeBIndex = orgTypes.findIndex(t => t.value === b.org_type)
      if (typeAIndex === typeBIndex) {
        // 如果类型相同，按照sort_order排序
        return (a.sort_order || 0) - (b.sort_order || 0)
      }
      return typeAIndex - typeBIndex
    })

    // 递归处理子节点
    nodes.forEach(node => {
      if (node.children && node.children.length > 0) {
        sortByOrgType(node.children)
      }
    })
  }

  // 对结果进行排序
  sortByOrgType(result)

  return result
}

// 处理节点点击
const handleNodeClick = (data) => {
  if (!data) return
  
  try {
    currentOrg.value = {
      ...data,
      name: data.org_name
    }
  } catch (error) {
    console.error('处理节点点击出错:', error)
    ElMessage.error('操作失败')
  }
}

// 处理新增
const handleAdd = () => {
  currentOrg.value = null
  form.value = {
    name: '',
    org_type: '',
    parent_id: null,
    sort_order: 0,
    description: ''
  }
  dialogVisible.value = true
}

// 处理编辑
const handleEdit = (data) => {
  currentOrg.value = data
  form.value = {
    name: data.name,
    org_type: data.org_type,
    parent_id: data.parent_id,
    sort_order: data.sort_order,
    description: data.description
  }
  dialogVisible.value = true
}

// 处理删除
const handleDelete = async (node, data) => {
  try {
    await ElMessageBox.confirm(
      '确定要删除该机构吗？如果存在子机构，将无法删除。',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    // 检查是否有子机构
    if (data.children && data.children.length > 0) {
      ElMessage.error('该机构下存在子机构，无法删除')
      return
    }
    
    const { error } = await supabase
      .from('organization')
      .delete()
      .eq('id', data.id)
    
    if (error) throw error
    
    ElMessage.success('删除成功')
    if (currentOrg.value?.id === data.id) {
      currentOrg.value = null
    }
    await fetchOrgTree()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败：' + error.message)
    }
  }
}

// 处理拖拽结束
const handleDragEnd = async (draggingNode, dropNode, dropType) => {
  try {
    const updates = {
      parent_id: dropType === 'inner' ? dropNode.data.id : dropNode.data.parent_id
    }
    
    const { error } = await supabase
      .from('organization')
      .update(updates)
      .eq('id', draggingNode.data.id)
    
    if (error) throw error
    
    ElMessage.success('移动成功')
    await fetchOrgTree()
  } catch (error) {
    ElMessage.error('移动失败：' + error.message)
  }
}

// 处理表单提交
const handleSubmit = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    const submitData = {
      org_name: form.value.org_name,
      org_type: form.value.org_type,
      parent_id: form.value.parent_id,
      sort_order: form.value.sort_order,
      description: form.value.description
    }
    
    if (currentOrg.value) {
      // 更新
      const { error } = await supabase
        .from('organization')
        .update(submitData)
        .eq('id', currentOrg.value.id)
      
      if (error) throw error
      ElMessage.success('更新成功')
    } else {
      // 新增
      const { error } = await supabase
        .from('organization')
        .insert(submitData)
      
      if (error) throw error
      ElMessage.success('创建成功')
    }
    
    dialogVisible.value = false
    await fetchOrgTree()
  } catch (error) {
    console.error('提交表单出错:', error)
    ElMessage.error(error.message || '保存失败')
  }
}

onMounted(async () => {
  try {
    await fetchOrgTree()
  } catch (error) {
    console.error('初始化组织架构树失败:', error)
    ElMessage.error('加载数据失败')
  }
})

onUnmounted(() => {
  treeRef.value = null
  currentOrg.value = null
})
</script>

<style scoped>
.org-tree-card {
  min-height: calc(100vh - 200px);
}

.operation-buttons {
  opacity: 0;
  transition: opacity 0.2s;
}

:deep(.el-tree-node__content:hover) .operation-buttons {
  opacity: 1;
}

:deep(.el-tree-node__content) {
  height: 40px;
}

:deep(.el-tree-node.is-current > .el-tree-node__content) {
  background-color: var(--el-color-primary-light-9);
}
</style>