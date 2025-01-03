<template>
  <main-layout>
    <el-container class="h-full">
      <!-- 左侧导航栏 -->
      <el-aside width="240px" class="bg-sidebar border-r border-light">
        <!-- Logo区域 -->
        <div class="py-5 px-6 border-b border-light">
          <h1 class="text-xl font-semibold tracking-wide">
            <el-icon class="mr-2 text-primary"><Monitor /></el-icon>
            实训管理平台
          </h1>
        </div>
        
        <!-- 导航菜单 -->
        <div class="py-4">
          <el-menu 
            class="border-none font-medium"
            :default-active="activeMenu"
            @select="handleSelect"
          >
            <!-- 实训基础数据管理 -->
            <el-sub-menu index="basic-data" class="menu-sub">
              <template #title>
                <el-icon><DataLine /></el-icon>
                <span>实训基础数据管理</span>
              </template>
              <el-menu-item index="training-base">
                <el-icon><OfficeBuilding /></el-icon>实训基地管理
              </el-menu-item>
              <el-menu-item index="training-room">
                <el-icon><House /></el-icon>实训室管理
              </el-menu-item>
              <el-menu-item index="training-project">
                <el-icon><Collection /></el-icon>实训项目管理
              </el-menu-item>
            </el-sub-menu>

            <!-- 实训设备管理 -->
            <el-sub-menu index="equipment" class="menu-sub">
              <template #title>
                <el-icon><Tools /></el-icon>
                <span>实训设备管理</span>
              </template>
              <!-- 设备管理子菜单 -->
              <el-sub-menu index="equipment-manage">
                <template #title>
                  <el-icon><Setting /></el-icon>设备管理
                </template>
                <el-menu-item index="equipment-info">
                  <el-icon><Document /></el-icon>实训设备信息
                </el-menu-item>
                <el-menu-item index="equipment-declare">
                  <el-icon><Tickets /></el-icon>设备申报
                </el-menu-item>
                <el-menu-item index="equipment-declare-audit">
                  <el-icon><Check /></el-icon>设备申报审核
                </el-menu-item>
                <el-menu-item index="equipment-purchase">
                  <el-icon><ShoppingCart /></el-icon>设备采购
                </el-menu-item>
                <el-menu-item index="equipment-accept">
                  <el-icon><Goods /></el-icon>设备验收
                </el-menu-item>
                <el-menu-item index="equipment-daily">
                  <el-icon><Management /></el-icon>设备日常管理
                </el-menu-item>
              </el-sub-menu>
              <!-- 设备盘点管理子菜单 -->
              <el-sub-menu index="equipment-inventory">
                <template #title>
                  <el-icon><List /></el-icon>设备盘点管理
                </template>
                <el-menu-item index="inventory-check">
                  <el-icon><Operation /></el-icon>设备盘点
                </el-menu-item>
                <el-menu-item index="inventory-record">
                  <el-icon><DocumentCopy /></el-icon>盘点记录查询
                </el-menu-item>
              </el-sub-menu>
            </el-sub-menu>

            <!-- 实训耗材管理 -->
            <el-sub-menu index="materials" class="menu-sub">
              <template #title>
                <el-icon><Box /></el-icon>
                <span>实训耗材管理</span>
              </template>
              <!-- 耗材申报与审核 -->
              <el-sub-menu index="materials-declare">
                <template #title>
                  <el-icon><Tickets /></el-icon>耗材申报与审核
                </template>
                <el-menu-item index="materials-declare-apply">
                  <el-icon><Edit /></el-icon>耗材申报
                </el-menu-item>
                <el-menu-item index="materials-declare-audit">
                  <el-icon><Check /></el-icon>耗材申报审核
                </el-menu-item>
              </el-sub-menu>
              <!-- 耗材采购与验收 -->
              <el-sub-menu index="materials-purchase">
                <template #title>
                  <el-icon><ShoppingCart /></el-icon>耗材采购与验收
                </template>
                <el-menu-item index="materials-purchase-order">
                  <el-icon><Notebook /></el-icon>耗材采购
                </el-menu-item>
                <el-menu-item index="materials-accept">
                  <el-icon><Goods /></el-icon>耗材验收
                </el-menu-item>
                <el-menu-item index="materials-storage">
                  <el-icon><Box /></el-icon>耗材入库
                </el-menu-item>
              </el-sub-menu>
              <!-- 耗材库存管理 -->
              <el-sub-menu index="materials-stock">
                <template #title>
                  <el-icon><List /></el-icon>耗材库存管理
                </template>
                <el-menu-item index="stock-manage">
                  <el-icon><Management /></el-icon>库存管理
                </el-menu-item>
                <el-menu-item index="stock-query">
                  <el-icon><Search /></el-icon>库存查询
                </el-menu-item>
              </el-sub-menu>
              <!-- 耗材领用与统计 -->
              <el-sub-menu index="materials-use">
                <template #title>
                  <el-icon><Operation /></el-icon>耗材领用与统计
                </template>
                <el-menu-item index="materials-apply">
                  <el-icon><Tickets /></el-icon>耗材领用申请
                </el-menu-item>
                <el-menu-item index="materials-audit">
                  <el-icon><Check /></el-icon>耗材领用审核
                </el-menu-item>
                <el-menu-item index="materials-query">
                  <el-icon><Search /></el-icon>领用查询
                </el-menu-item>
                <el-menu-item index="materials-usage">
                  <el-icon><DataAnalysis /></el-icon>使用情况查询
                </el-menu-item>
              </el-sub-menu>
            </el-sub-menu>

            <!-- 实训课程管理 -->
            <el-sub-menu index="course" class="menu-sub">
              <template #title>
                <el-icon><Reading /></el-icon>
                <span>实训课程管理</span>
              </template>
              <!-- 课程计划与课表 -->
              <el-sub-menu index="course-schedule">
                <template #title>
                  <el-icon><Calendar /></el-icon>课程计划与课表
                </template>
                <el-menu-item index="schedule-manage">
                  <el-icon><Document /></el-icon>实训课表管理
                </el-menu-item>
                <el-menu-item index="plan-manage">
                  <el-icon><Notebook /></el-icon>实训计划管理
                </el-menu-item>
              </el-sub-menu>
              <!-- 实训日志管理 -->
              <el-sub-menu index="course-log">
                <template #title>
                  <el-icon><DocumentCopy /></el-icon>实训日志管理
                </template>
                <el-menu-item index="log-params">
                  <el-icon><Setting /></el-icon>日志参数设置
                </el-menu-item>
                <el-menu-item index="log-write">
                  <el-icon><Edit /></el-icon>实训日志填写
                </el-menu-item>
                <el-menu-item index="log-query">
                  <el-icon><Search /></el-icon>日志解锁与查询
                </el-menu-item>
              </el-sub-menu>
              <!-- 考勤与课堂活动 -->
              <el-sub-menu index="course-activity">
                <template #title>
                  <el-icon><VideoCamera /></el-icon>考勤与课堂活动
                </template>
                <el-menu-item index="attendance">
                  <el-icon><Clock /></el-icon>实训考勤
                </el-menu-item>
                <el-menu-item index="interaction">
                  <el-icon><ChatLineRound /></el-icon>教师课堂互动
                </el-menu-item>
              </el-sub-menu>
            </el-sub-menu>

            <!-- 实训过程管理 -->
            <el-sub-menu index="process" class="menu-sub">
              <template #title>
                <el-icon><Timer /></el-icon>
                <span>实训过程管理</span>
              </template>
              <el-menu-item index="plan-execution">
                <el-icon><Connection /></el-icon>计划执行情况
              </el-menu-item>
              <el-menu-item index="class-manage">
                <el-icon><Management /></el-icon>课堂管理
              </el-menu-item>
              <el-menu-item index="training-evaluation">
                <el-icon><Aim /></el-icon>实训评估与总结
              </el-menu-item>
            </el-sub-menu>

            <!-- 通知与消息管理 -->
            <el-sub-menu index="notification" class="menu-sub">
              <template #title>
                <el-icon><Bell /></el-icon>
                <span>通知与消息管理</span>
              </template>
              <el-menu-item index="notice-manage">
                <el-icon><Notification /></el-icon>通知管理
              </el-menu-item>
              <el-menu-item index="message-manage">
                <el-icon><Message /></el-icon>消息管理
              </el-menu-item>
            </el-sub-menu>

            <!-- 数据统计与分析 -->
            <el-sub-menu index="statistics" class="menu-sub">
              <template #title>
                <el-icon><TrendCharts /></el-icon>
                <span>数据统计与分析</span>
              </template>
              <el-menu-item index="training-statistics">
                <el-icon><DataAnalysis /></el-icon>
                实训数据统计
              </el-menu-item>
              <el-menu-item index="student-analysis">
                <el-icon><Histogram /></el-icon>
                学生实训数据分析
              </el-menu-item>
            </el-sub-menu>
          </el-menu>
        </div>
      </el-aside>

      <!-- 右侧内容区 -->
      <el-container class="bg-secondary">
        <!-- 顶部导航栏 -->
        <el-header height="64px" class="bg-header border-b border-light px-6">
          <div class="flex justify-between items-center h-full">
            <!-- 面包屑导航 -->
            <div class="flex items-center">
              <el-breadcrumb separator="/">
                <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
                <el-breadcrumb-item>{{ currentMenuTitle }}</el-breadcrumb-item>
              </el-breadcrumb>
            </div>
            
            <!-- 右侧工具栏 -->
            <div class="flex items-center space-x-4">
              <!-- 主题切换按钮 -->
              <el-tooltip 
                :content="isDarkTheme ? '切换到浅色模式' : '切换到深色模式'"
                placement="bottom"
              >
                <el-button
                  class="theme-toggle"
                  :icon="isDarkTheme ? 'Sunny' : 'Moon'"
                  circle
                  @click="toggleTheme"
                />
              </el-tooltip>
              
              <!-- 用户信息 -->
              <el-dropdown>
                <span class="flex items-center cursor-pointer">
                  <el-avatar size="small" class="mr-2">管理员</el-avatar>
                  <span class="text-sm">Admin</span>
                  <el-icon class="ml-1"><CaretBottom /></el-icon>
                </span>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item>个人信息</el-dropdown-item>
                    <el-dropdown-item>修改密码</el-dropdown-item>
                    <el-dropdown-item divided>退出登录</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </div>
        </el-header>

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
  </main-layout>
</template>

<script setup>
import { ref, computed } from 'vue'
import MainLayout from '@/components/layout/MainLayout.vue'
import { 
  Location, Tools, Box, Reading, DataLine, User, Calendar, 
  Moon, Sunny, Monitor, CaretBottom, Download,
  Setting, Document, Timer, Bell, TrendCharts,
  Tickets, Check, ShoppingCart, Goods, List,
  Management, Operation, DocumentCopy, Clock,
  Notification, Message, Histogram,
  OfficeBuilding, House, Collection, Briefcase,
  Notebook, Edit, Search, VideoCamera, Aim,
  Connection, ChatLineRound, DataAnalysis,
  Warning
} from '@element-plus/icons-vue'
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

const activeMenu = ref('training-base')
const chartTimeRange = ref('month')
const currentMenuTitle = ref('实训基地管理')

const handleSelect = (index) => {
  activeMenu.value = index
  // 根据选中的菜单项更新面包屑标题
  const menuTitles = {
    'training-base': '实训基地管理',
    'equipment-list': '设备列表',
    'equipment-maintenance': '设备维护',
    'materials-list': '耗材列表',
    'materials-stock': '库存管理',
    'course-list': '课程列表',
    'course-schedule': '课程安排'
  }
  currentMenuTitle.value = menuTitles[index] || '实训基地管理'
}

// 仪表盘卡片数据
const dashboardCards = [
  {
    icon: DataLine,
    iconColor: 'text-blue-500',
    title: '实训室总数',
    value: '24'
  },
  {
    icon: Tools,
    iconColor: 'text-green-500',
    title: '设备总数',
    value: '358'
  },
  {
    icon: User,
    iconColor: 'text-purple-500',
    title: '在培学员',
    value: '1,280'
  },
  {
    icon: Calendar,
    iconColor: 'text-orange-500',
    title: '本月课程数',
    value: '46'
  }
]

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

/* 导航菜单样式优化 */
.el-menu {
  --el-menu-item-height: 48px;
}

.menu-item {
  margin: 4px 0;
  border-radius: 6px;
}

.el-menu-item.is-active {
  font-weight: 600;
}

/* 主题切换按钮样式 */
.theme-toggle {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.theme-toggle:hover {
  background-color: var(--theme-hover);
  transform: rotate(15deg);
}

/* 导出按钮样式 */
.export-btn {
  border-radius: 6px;
  font-weight: 500;
}

/* Element Plus 组件样式覆盖 */
.el-breadcrumb__item {
  font-weight: 500 !important;
}

.el-radio-button__inner {
  border-radius: 6px !important;
}

.el-dropdown-menu {
  border-radius: 8px !important;
  padding: 4px !important;
}

.el-dropdown-menu__item {
  border-radius: 4px !important;
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