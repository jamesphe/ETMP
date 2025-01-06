<template>
  <div class="class-info">
    <el-card class="box-card" shadow="hover">
      <!-- 顶部标题和操作栏 -->
      <div class="header">
        <div class="title">
          <el-icon><School /></el-icon>
          <span>班级信息管理</span>
        </div>
        <div class="operation-bar">
          <el-button type="primary" @click="handleAdd">
            <el-icon><Plus /></el-icon>
            新增班级
          </el-button>
        </div>
      </div>

      <!-- 查询区 -->
      <div class="search-wrapper">
        <el-row :gutter="20">
          <el-col :span="6">
            <div class="search-item">
              <span class="label">班级编号</span>
              <el-input
                v-model="queryParams.classCode"
                placeholder="请输入班级编号"
                clearable
                @keyup.enter="handleQuery"
              />
            </div>
          </el-col>
          <el-col :span="6">
            <div class="search-item">
              <span class="label">班级名称</span>
              <el-input
                v-model="queryParams.className"
                placeholder="请输入班级名称"
                clearable
                @keyup.enter="handleQuery"
              />
            </div>
          </el-col>
          <el-col :span="6">
            <div class="search-item">
              <span class="label">所属专业</span>
              <el-select 
                v-model="queryParams.majorCode"
                placeholder="请选择专业"
                clearable
              >
                <el-option
                  v-for="major in majorList"
                  :key="major.majorCode"
                  :label="major.majorName"
                  :value="major.majorCode"
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
                <el-option label="在读" value="active" />
                <el-option label="毕业" value="graduated" />
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
        :data="classList" 
        style="width: 100%"
        border
        stripe
        highlight-current-row
      >
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column 
          prop="classCode" 
          label="班级编号" 
          width="120" 
          align="center"
          show-overflow-tooltip
        />
        <el-table-column 
          prop="className" 
          label="班级名称" 
          min-width="150"
          show-overflow-tooltip
        />
        <el-table-column 
          prop="majorName" 
          label="所属专业" 
          min-width="150"
          show-overflow-tooltip
        />
        <el-table-column 
          prop="departmentName" 
          label="所属院系" 
          min-width="150"
          show-overflow-tooltip
        />
        <el-table-column 
          prop="grade" 
          label="年级" 
          width="100"
          align="center"
        />
        <el-table-column 
          prop="studentCount" 
          label="学生人数" 
          width="100"
          align="center"
        />
        <el-table-column 
          prop="status" 
          label="状态" 
          width="100" 
          align="center"
        >
          <template #default="{ row }">
            <el-tag 
              :type="getStatusType(row.status)"
              effect="plain"
              round
            >
              {{ getStatusText(row.status) }}
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
        :title="dialogType === 'add' ? '新增班级' : '编辑班级'"
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
          <el-form-item label="班级编号" prop="classCode">
            <el-input 
              v-model="formData.classCode"
              placeholder="请输入班级编号"
              clearable
            />
          </el-form-item>
          <el-form-item label="班级名称" prop="className">
            <el-input 
              v-model="formData.className"
              placeholder="请输入班级名称"
              clearable
            />
          </el-form-item>
          <el-form-item label="所属专业" prop="majorCode">
            <el-select 
              v-model="formData.majorCode"
              placeholder="请选择专业"
              style="width: 100%"
              clearable
            >
              <el-option
                v-for="major in majorList"
                :key="major.majorCode"
                :label="major.majorName"
                :value="major.majorCode"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="年级" prop="grade">
            <el-input
              v-model="formData.grade"
              placeholder="请输入年级，如：2024"
              clearable
            />
          </el-form-item>
          <el-form-item label="备注" prop="remark">
            <el-input
              v-model="formData.remark"
              type="textarea"
              :rows="3"
              placeholder="请输入备注信息"
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
import { Plus, School, Search, Refresh, Edit, CircleClose, CircleCheck, Delete } from '@element-plus/icons-vue'
import { useClassStore } from '@/stores/system/major/class'
import { useMajorStore } from '@/stores/system/major/major'

// 初始化 store
const classStore = useClassStore()
const majorStore = useMajorStore()

// 数据列表相关
const loading = ref(false)
const classList = ref([])
const majorList = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)

// 对话框相关
const dialogVisible = ref(false)
const dialogType = ref('add')
const formRef = ref(null)
const formData = ref({
  classCode: '',
  className: '',
  majorCode: '',
  grade: '',
  remark: ''
})

// 表单校验规则
const rules = {
  classCode: [
    { required: true, message: '请输入班级编号', trigger: 'blur' },
    { min: 2, max: 20, message: '长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  className: [
    { required: true, message: '请输入班级名称', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  majorCode: [
    { required: true, message: '请选择所属专业', trigger: 'change' }
  ],
  grade: [
    { required: true, message: '请输入年级', trigger: 'blur' },
    { pattern: /^\d{4}$/, message: '请输入正确的年级格式，如：2024', trigger: 'blur' }
  ]
}

// 查询参数
const queryParams = ref({
  classCode: '',
  className: '',
  majorCode: '',
  status: ''
})

// 状态相关方法
const getStatusType = (status) => {
  const statusMap = {
    active: 'success',
    graduated: 'info',
    inactive: 'danger'
  }
  return statusMap[status] || 'info'
}

const getStatusText = (status) => {
  const statusMap = {
    active: '在读',
    graduated: '毕业',
    inactive: '停用'
  }
  return statusMap[status] || '未知'
}

// 查询方法
const handleQuery = () => {
  currentPage.value = 1
  loadClassList()
}

// 重置查询
const resetQuery = () => {
  queryParams.value = {
    classCode: '',
    className: '',
    majorCode: '',
    status: ''
  }
  handleQuery()
}

// 获取班级列表
const loadClassList = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      pageSize: pageSize.value,
      ...queryParams.value
    }
    const { data, total: totalCount } = await classStore.getClassList(params)
    classList.value = data
    total.value = totalCount
  } catch (error) {
    ElMessage.error('获取班级列表失败')
  } finally {
    loading.value = false
  }
}

// 获取专业列表
const loadMajorList = async () => {
  try {
    const { data } = await majorStore.getMajorList({ status: 'active' })
    majorList.value = data
  } catch (error) {
    console.error('获取专业列表失败:', error)
    ElMessage.error('获取专业列表失败')
  }
}

// 新增班级
const handleAdd = () => {
  dialogType.value = 'add'
  formData.value = {
    classCode: '',
    className: '',
    majorCode: '',
    grade: '',
    remark: ''
  }
  dialogVisible.value = true
}

// 编辑班级
const handleEdit = (row) => {
  dialogType.value = 'edit'
  formData.value = { ...row }
  dialogVisible.value = true
}

// 更改班级状态
const handleStatus = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确认要${row.status === 'active' ? '停用' : '启用'}该班级吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    await classStore.updateClassStatus({
      classCode: row.classCode,
      status: row.status === 'active' ? 'inactive' : 'active'
    })
    ElMessage.success('操作成功')
    loadClassList()
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
          await classStore.createClass(formData.value)
          ElMessage.success('新增成功')
        } else {
          await classStore.updateClass(formData.value)
          ElMessage.success('更新成功')
        }
        dialogVisible.value = false
        loadClassList()
      } catch (error) {
        ElMessage.error(dialogType.value === 'add' ? '新增失败' : '更新失败')
      }
    }
  })
}

// 分页相关方法
const handleSizeChange = (val) => {
  pageSize.value = val
  loadClassList()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  loadClassList()
}

// 删除处理方法
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该班级吗？', '提示', {
      type: 'warning',
      confirmButtonText: '确定',
      cancelButtonText: '取消'
    })
    
    await classStore.deleteClass(row.classCode)
    ElMessage.success('删除成功')
    loadClassList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 初始化
onMounted(() => {
  loadClassList()
  loadMajorList()
})
</script>

<style scoped>
.class-info {
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

/* 操作按钮样式 */
.el-button [class*='el-icon'] + span {
  margin-left: 4px;
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