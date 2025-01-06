<template>
  <div class="major-info">
    <el-card class="box-card" shadow="hover">
      <!-- 顶部标题和操作栏 -->
      <div class="header">
        <div class="title">
          <el-icon><Collection /></el-icon>
          <span>专业信息管理</span>
        </div>
        <div class="operation-bar">
          <el-button type="primary" @click="handleAdd">
            <el-icon><Plus /></el-icon>
            新增专业
          </el-button>
        </div>
      </div>

      <!-- 查询区 -->
      <div class="search-wrapper">
        <el-row :gutter="20">
          <el-col :span="6">
            <div class="search-item">
              <span class="label">专业代码</span>
              <el-input
                v-model="queryParams.majorCode"
                placeholder="请输入专业代码"
                clearable
                @keyup.enter="handleQuery"
              />
            </div>
          </el-col>
          <el-col :span="6">
            <div class="search-item">
              <span class="label">专业名称</span>
              <el-input
                v-model="queryParams.majorName"
                placeholder="请输入专业名称"
                clearable
                @keyup.enter="handleQuery"
              />
            </div>
          </el-col>
          <el-col :span="6">
            <div class="search-item">
              <span class="label">所属院系</span>
              <el-select 
                v-model="queryParams.deptCode"
                placeholder="请选择院系"
                clearable
              >
                <el-option
                  v-for="dept in deptList"
                  :key="dept.deptCode"
                  :label="dept.deptName"
                  :value="dept.deptCode"
                />
              </el-select>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="search-item">
              <span class="label">状态</span>
              <el-select 
                v-model="queryParams.status"
                placeholder="请选择状态"
                clearable
              >
                <el-option label="启用" value="active" />
                <el-option label="停用" value="inactive" />
              </el-select>
            </div>
          </el-col>
        </el-row>
        <div class="search-buttons">
          <el-button type="primary" @click="handleQuery">
            <el-icon><Search /></el-icon>
            查询
          </el-button>
          <el-button @click="resetQuery">
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </div>
      </div>

      <!-- 表格工具栏 -->
      <div class="table-toolbar">
        <div class="left">
          <span class="total-count">共 {{ total }} 条记录</span>
        </div>
      </div>

      <!-- 数据表格 -->
      <el-table 
        v-loading="loading"
        :data="majorList" 
        style="width: 100%"
        border
        stripe
        highlight-current-row
      >
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column 
          prop="majorCode" 
          label="专业代码" 
          width="120" 
          align="center"
          show-overflow-tooltip
        />
        <el-table-column 
          prop="majorName" 
          label="专业名称" 
          min-width="180"
          show-overflow-tooltip
        />
        <el-table-column 
          prop="deptName" 
          label="所属院系" 
          min-width="180"
          show-overflow-tooltip
        />
        <el-table-column 
          prop="description" 
          label="专业描述" 
          min-width="200"
          show-overflow-tooltip
        />
        <el-table-column 
          prop="status" 
          label="状态" 
          width="100" 
          align="center"
        >
          <template #default="{ row }">
            <el-tag 
              :type="row.status === 'active' ? 'success' : 'danger'"
              effect="plain"
              round
            >
              {{ row.status === 'active' ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column 
          label="操作" 
          width="180" 
          fixed="right"
          align="center"
        >
          <template #default="{ row }">
            <el-button-group>
              <el-button 
                type="primary" 
                link
                size="small"
                @click="handleEdit(row)"
              >
                <el-icon><Edit /></el-icon>编辑
              </el-button>
              <el-button 
                :type="row.status === 'active' ? 'warning' : 'success'"
                link
                size="small"
                @click="handleStatus(row)"
              >
                <el-icon>
                  <CircleClose v-if="row.status === 'active'" />
                  <CircleCheck v-else />
                </el-icon>
                {{ row.status === 'active' ? '停用' : '启用' }}
              </el-button>
              <el-button
                type="danger"
                link
                size="small"
                @click="handleDelete(row)"
              >
                <el-icon><Delete /></el-icon>删除
              </el-button>
            </el-button-group>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页器 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[10, 20, 30, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          background
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>

      <!-- 新增/编辑对话框 -->
      <el-dialog
        v-model="dialogVisible"
        :title="dialogType === 'add' ? '新增专业' : '编辑专业'"
        width="500px"
        destroy-on-close
      >
        <el-form
          ref="formRef"
          :model="formData"
          :rules="rules"
          label-width="100px"
          class="dialog-form"
        >
          <el-form-item label="专业代码" prop="majorCode">
            <el-input 
              v-model="formData.majorCode"
              placeholder="请输入专业代码"
              clearable
            />
          </el-form-item>
          <el-form-item label="专业名称" prop="majorName">
            <el-input 
              v-model="formData.majorName"
              placeholder="请输入专业名称"
              clearable
            />
          </el-form-item>
          <el-form-item label="所属院系" prop="deptCode">
            <el-select 
              v-model="formData.deptCode" 
              placeholder="请选择院系"
              style="width: 100%"
              clearable
            >
              <el-option
                v-for="dept in deptList"
                :key="dept.deptCode"
                :label="dept.deptName"
                :value="dept.deptCode"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="专业描述" prop="description">
            <el-input
              v-model="formData.description"
              type="textarea"
              :rows="3"
              placeholder="请输入专业描述"
              clearable
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
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Edit, CircleCheck, CircleClose, Collection, Search, Refresh, Delete } from '@element-plus/icons-vue'
import { useMajorStore } from '@/stores/system/major/major'

// 初始化 store
const majorStore = useMajorStore()

// 数据列表相关
const loading = ref(false)
const majorList = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)

// 对话框相关
const dialogVisible = ref(false)
const dialogType = ref('add') // 'add' 或 'edit'
const formRef = ref(null)
const formData = ref({
  majorCode: '',
  majorName: '',
  deptCode: '',
  description: ''
})

// 院系列表
const deptList = ref([])

// 表单校验规则
const rules = {
  majorCode: [
    { required: true, message: '请输入专业代码', trigger: 'blur' },
    { min: 2, max: 20, message: '长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  majorName: [
    { required: true, message: '请输入专业名称', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  deptCode: [
    { required: true, message: '请选择所属院系', trigger: 'change' }
  ]
}

// 查询参数
const queryParams = ref({
  majorCode: '',
  majorName: '',
  deptCode: '',
  status: ''
})

// 查询方法
const handleQuery = () => {
  currentPage.value = 1
  loadMajorList()
}

// 重置查询
const resetQuery = () => {
  queryParams.value = {
    majorCode: '',
    majorName: '',
    deptCode: '',
    status: ''
  }
  handleQuery()
}

// 获取专业列表
const loadMajorList = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      pageSize: pageSize.value,
      ...queryParams.value
    }
    const { data, total: totalCount } = await majorStore.getMajorList(params)
    majorList.value = data
    total.value = totalCount
  } catch (error) {
    ElMessage.error('获取专业列表失败')
  } finally {
    loading.value = false
  }
}

// 获取院系列表
const loadDeptList = async () => {
  try {
    const departments = await majorStore.getDeptList()
    deptList.value = departments.map(dept => ({
      deptCode: dept.orgCode,
      deptName: dept.orgName
    }))
  } catch (error) {
    console.error('获取院系列表失败:', error)
    ElMessage.error('获取院系列表失败')
    deptList.value = []
  }
}

// 新增专业
const handleAdd = () => {
  dialogType.value = 'add'
  formData.value = {
    majorCode: '',
    majorName: '',
    deptCode: '',
    description: ''
  }
  dialogVisible.value = true
}

// 编辑专业
const handleEdit = (row) => {
  dialogType.value = 'edit'
  formData.value = { ...row }
  dialogVisible.value = true
}

// 更改专业状态
const handleStatus = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确认要${row.status === 'active' ? '停用' : '启用'}该专业吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    await majorStore.updateMajorStatus({
      majorCode: row.majorCode,
      status: row.status === 'active' ? 'inactive' : 'active'
    })
    ElMessage.success('操作成功')
    loadMajorList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (dialogType.value === 'add') {
          await majorStore.createMajor(formData.value)
          ElMessage.success('新增成功')
        } else {
          await majorStore.updateMajor(formData.value)
          ElMessage.success('更新成功')
        }
        dialogVisible.value = false
        loadMajorList()
      } catch (error) {
        ElMessage.error(dialogType.value === 'add' ? '新增失败' : '更新失败')
      }
    }
  })
}

// 分页相关方法
const handleSizeChange = (val) => {
  pageSize.value = val
  loadMajorList()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  loadMajorList()
}

// 初始化
onMounted(() => {
  loadMajorList()
  loadDeptList()
})
</script>

<style scoped>
.major-info {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 84px);
}

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

.table-toolbar {
  margin-bottom: 16px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

/* 操作按钮样式 */
.operation-buttons {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.el-button [class*='el-icon'] + span {
  margin-left: 4px;
}

/* 响应式布局 */
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

/* 对话框样式 */
.dialog-form {
  padding: 20px 20px 0;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  padding-top: 20px;
}
</style> 