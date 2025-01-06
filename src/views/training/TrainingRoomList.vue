<template>
  <div class="training-room-list">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>实训室管理</span>
          <el-button type="primary" @click="handleAdd">新增实训室</el-button>
        </div>
      </template>
      
      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="name" label="实训室名称" />
        <el-table-column prop="location" label="位置" />
        <el-table-column prop="capacity" label="容量" />
        <el-table-column prop="status" label="状态" />
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button
              size="small"
              type="danger"
              @click="handleDelete(scope.row)"
            >删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model="currentPage"
          v-model="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { supabase } from '@/supabase'
import { useRouter } from 'vue-router'

const router = useRouter()

// 表格数据
const tableData = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 处理分页
const handleSizeChange = (val) => {
  pageSize.value = val
  fetchData()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchData()
}

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const { data, error, count } = await supabase
      .from('training_rooms')
      .select('*', { count: 'exact' })
      .range((currentPage.value - 1) * pageSize.value, currentPage.value * pageSize.value - 1)
    
    if (error) throw error
    
    tableData.value = data
    total.value = count
  } catch (error) {
    ElMessage.error('获取数据失败：' + error.message)
  } finally {
    loading.value = false
  }
}

// 处理操作
const handleAdd = () => {
  // 跳转到添加页面
  router.push('/training/room/add')
}

const handleEdit = (row) => {
  // 跳转到编辑页面
  router.push(`/training/room/edit/${row.id}`)
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该实训室吗？', '提示', {
      type: 'warning'
    })
    
    const { error } = await supabase
      .from('training_rooms')
      .delete()
      .eq('id', row.id)
    
    if (error) throw error
    
    ElMessage.success('删除成功')
    fetchData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败：' + error.message)
    }
  }
}

// 初始化
fetchData()
</script>

<style scoped>
.training-room-list {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style> 