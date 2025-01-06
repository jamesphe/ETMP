<template>
  <el-card class="org-tree-card">
    <el-tree
      ref="treeRef"
      :data="organizationData"
      :props="{
        children: 'children',
        label: 'org_name'
      }"
      node-key="id"
      :default-expand-all="true"
      :expand-on-click-node="false"
      highlight-current
    >
      <template #default="{ node, data }">
        <div class="custom-tree-node">
          <div class="node-info">
            <span class="org-name">{{ data.org_name }}</span>
            <span class="org-code">({{ data.org_code }})</span>
            <span v-if="data.leader_title" class="leader-title">
              - {{ data.leader_title }}
            </span>
          </div>
          <div class="operation-buttons">
            <el-button
              text
              type="primary"
              size="small"
              @click.stop="handleEdit(data)"
            >
              编辑
            </el-button>
            <el-button
              text
              type="danger"
              size="small"
              @click.stop="handleDelete(data)"
            >
              删除
            </el-button>
          </div>
        </div>
      </template>
    </el-tree>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getOrganizationTree } from '@/services/organization'

const treeRef = ref(null)
const organizationData = ref([])

// 获取组织机构数据
const fetchOrganizationData = async () => {
  try {
    const { data } = await getOrganizationTree()
    organizationData.value = data
  } catch (error) {
    console.error('获取组织机构数据失败:', error)
  }
}

const handleEdit = (data) => {
  console.log('编辑', data)
}

const handleDelete = (data) => {
  console.log('删除', data)
}

onMounted(() => {
  fetchOrganizationData()
})
</script>

<style scoped>
.org-tree-card {
  margin: 20px;
}

.custom-tree-node {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-right: 8px;
  width: 100%;
}

.node-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.org-code {
  color: #909399;
  font-size: 0.9em;
}

.leader-title {
  color: #606266;
  font-size: 0.9em;
}

.operation-buttons {
  opacity: 0;
  transition: opacity 0.2s;
  display: flex;
  gap: 8px;
}

.custom-tree-node:hover .operation-buttons {
  opacity: 1;
}

:deep(.el-tree-node__content) {
  height: auto;
  padding: 8px 0;
}
</style> 