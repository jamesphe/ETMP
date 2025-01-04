<template>
  <div class="training-base-list">
    <div class="header">
      <h2>实训基地列表</h2>
      <el-button type="primary" @click="$router.push('/training/bases/create')">
        新增基地
      </el-button>
    </div>

    <el-table
      v-loading="loading"
      :data="baseList"
      border
      style="width: 100%"
    >
      <el-table-column prop="base_name" label="基地名称" />
      <el-table-column prop="dept_name" label="管理单位" />
      <el-table-column prop="support_unit" label="依托单位" />
      <el-table-column prop="contact_person" label="联系人" />
      <el-table-column prop="contact_phone" label="联系电话" />
      <el-table-column prop="base_type" label="基地类别">
        <template #default="{ row }">
          {{ row.base_type === 'internal' ? '校内实训基地' : '校外实训基地' }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button-group>
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </el-button-group>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { trainingBaseService } from '@/services/trainingBase'

const router = useRouter()
const loading = ref(false)
const baseList = ref([])

// 获取基地列表
const fetchList = async () => {
  loading.value = true
  try {
    baseList.value = await trainingBaseService.getList()
  } catch (error) {
    ElMessage.error(error.message || '获取列表失败')
  } finally {
    loading.value = false
  }
}

// 删除基地
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该实训基地吗？', '提示', {
      type: 'warning',
      confirmButtonText: '确定',
      cancelButtonText: '取消'
    })
    
    await trainingBaseService.delete(row.id)
    ElMessage.success('删除成功')
    fetchList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

// 编辑基地
const handleEdit = (row) => {
  router.push(`/training/bases/edit/${row.id}`)
}

onMounted(() => {
  fetchList()
})
</script>

<style scoped>
.training-base-list {
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}

.el-table {
  margin-top: 20px;
}

:deep(.el-button-group) {
  .el-button {
    margin-left: 0;
  }
}
</style> 