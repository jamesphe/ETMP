<template>
  <div class="training-base-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>实训基地管理</span>
          <el-button type="primary" @click="handleAdd">新增实训基地</el-button>
        </div>
      </template>

      <!-- 搜索栏 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="基地编号">
          <el-input v-model="searchForm.baseCode" placeholder="请输入基地编号" />
        </el-form-item>
        <el-form-item label="基地名称">
          <el-input v-model="searchForm.baseName" placeholder="请输入基地名称" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="filteredBaseList" border style="width: 100%">
        <el-table-column prop="base_code" label="基地编号" width="120" />
        <el-table-column prop="base_name" label="基地名称" width="180" />
        <el-table-column prop="dept_name" label="所属管理单位" width="180" />
        <el-table-column prop="establish_date" label="建立日期" width="120" />
        <el-table-column prop="contact_person" label="联系人" width="120" />
        <el-table-column prop="contact_phone" label="联系电话" width="120" />
        <el-table-column label="操作" width="180">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      :title="dialogTitle"
      v-model="dialogVisible"
      width="700px"
    >
      <el-form
        ref="baseFormRef"
        :model="baseForm"
        :rules="rules"
        label-width="120px"
      >
        <el-form-item label="基地编号" prop="base_code">
          <el-input v-model="baseForm.base_code" />
        </el-form-item>
        <el-form-item label="基地名称" prop="base_name">
          <el-input v-model="baseForm.base_name" />
        </el-form-item>
        <el-form-item label="管理单位编号" prop="dept_code">
          <el-input v-model="baseForm.dept_code" />
        </el-form-item>
        <el-form-item label="管理单位名称" prop="dept_name">
          <el-input v-model="baseForm.dept_name" />
        </el-form-item>
        <el-form-item label="建立日期" prop="establish_date">
          <el-date-picker
            v-model="baseForm.establish_date"
            type="date"
            placeholder="选择日期"
          />
        </el-form-item>
        <el-form-item label="依托单位" prop="support_unit">
          <el-input v-model="baseForm.support_unit" />
        </el-form-item>
        <el-form-item label="适应专业" prop="major_names">
          <el-select
            v-model="baseForm.major_names"
            multiple
            filterable
            allow-create
            placeholder="请输入专业名称"
          />
        </el-form-item>
        <el-form-item label="合作企业" prop="partner_companies">
          <el-select
            v-model="baseForm.partner_companies"
            multiple
            filterable
            allow-create
            placeholder="请输入合作企业"
          />
        </el-form-item>
        <el-form-item label="基地类别" prop="base_type">
          <el-select v-model="baseForm.base_type" placeholder="请选择基地类别">
            <el-option label="校内实训基地" value="internal" />
            <el-option label="校外实训基地" value="external" />
          </el-select>
        </el-form-item>
        <el-form-item label="联系人" prop="contact_person">
          <el-input v-model="baseForm.contact_person" />
        </el-form-item>
        <el-form-item label="联系电话" prop="contact_phone">
          <el-input v-model="baseForm.contact_phone" />
        </el-form-item>
        <el-form-item label="备注" prop="remarks">
          <el-input
            v-model="baseForm.remarks"
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
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { trainingBaseAPI } from '@/services/trainingBase'

// 数据列表
const baseList = ref([])
const searchForm = ref({
  baseCode: '',
  baseName: ''
})

// 过滤后的数据列表
const filteredBaseList = computed(() => {
  return baseList.value.filter(item => {
    const matchCode = item.base_code.toLowerCase().includes(searchForm.value.baseCode.toLowerCase())
    const matchName = item.base_name.toLowerCase().includes(searchForm.value.baseName.toLowerCase())
    return matchCode && matchName
  })
})

// 表单相关
const dialogVisible = ref(false)
const dialogTitle = ref('')
const baseFormRef = ref(null)
const baseForm = ref({
  base_code: '',
  base_name: '',
  dept_code: '',
  dept_name: '',
  establish_date: '',
  support_unit: '',
  major_names: [],
  partner_companies: [],
  base_type: '',
  contact_person: '',
  contact_phone: '',
  remarks: ''
})

// 表单验证规则
const rules = {
  base_code: [{ required: true, message: '请输入基地编号', trigger: 'blur' }],
  base_name: [{ required: true, message: '请输入基地名称', trigger: 'blur' }],
  dept_code: [{ required: true, message: '请输入管理单位编号', trigger: 'blur' }],
  dept_name: [{ required: true, message: '请输入管理单位名称', trigger: 'blur' }],
  establish_date: [{ required: true, message: '请选择建立日期', trigger: 'change' }],
  support_unit: [{ required: true, message: '请输入依托单位', trigger: 'blur' }],
  major_names: [{ required: true, message: '请输入适应专业', trigger: 'change' }],
  partner_companies: [{ required: true, message: '请输入合作企业', trigger: 'change' }],
  base_type: [{ required: true, message: '请选择基地类别', trigger: 'change' }],
  contact_person: [{ required: true, message: '请输入联系人', trigger: 'blur' }],
  contact_phone: [{ required: true, message: '请输入联系电话', trigger: 'blur' }]
}

// 初始化数据
onMounted(async () => {
  await loadData()
})

// 加载数据
async function loadData() {
  try {
    baseList.value = await trainingBaseAPI.getTrainingBases()
  } catch (error) {
    ElMessage.error('获取实训基地列表失败')
    console.error(error)
  }
}

// 搜索和重置
function handleSearch() {
  // 已通过计算属性实现过滤
}

function resetSearch() {
  searchForm.value = {
    baseCode: '',
    baseName: ''
  }
}

// 新增实训基地
function handleAdd() {
  dialogTitle.value = '新增实训基地'
  baseForm.value = {
    base_code: '',
    base_name: '',
    dept_code: '',
    dept_name: '',
    establish_date: '',
    support_unit: '',
    major_names: [],
    partner_companies: [],
    base_type: '',
    contact_person: '',
    contact_phone: '',
    remarks: ''
  }
  dialogVisible.value = true
}

// 编辑实训基地
function handleEdit(row) {
  dialogTitle.value = '编辑实训基地'
  baseForm.value = { ...row }
  dialogVisible.value = true
}

// 删除实训基地
async function handleDelete(row) {
  try {
    await ElMessageBox.confirm('确认删除该实训基地吗？', '提示', {
      type: 'warning'
    })
    await trainingBaseAPI.deleteTrainingBase(row.id)
    ElMessage.success('删除成功')
    await loadData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
      console.error(error)
    }
  }
}

// 提交表单
async function handleSubmit() {
  if (!baseFormRef.value) return
  
  try {
    await baseFormRef.value.validate()
    
    if (baseForm.value.id) {
      // 更新
      await trainingBaseAPI.updateTrainingBase(baseForm.value.id, baseForm.value)
      ElMessage.success('更新成功')
    } else {
      // 新增
      await trainingBaseAPI.addTrainingBase(baseForm.value)
      ElMessage.success('添加成功')
    }
    
    dialogVisible.value = false
    await loadData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('提交失败')
      console.error(error)
    }
  }
}
</script>

<style scoped>
.training-base-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 20px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 