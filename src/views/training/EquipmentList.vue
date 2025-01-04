<template>
  <div class="equipment-list">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>实训设备管理</span>
          <el-button type="primary" @click="handleAdd">新增设备</el-button>
        </div>
      </template>
      
      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="name" label="设备名称" />
        <el-table-column prop="code" label="设备编号" />
        <el-table-column prop="type" label="设备类型" />
        <el-table-column prop="status" label="状态" />
        <el-table-column prop="location" label="存放位置" />
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
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
// 与 TrainingRoomList 相同的脚本逻辑
</script>

<style scoped>
// 与 TrainingRoomList 相同的样式
</style> 