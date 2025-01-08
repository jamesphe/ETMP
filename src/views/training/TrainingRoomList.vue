<template>
  <div class="training-room-list">
    <el-card class="box-card" shadow="hover">
      <!-- 顶部标题和操作栏 -->
      <div class="header">
        <div class="title">
          <el-icon><School /></el-icon>
          <span>实训室管理</span>
        </div>
        <div class="operation-bar">
          <el-button type="primary" @click="$router.push('/training/rooms/create')">
            <el-icon><Plus /></el-icon>新增实训室
          </el-button>
        </div>
      </div>

      <!-- 搜索表单 -->
      <div class="search-wrapper">
        <el-row :gutter="20">
          <el-col :span="6">
            <div class="search-item">
              <span class="label">实训室编号</span>
              <el-input
                v-model="searchForm.roomCode"
                placeholder="请输入实训室编号"
                clearable
                @keyup.enter="handleSearch"
              />
            </div>
          </el-col>
          <el-col :span="6">
            <div class="search-item">
              <span class="label">实训室名称</span>
              <el-input
                v-model="searchForm.roomName"
                placeholder="请输入实训室名称"
                clearable
                @keyup.enter="handleSearch"
              />
            </div>
          </el-col>
          <el-col :span="6">
            <div class="search-item">
              <span class="label">所属基地</span>
              <el-select 
                v-model="searchForm.baseId" 
                placeholder="请选择所属基地"
                clearable
                style="width: 100%"
              >
                <el-option 
                  v-for="base in baseOptions"
                  :key="base.id"
                  :label="base.baseName"
                  :value="base.id"
                />
              </el-select>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="search-item">
              <span class="label">实训室类型</span>
              <el-select 
                v-model="searchForm.roomType" 
                placeholder="请选择类型"
                clearable
                style="width: 100%"
              >
                <el-option label="机械加工" value="mechanical" />
                <el-option label="电子电工" value="electronic" />
                <el-option label="计算机" value="computer" />
                <el-option label="模拟训练" value="simulation" />
              </el-select>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="search-item">
              <span class="label">状态</span>
              <el-select 
                v-model="searchForm.status" 
                placeholder="请选择状态"
                clearable
                style="width: 100%"
              >
                <el-option label="空闲" value="free" />
                <el-option label="使用中" value="in_use" />
                <el-option label="维护中" value="maintenance" />
                <el-option label="停用" value="disabled" />
              </el-select>
            </div>
          </el-col>
        </el-row>
        <div class="search-buttons">
          <el-button type="primary" @click="handleSearch">
            <el-icon><Search /></el-icon>查询
          </el-button>
          <el-button @click="handleReset">
            <el-icon><Refresh /></el-icon>重置
          </el-button>
        </div>
      </div>

      <!-- 数据表格 -->
      <el-table
        v-loading="loading"
        :data="roomList"
        border
        style="width: 100%"
      >
        <el-table-column prop="roomCode" label="实训室编号" width="120" />
        <el-table-column prop="roomName" label="实训室名称" min-width="150" />
        <el-table-column prop="baseName" label="所属基地" min-width="150" />
        <el-table-column prop="roomType" label="实训室类型" width="120">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.roomType)">
              {{ getRoomTypeName(row.roomType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="capacity" label="容纳人数" width="100" />
        <el-table-column prop="manager" label="负责人" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">
              {{ getStatusName(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
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
                type="primary"
                @click="handleSchedule(row)"
              >
                <el-icon><Calendar /></el-icon>排课
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
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          background
          layout="total, sizes, prev, pager, next, jumper"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Plus,
  Search,
  Refresh,
  Edit,
  Delete,
  School,
  Calendar
} from '@element-plus/icons-vue'
import { useTrainingRoomStore } from '@/stores/trainingRoom'

const router = useRouter()
const trainingRoomStore = useTrainingRoomStore()

// 数据相关
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const roomList = ref([])
const baseOptions = ref([])

// 搜索表单
const searchForm = ref({
  roomCode: '',
  roomName: '',
  baseId: '',
  roomType: '',
  status: ''
})

// 获取实训室类型标签样式
const getTypeTagType = (type) => {
  const types = {
    mechanical: 'success',
    electronic: 'warning',
    computer: 'info',
    simulation: 'primary'
  }
  return types[type] || 'info'
}

// 获取实训室类型名称
const getRoomTypeName = (type) => {
  const types = {
    mechanical: '机械加工',
    electronic: '电子电工',
    computer: '计算机',
    simulation: '模拟训练'
  }
  return types[type] || type
}

// 获取状态标签样式
const getStatusTagType = (status) => {
  const types = {
    free: 'success',
    in_use: 'warning',
    maintenance: 'info',
    disabled: 'danger'
  }
  return types[status] || 'info'
}

// 获取状态名称
const getStatusName = (status) => {
  const statuses = {
    free: '空闲',
    in_use: '使用中',
    maintenance: '维护中',
    disabled: '停用'
  }
  return statuses[status] || status
}

// 处理搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchRoomList()
}

// 处理重置
const handleReset = () => {
  searchForm.value = {
    roomCode: '',
    roomName: '',
    baseId: '',
    roomType: '',
    status: ''
  }
  handleSearch()
}

// 获取实训室列表
const fetchRoomList = async () => {
  loading.value = true
  try {
    const { list, total: totalCount } = await trainingRoomStore.fetchRoomList({
      page: currentPage.value,
      pageSize: pageSize.value,
      ...searchForm.value
    })
    roomList.value = list
    total.value = totalCount
  } catch (error) {
    ElMessage.error('获取实训室列表失败')
  } finally {
    loading.value = false
  }
}

// 处理编辑
const handleEdit = (row) => {
  router.push(`/training/rooms/edit/${row.id}`)
}

// 处理排课
const handleSchedule = (row) => {
  router.push(`/training/rooms/schedule/${row.id}`)
}

// 处理删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该实训室吗？', '提示', {
      type: 'warning'
    })
    await trainingRoomStore.deleteRoom(row.id)
    ElMessage.success('删除成功')
    fetchRoomList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 监听分页变化
watch([currentPage, pageSize], () => {
  fetchRoomList()
})

onMounted(() => {
  fetchRoomList()
})
</script>

<style scoped>
.training-room-list {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 84px);
}

/* 复用实训基地列表的样式 */
.box-card {
  border-radius: 8px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid #ebeef5;
}

.title {
  display: flex;
  align-items: center;
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.title .el-icon {
  margin-right: 8px;
  font-size: 20px;
  color: #409eff;
}

.search-wrapper {
  margin-bottom: 20px;
  padding: 20px;
  background-color: #fff;
  border-radius: 4px;
  border: 1px solid #ebeef5;
}

.search-item {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
}

.label {
  min-width: 70px;
  color: #606266;
  font-size: 14px;
  text-align: right;
}

.search-buttons {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px dashed #e6e6e6;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

@media screen and (max-width: 1400px) {
  :deep(.el-col-6) {
    width: 50%;
  }
}

@media screen and (max-width: 768px) {
  :deep(.el-col-6) {
    width: 100%;
  }
}
</style> 