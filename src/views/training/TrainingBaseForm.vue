<template>
  <div class="training-base-form">
    <div class="form-header">
      <h2>{{ isEdit ? '编辑实训基地' : '新增实训基地' }}</h2>
      <p class="form-subtitle">请填写实训基地相关信息</p>
    </div>
    
    <el-form
      ref="formRef"
      :model="formData"
      :rules="rules"
      label-width="100px"
      class="base-form"
    >
      <el-form-item label="基地名称" prop="name">
        <el-input v-model="formData.name" placeholder="请输入基地名称" />
      </el-form-item>
      
      <el-form-item label="管理单位" prop="deptName">
        <el-input v-model="formData.deptName" placeholder="请输入管理单位" />
      </el-form-item>
      
      <el-form-item label="依托单位" prop="supportUnit">
        <el-input v-model="formData.supportUnit" placeholder="请输入依托单位" />
      </el-form-item>

      <el-form-item label="适应专业" prop="majorNames">
        <el-select
          v-model="formData.majorNames"
          multiple
          filterable
          allow-create
          placeholder="请输入专业名称"
          class="full-width"
        />
      </el-form-item>
      
      <el-form-item label="合作企业" prop="partnerCompanies">
        <el-select
          v-model="formData.partnerCompanies"
          multiple
          filterable
          allow-create
          placeholder="请输入合作企业"
          class="full-width"
        />
      </el-form-item>
      
      <el-form-item label="基地类别" prop="baseType">
        <el-select 
          v-model="formData.baseType"
          class="full-width"
          placeholder="请选择基地类别"
        >
          <el-option label="校内实训基地" value="internal" />
          <el-option label="校外实训基地" value="external" />
        </el-select>
      </el-form-item>

      <el-form-item label="联系人" prop="contact">
        <el-input v-model="formData.contact" placeholder="请输入联系人姓名" />
      </el-form-item>
      
      <el-form-item label="联系电话" prop="phone">
        <el-input v-model="formData.phone" placeholder="请输入联系电话" />
      </el-form-item>

      <el-form-item label="备注" prop="description">
        <el-input
          v-model="formData.description"
          type="textarea"
          :rows="4"
          placeholder="请输入备注信息"
        />
      </el-form-item>
      
      <el-form-item class="form-actions">
        <el-button @click="$router.back()">返回列表</el-button>
        <el-button type="primary" @click="handleSubmit">
          {{ isEdit ? '保存修改' : '创建基地' }}
        </el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { trainingBaseService } from '@/services/trainingBase'

const route = useRoute()
const router = useRouter()
const formRef = ref()

const isEdit = computed(() => route.params.id)

const formData = ref({
  name: '',
  deptCode: '',
  deptName: '',
  supportUnit: '',
  majorNames: [],
  partnerCompanies: [],
  baseType: 'internal',
  contact: '',
  phone: '',
  description: ''
})

const rules = {
  name: [{ required: true, message: '请输入基地名称', trigger: 'blur' }],
  deptName: [{ required: true, message: '请输入管理单位', trigger: 'blur' }],
  supportUnit: [{ required: true, message: '请输入依托单位', trigger: 'blur' }],
  contact: [{ required: true, message: '请输入联系人', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入联系电话', trigger: 'blur' }]
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    const submitData = {
      base_name: formData.value.name,
      dept_name: formData.value.deptName,
      dept_code: formData.value.deptCode,
      support_unit: formData.value.supportUnit,
      major_names: formData.value.majorNames,
      partner_companies: formData.value.partnerCompanies,
      base_type: formData.value.baseType,
      contact_person: formData.value.contact,
      contact_phone: formData.value.phone,
      remarks: formData.value.description
    }
    
    if (isEdit.value) {
      await trainingBaseService.update(route.params.id, submitData)
    } else {
      await trainingBaseService.create(submitData)
    }
    
    ElMessage.success(`${isEdit.value ? '更新' : '创建'}成功`)
    router.push('/training/bases')
  } catch (error) {
    ElMessage.error(error.message || '保存失败')
  }
}

const fetchData = async () => {
  if (!isEdit.value) return
  
  try {
    const data = await trainingBaseService.getById(route.params.id)
    formData.value = {
      name: data.base_name,
      deptName: data.dept_name,
      deptCode: data.dept_code,
      supportUnit: data.support_unit,
      majorNames: data.major_names || [],
      partnerCompanies: data.partner_companies || [],
      baseType: data.base_type,
      contact: data.contact_person,
      phone: data.contact_phone,
      description: data.remarks
    }
  } catch (error) {
    ElMessage.error(error.message || '获取数据失败')
  }
}

onMounted(() => {
  if (isEdit.value) {
    fetchData()
  }
})
</script>

<style scoped>
.training-base-form {
  padding: 24px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 64px);
  max-width: 800px;
  margin: 0 auto;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
}

.form-header {
  margin-bottom: 32px;
  border-bottom: 1px solid #ebeef5;
  padding-bottom: 16px;
}

.form-header h2 {
  margin: 0;
  font-size: 24px;
  color: #303133;
}

.form-subtitle {
  margin: 8px 0 0;
  color: #909399;
  font-size: 14px;
}

.base-form {
  margin: 0 auto;
}

.full-width {
  width: 100%;
}

.form-actions {
  margin-top: 40px;
  padding-top: 24px;
  border-top: 1px solid #ebeef5;
  text-align: right;
}

.form-actions .el-button {
  padding: 12px 24px;
  min-width: 100px;
}

:deep(.el-form-item__label) {
  font-weight: 500;
}

:deep(.el-input__wrapper),
:deep(.el-textarea__inner) {
  box-shadow: 0 0 0 1px #dcdfe6;
}

:deep(.el-input__wrapper:hover),
:deep(.el-textarea__inner:hover) {
  box-shadow: 0 0 0 1px #c0c4cc;
}

:deep(.el-select .el-input__wrapper) {
  box-shadow: none;
}
</style> 