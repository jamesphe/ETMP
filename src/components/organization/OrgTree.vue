<template>
  <div class="org-tree">
    <el-card v-loading="loading">
      <template #header>
        <div class="card-header">
          <span>组织机构树</span>
          <el-button type="primary" @click="handleAdd">新增机构</el-button>
        </div>
      </template>
      
      <el-tree
        :data="orgTree"
        node-key="id"
        :props="defaultProps"
        draggable
        @node-click="handleNodeClick"
        @node-drag-end="handleDragEnd"
      >
        <template #default="{ node, data }">
          <div class="custom-tree-node">
            <span>{{ data.name }}</span>
            <span class="actions">
              <el-button link type="primary" @click.stop="handleEdit(data)">
                编辑
              </el-button>
              <el-button link type="danger" @click.stop="handleDelete(node, data)">
                删除
              </el-button>
            </span>
          </div>
        </template>
      </el-tree>
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
        <el-form-item label="机构名称" prop="name">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="机构类型" prop="org_type">
          <el-select v-model="form.org_type">
            <el-option label="学校" value="school" />
            <el-option label="党群部门" value="party" />
            <el-option label="行政部门" value="administrative" />
            <el-option label="教学院系" value="academic" />
            <el-option label="教研室" value="teaching" />
            <el-option label="研究所" value="research" />
            <el-option label="教辅部门" value="service" />
            <el-option label="其他" value="other" />
          </el-select>
        </el-form-item>
        <el-form-item label="上级机构" prop="parent_id">
          <el-tree-select
            v-model="form.parent_id"
            :data="orgTree"
            :props="defaultProps"
            check-strictly
          />
        </el-form-item>
        <el-form-item label="排序号" prop="sort_order">
          <el-input-number v-model="form.sort_order" :min="0" />
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
          <el-button type="primary" @click="handleSubmit">
            确定
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useOrganizationStore } from '@/stores/organization'

const store = useOrganizationStore()
const dialogVisible = ref(false)
const formRef = ref()

const defaultProps = {
  children: 'children',
  label: 'name'
}

const form = ref({
  name: '',
  org_type: '',
  parent_id: null,
  sort_order: 0,
  description: ''
})

const rules = {
  name: [{ required: true, message: '请输入机构名称', trigger: 'blur' }],
  org_type: [{ required: true, message: '请选择机构类型', trigger: 'change' }]
}

onMounted(async () => {
  await store.fetchOrgTree()
  store.initSubscription()
})

const handleNodeClick = (data) => {
  store.setCurrentOrg(data)
}

const handleAdd = () => {
  store.setCurrentOrg(null)
  form.value = {
    name: '',
    org_type: '',
    parent_id: null,
    sort_order: 0,
    description: ''
  }
  dialogVisible.value = true
}

const handleEdit = (data) => {
  store.setCurrentOrg(data)
  form.value = { ...data }
  dialogVisible.value = true
}

const handleDelete = (node, data) => {
  ElMessageBox.confirm(
    '确定要删除该机构吗？',
    '警告',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    await store.deleteOrg(data.id)
    ElMessage.success('删除成功')
  }).catch(() => {})
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (store.currentOrg) {
          await store.updateOrg(store.currentOrg.id, form.value)
        } else {
          await store.createOrg(form.value)
        }
        ElMessage.success('保存成功')
        dialogVisible.value = false
      } catch (error) {
        ElMessage.error('保存失败')
      }
    }
  })
}

const handleDragEnd = async (draggingNode, dropNode, dropType) => {
  try {
    const updates = {
      parent_id: dropType === 'inner' ? dropNode.data.id : dropNode.data.parent_id
    }
    await store.updateOrg(draggingNode.data.id, updates)
    ElMessage.success('移动成功')
  } catch (error) {
    ElMessage.error('移动失败')
  }
}
</script>

<style scoped>
.org-tree {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.custom-tree-node {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-right: 8px;
}

.actions {
  visibility: hidden;
}

.el-tree-node:hover .actions {
  visibility: visible;
}
</style> 