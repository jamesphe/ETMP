<template>
  <div class="training-base-list">
    <div class="header">
      <h2>实训基地管理</h2>
      <el-button type="primary" @click="$router.push('/training/bases/create')">
        <el-icon><Plus /></el-icon>新增基地
      </el-button>
    </div>

    <!-- 搜索表单 -->
    <el-form :model="searchForm" inline class="search-form">
      <el-form-item label="基地编号">
        <el-input
          v-model="searchForm.baseCode"
          placeholder="请输入基地编号"
          clearable
          @keyup.enter="handleSearch"
        />
      </el-form-item>
      <el-form-item label="基地名称">
        <el-input
          v-model="searchForm.baseName"
          placeholder="请输入基地名称"
          clearable
          @keyup.enter="handleSearch"
        />
      </el-form-item>
      <el-form-item label="管理单位">
        <el-select 
          v-model="searchForm.deptCode" 
          placeholder="请选择管理单位"
          clearable
        >
          <el-option 
            v-for="dept in deptOptions"
            :key="dept.deptCode"
            :label="dept.deptName"
            :value="dept.deptCode"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="基地类别">
        <el-select 
          v-model="searchForm.baseType" 
          placeholder="请选择类别"
          clearable
        >
          <el-option label="校内实训基地" value="internal" />
          <el-option label="校外实训基地" value="external" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态">
        <el-select 
          v-model="searchForm.status" 
          placeholder="请选择状态"
          clearable
        >
          <el-option label="正常" value="active" />
          <el-option label="停用" value="inactive" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSearch">
          <el-icon><Search /></el-icon>查询
        </el-button>
        <el-button @click="handleReset">
          <el-icon><Refresh /></el-icon>重置
        </el-button>
      </el-form-item>
    </el-form>

    <!-- 数据表格 -->
    <el-table
      v-loading="store.loading"
      :data="store.baseList"
      border
      style="width: 100%"
    >
      <el-table-column prop="baseCode" label="基地编号" width="120" />
      <el-table-column prop="baseName" label="基地名称" min-width="180" />
      <el-table-column prop="deptName" label="管理单位" min-width="150" />
      <el-table-column prop="supportUnit" label="依托单位" min-width="150" />
      <el-table-column prop="baseType" label="基地类别" width="120">
        <template #default="{ row }">
          <el-tag :type="row.baseType === 'internal' ? 'success' : 'warning'">
            {{ row.baseType === 'internal' ? '校内基地' : '校外基地' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="contactPerson" label="联系人" width="100" />
      <el-table-column prop="contactPhone" label="联系电话" width="120" />
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }">
          <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
            {{ row.status === 'active' ? '正常' : '停用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button-group>
            <el-button
              link
              type="primary"
              @click="handleEdit(row)"
            >
              <el-icon><Edit /></el-icon>编辑
            </el-button>
            <el-button
              link
              :type="row.status === 'active' ? 'warning' : 'success'"
              @click="handleToggleStatus(row)"
            >
              <el-icon><CircleClose v-if="row.status === 'active'" />
              <CircleCheck v-else /></el-icon>
              {{ row.status === 'active' ? '停用' : '启用' }}
            </el-button>
            <el-button
              link
              type="danger"
              @click="handleDelete(row)"
            >
              <el-icon><Delete /></el-icon>删除
            </el-button>
          </el-button-group>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <div class="pagination-container">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :total="store.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useTrainingBaseStore } from '@/stores/trainingBase'
import {
  Plus,
  Search,
  Refresh,
  Edit,
  Delete,
  CircleCheck,
  CircleClose
} from '@element-plus/icons-vue'

const router = useRouter()
const store = useTrainingBaseStore()

// 部门选项数据
const deptOptions = ref([
  { deptCode: 'DEPT001', deptName: '智能制造学院' },
  { deptCode: 'DEPT002', deptName: '电子信息学院' },
  // 这里需要从后端获取完整的部门列表
])

// 搜索表单
const searchForm = ref({
  baseCode: '',
  baseName: '',
  deptCode: '',
  baseType: '',
  status: ''
})

// 分页参数
const currentPage = ref(1)
const pageSize = ref(10)

// 监听分页变化
watch([currentPage, pageSize], () => {
  fetchList()
})

// 获取基地列表
const fetchList = async () => {
  try {
    await store.fetchList({
      page: currentPage.value,
      pageSize: pageSize.value,
      ...searchForm.value
    })
  } catch (error) {
    ElMessage.error(error.message || '获取列表失败')
  }
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchList()
}

// 重置搜索
const handleReset = () => {
  searchForm.value = {
    baseCode: '',
    baseName: '',
    deptCode: '',
    baseType: '',
    status: ''
  }
  currentPage.value = 1
  fetchList()
}

// 切换状态
const handleToggleStatus = async (row) => {
  try {
    const newStatus = row.status === 'active' ? 'inactive' : 'active'
    const actionText = newStatus === 'active' ? '启用' : '停用'
    
    await ElMessageBox.confirm(`确定要${actionText}该实训基地吗？`, '提示', {
      type: 'warning'
    })
    
    await store.updateBaseStatus({
      id: row.id,
      status: newStatus
    })
    ElMessage.success(`${actionText}成功`)
    fetchList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || `操作失败`)
    }
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
    
    await store.deleteBase(row.id)
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

.search-form {
  margin-bottom: 20px;
  padding: 20px;
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.el-table {
  margin-top: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

:deep(.el-button-group) {
  .el-button {
    margin-left: 0;
  }
}

.el-button [class*='el-icon'] + span {
  margin-left: 4px;
}
</style> 