<template>
  <el-container class="h-full">
    <!-- 移除左侧菜单,直接从主内容开始 -->
    <el-container class="bg-secondary">
      <!-- 主要内容区域 -->
      <el-main class="p-6">
        <!-- 顶部概览卡片 -->
        <div class="grid grid-cols-4 gap-6 mb-6">
          <div v-for="card in overviewCards" :key="card.title" class="stat-card">
            <div class="flex items-center justify-between">
              <div>
                <h3 class="text-sm text-gray-500 mb-2">{{ card.title }}</h3>
                <div class="flex items-baseline">
                  <span class="text-2xl font-bold">{{ card.value }}</span>
                  <span class="text-sm ml-2">{{ card.unit }}</span>
                </div>
              </div>
              <div :class="['stat-icon', card.trend > 0 ? 'trend-up' : 'trend-down']">
                <el-icon><component :is="card.icon" /></el-icon>
              </div>
            </div>
            <div class="mt-4 flex items-center text-sm">
              <span :class="card.trend > 0 ? 'text-success' : 'text-danger'">
                {{ Math.abs(card.trend) }}%
              </span>
              <span class="text-gray-500 ml-2">较上月</span>
            </div>
          </div>
        </div>

        <!-- 实训资源使用情况 -->
        <div class="grid grid-cols-2 gap-6 mb-6">
          <div class="chart-card">
            <div class="chart-header">
              <h3 class="chart-title">实训室使用率趋势</h3>
              <el-radio-group v-model="timeRange" size="small">
                <el-radio-button :value="'week'">本周</el-radio-button>
                <el-radio-button :value="'month'">本月</el-radio-button>
              </el-radio-group>
            </div>
            <div class="chart-content">
              <line-chart :data="usageData" :time-range="timeRange" />
            </div>
          </div>

          <div class="chart-card">
            <div class="chart-header">
              <h3 class="chart-title">设备状态分布</h3>
              <el-button-group size="small">
                <el-button type="primary" plain>导出</el-button>
                <el-button type="primary" plain>详情</el-button>
              </el-button-group>
            </div>
            <div class="chart-content">
              <pie-chart :data="equipmentData" />
            </div>
          </div>
        </div>

        <!-- 实训教学情况 -->
        <div class="grid grid-cols-3 gap-6 mb-6">
          <div class="data-card">
            <div class="data-card-header">
              <h3 class="data-card-title">待处理事项</h3>
              <el-button link type="primary">查看全部</el-button>
            </div>
            <div class="data-card-content">
              <el-scrollbar height="240px">
                <div v-for="item in todoItems" :key="item.id" class="todo-item">
                  <div class="flex items-center">
                    <el-tag :type="item.type" size="small" class="mr-2">
                      {{ item.tag }}
                    </el-tag>
                    <span class="flex-1">{{ item.title }}</span>
                    <el-button link type="primary" size="small">处理</el-button>
                  </div>
                </div>
              </el-scrollbar>
            </div>
          </div>

          <div class="data-card">
            <div class="data-card-header">
              <h3 class="data-card-title">本周课程安排</h3>
              <el-button link type="primary">课表详情</el-button>
            </div>
            <div class="data-card-content">
              <el-calendar :range="[startDate, endDate]" />
            </div>
          </div>

          <div class="data-card">
            <div class="data-card-header">
              <h3 class="data-card-title">实训质量分析</h3>
              <el-button link type="primary">完整报告</el-button>
            </div>
            <div class="data-card-content">
              <radar-chart :data="qualityData" />
            </div>
          </div>
        </div>

        <!-- 预警信息 -->
        <div class="alert-section">
          <div class="alert-header">
            <h3 class="alert-title">系统预警</h3>
            <el-switch v-model="alertEnabled" />
          </div>
          <div class="grid grid-cols-4 gap-4">
            <div v-for="alert in alerts" :key="alert.id" 
              class="alert-card" :class="alert.level">
              <el-icon class="alert-icon"><Warning /></el-icon>
              <div class="alert-content">
                <h4 class="alert-name">{{ alert.name }}</h4>
                <p class="alert-desc">{{ alert.description }}</p>
              </div>
            </div>
          </div>
        </div>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useThemeStore } from '@/store/theme'

// 导入图表组件
import LineChart from '@/components/charts/LineChart.vue'
import PieChart from '@/components/charts/PieChart.vue'
import RadarChart from '@/components/charts/RadarChart.vue'

const themeStore = useThemeStore()
const isDarkTheme = computed(() => themeStore.currentTheme === 'dark')

// 主题切换函数
const toggleTheme = () => {
  themeStore.setTheme(isDarkTheme.value ? 'light' : 'dark')
}

// 顶部概览数据
const overviewCards = [
  {
    title: '在培学员',
    value: '1,280',
    unit: '人',
    icon: 'User',
    trend: 5.2
  },
  {
    title: '设备完好率',
    value: '98.5',
    unit: '%',
    icon: 'Tools',
    trend: -0.3
  },
  {
    title: '实训室利用率',
    value: '85.2',
    unit: '%',
    icon: 'OfficeBuilding',
    trend: 3.1
  },
  {
    title: '耗材库存预警',
    value: '3',
    unit: '项',
    icon: 'Warning',
    trend: -25
  }
]

// 添加图表数据
const timeRange = ref('week')

// 实训室使用率趋势数据
const usageData = ref([
  { date: '周一', value: 85 },
  { date: '周二', value: 92 },
  { date: '周三', value: 78 },
  { date: '周四', value: 88 },
  { date: '周五', value: 95 },
  { date: '周六', value: 62 },
  { date: '周日', value: 45 }
])

// 设备状态分布数据
const equipmentData = ref([
  { value: 235, name: '正常使用', itemStyle: { color: '#52c41a' } },
  { value: 18, name: '维修中', itemStyle: { color: '#faad14' } },
  { value: 12, name: '待维修', itemStyle: { color: '#ff4d4f' } },
  { value: 8, name: '报废', itemStyle: { color: '#bfbfbf' } }
])

// 实训质量分析数据
const qualityData = ref([92, 88, 85, 90, 87])

// 待处理事项数据
const todoItems = ref([
  {
    id: 1,
    type: 'warning',
    tag: '设备维修',
    title: '3号实训室投影仪需要维修',
    time: '2小时前'
  },
  {
    id: 2,
    type: 'info',
    tag: '耗材申购',
    title: '电子元器件库存不足',
    time: '4小时前'
  },
  {
    id: 3,
    type: 'success',
    tag: '课程安排',
    title: '新增物联网实训课程计划待审核',
    time: '1天前'
  },
  {
    id: 4,
    type: 'danger',
    tag: '设备故障',
    title: 'CNC设备需要紧急维修',
    time: '1天前'
  }
])

// 系统预警数据
const alertEnabled = ref(true)
const alerts = ref([
  {
    id: 1,
    level: 'critical',
    name: '设备故障',
    description: '2个设备需要维修',
    icon: 'Tools'
  },
  {
    id: 2,
    level: 'warning',
    name: '库存预警',
    description: '3项耗材库存不足',
    icon: 'Box'
  },
  {
    id: 3,
    level: 'info',
    name: '课程提醒',
    description: '本周新增2门课程',
    icon: 'Reading'
  },
  {
    id: 4,
    level: 'success',
    name: '系统状态',
    description: '运行正常',
    icon: 'Check'
  }
])

// 日历相关
const startDate = ref(new Date())
const endDate = ref(new Date())
endDate.value.setDate(startDate.value.getDate() + 6)
</script>

<style>
/* 导入字体 */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

/* 全局样式 */
:root {
  --font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --transition-speed: 0.3s;
}

/* 基础样式 */
body {
  font-family: var(--font-family);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* 主题切换过渡效果 */
* {
  transition: background-color var(--transition-speed),
              border-color var(--transition-speed),
              color var(--transition-speed),
              box-shadow var(--transition-speed);
}

/* 数据卡片样式 */
.dashboard-card {
  background-color: var(--theme-bg-container);
  border-radius: 12px;
  padding: 24px;
  box-shadow: var(--theme-shadow);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.dashboard-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.stat-icon.text-blue-500 { background-color: rgba(24, 144, 255, 0.1); color: #1890ff; }
.stat-icon.text-green-500 { background-color: rgba(82, 196, 26, 0.1); color: #52c41a; }
.stat-icon.text-purple-500 { background-color: rgba(114, 46, 209, 0.1); color: #722ed1; }
.stat-icon.text-orange-500 { background-color: rgba(250, 173, 20, 0.1); color: #faad14; }

/* 图表卡片样式 */
.chart-card {
  background-color: var(--theme-bg-container);
  border-radius: 12px;
  box-shadow: var(--theme-shadow);
  height: 400px;
  overflow: hidden;
}

.chart-header {
  padding: 16px 24px;
  border-bottom: 1px solid var(--theme-border-split);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.chart-content {
  padding: 24px;
  height: calc(100% - 65px);
}

/* 统计卡片样式 */
.stat-card {
  @apply bg-white rounded-lg p-6 shadow-sm;
}

.stat-icon {
  @apply w-12 h-12 rounded-full flex items-center justify-center text-xl;
}

.trend-up {
  @apply bg-success bg-opacity-10 text-success;
}

.trend-down {
  @apply bg-danger bg-opacity-10 text-danger;
}

/* 数据卡片样式 */
.data-card {
  @apply bg-white rounded-lg shadow-sm overflow-hidden;
}

.data-card-header {
  @apply flex items-center justify-between p-4 border-b;
}

.data-card-title {
  @apply text-base font-medium;
}

.data-card-content {
  @apply p-4;
}

/* 待办事项样式 */
.todo-item {
  @apply py-3 px-4 border-b last:border-0 hover:bg-gray-50 transition-colors;
}

.todo-item .el-tag {
  @apply px-2 py-1 text-xs font-medium;
}

.todo-item .time {
  @apply text-xs text-gray-400 mt-1;
}

/* 预警卡片样式 */
.alert-section {
  @apply bg-white rounded-lg p-6 shadow-sm;
}

.alert-header {
  @apply flex items-center justify-between mb-4;
}

.alert-card {
  @apply flex items-start p-4 rounded-lg transition-transform hover:transform hover:scale-105;
}

.alert-card.critical {
  @apply bg-red-50 text-red-700;
}

.alert-card.warning {
  @apply bg-yellow-50 text-yellow-700;
}

.alert-card.info {
  @apply bg-blue-50 text-blue-700;
}

.alert-card.success {
  @apply bg-green-50 text-green-700;
}

.alert-icon {
  @apply text-2xl mr-3 opacity-75;
}

.alert-name {
  @apply font-medium text-sm mb-1;
}

.alert-desc {
  @apply text-xs opacity-75;
}

/* 图表卡片样式优化 */
.chart-card {
  @apply bg-white rounded-lg shadow-sm transition-shadow hover:shadow-md;
}

.chart-header {
  @apply p-4 border-b border-gray-100 flex justify-between items-center;
}

.chart-title {
  @apply text-base font-medium text-gray-700;
}

.chart-content {
  @apply p-4 h-[360px];
}
</style> 