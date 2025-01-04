<template>
  <div class="statistics">
    <el-row :gutter="20">
      <el-col :span="6" v-for="card in statisticsCards" :key="card.title">
        <el-card class="statistics-card">
          <div class="card-content">
            <div class="card-title">{{ card.title }}</div>
            <div class="card-value">{{ card.value }}</div>
            <div class="card-trend">
              <span :class="card.trend >= 0 ? 'up' : 'down'">
                {{ Math.abs(card.trend) }}%
              </span>
              较上月
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="chart-row">
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <div class="chart-header">
              <span>实训课程统计</span>
              <el-select v-model="timeRange" placeholder="选择时间范围">
                <el-option label="最近一周" value="week" />
                <el-option label="最近一月" value="month" />
                <el-option label="最近三月" value="quarter" />
              </el-select>
            </div>
          </template>
          <div class="chart-container">
            <base-chart ref="courseChart" />
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <div class="chart-header">
              <span>设备使用率</span>
              <el-select v-model="equipmentType" placeholder="选择设备类型">
                <el-option label="全部" value="all" />
                <el-option label="计算机" value="computer" />
                <el-option label="专业设备" value="professional" />
              </el-select>
            </div>
          </template>
          <div class="chart-container">
            <base-chart ref="equipmentChart" />
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import BaseChart from '@/components/charts/BaseChart.vue'

// 统计卡片数据
const statisticsCards = ref([
  { title: '实训课程总数', value: 0, trend: 5.2 },
  { title: '在训学生数', value: 0, trend: 3.1 },
  { title: '设备使用率', value: '0%', trend: -2.4 },
  { title: '耗材使用量', value: 0, trend: 1.8 }
])

// 图表相关
const timeRange = ref('week')
const equipmentType = ref('all')
const courseChart = ref(null)
const equipmentChart = ref(null)

// 课程统计图表配置
const getCourseChartOptions = (data = []) => {
  return {
    title: {
      text: '实训课程统计',
      left: 'center'
    },
    tooltip: {
      trigger: 'axis'
    },
    xAxis: {
      type: 'category',
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    },
    yAxis: {
      type: 'value'
    },
    series: [
      {
        name: '课程数',
        type: 'bar',
        data: data,
        itemStyle: {
          color: '#409EFF'
        }
      }
    ]
  }
}

// 设备使用率图表配置
const getEquipmentChartOptions = (data = []) => {
  return {
    title: {
      text: '设备使用率',
      left: 'center'
    },
    tooltip: {
      trigger: 'item'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: '使用率',
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: '20',
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: data
      }
    ]
  }
}

// 初始化图表
const initCharts = async () => {
  if (courseChart.value) {
    const chart = await courseChart.value.initChart()
    chart.setOption(getCourseChartOptions([10, 15, 8, 12, 9, 5, 7]))
  }
  
  if (equipmentChart.value) {
    const chart = await equipmentChart.value.initChart()
    chart.setOption(getEquipmentChartOptions([
      { value: 80, name: '计算机' },
      { value: 65, name: '专业设备' },
      { value: 45, name: '实验设备' }
    ]))
  }
}

// 获取统计数据
const fetchStatistics = async () => {
  try {
    // TODO: 从后端获取实际数据
    // 模拟数据
    statisticsCards.value = [
      { title: '实训课程总数', value: 125, trend: 5.2 },
      { title: '在训学生数', value: 1280, trend: 3.1 },
      { title: '设备使用率', value: '85%', trend: -2.4 },
      { title: '耗材使用量', value: 2560, trend: 1.8 }
    ]
  } catch (error) {
    console.error('获取统计数据失败:', error)
  }
}

// 监听筛选条件变化
watch([timeRange, equipmentType], async () => {
  // TODO: 根据筛选条件更新图表数据
  await updateChartData()
})

// 更新图表数据
const updateChartData = async () => {
  try {
    // TODO: 从后端获取新的图表数据
    // 这里使用模拟数据
    if (courseChart.value) {
      const chart = await courseChart.value.initChart()
      const data = timeRange.value === 'week' 
        ? [10, 15, 8, 12, 9, 5, 7]
        : [20, 25, 18, 22, 19, 15, 17]
      chart.setOption(getCourseChartOptions(data))
    }
    
    if (equipmentChart.value) {
      const chart = await equipmentChart.value.initChart()
      const data = equipmentType.value === 'all'
        ? [
            { value: 80, name: '计算机' },
            { value: 65, name: '专业设备' },
            { value: 45, name: '实验设备' }
          ]
        : [
            { value: 85, name: '在用' },
            { value: 15, name: '闲置' }
          ]
      chart.setOption(getEquipmentChartOptions(data))
    }
  } catch (error) {
    console.error('更新图表数据失败:', error)
  }
}

onMounted(() => {
  initCharts()
  fetchStatistics()
})
</script>

<style scoped>
.statistics {
  padding: 20px;
}

.statistics-card {
  margin-bottom: 20px;
}

.card-content {
  text-align: center;
}

.card-title {
  color: #909399;
  font-size: 14px;
}

.card-value {
  font-size: 24px;
  font-weight: bold;
  margin: 10px 0;
}

.card-trend {
  font-size: 12px;
  color: #909399;
}

.card-trend .up {
  color: #67C23A;
}

.card-trend .down {
  color: #F56C6C;
}

.chart-row {
  margin-top: 20px;
}

.chart-card {
  margin-bottom: 20px;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-container {
  height: 300px;
}
</style> 