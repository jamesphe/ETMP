<template>
  <base-chart
    ref="chartRef"
    :loading="loading"
  />
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import * as echarts from 'echarts'
import BaseChart from './BaseChart.vue'

const props = defineProps({
  data: {
    type: Array,
    required: true
  },
  loading: {
    type: Boolean,
    default: false
  },
  timeRange: {
    type: String,
    default: 'week'
  }
})

const chartRef = ref(null)

const updateOptions = () => {
  const options = {
    tooltip: {
      trigger: 'axis'
    },
    grid: {
      top: 20,
      right: 20,
      bottom: 20,
      left: 40,
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: props.data.map(item => item.date),
      boundaryGap: false,
      axisLine: {
        lineStyle: {
          color: '#ddd'
        }
      }
    },
    yAxis: {
      type: 'value',
      min: 0,
      max: 100,
      interval: 20,
      alignTicks: false,
      axisLine: {
        show: false
      },
      splitLine: {
        lineStyle: {
          color: '#eee'
        }
      }
    },
    series: [
      {
        data: props.data.map(item => item.value),
        type: 'line',
        smooth: true,
        symbol: 'circle',
        symbolSize: 8,
        lineStyle: {
          width: 3,
          color: '#1890ff'
        },
        itemStyle: {
          color: '#1890ff',
          borderWidth: 2,
          borderColor: '#fff'
        },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            {
              offset: 0,
              color: 'rgba(24,144,255,0.3)'
            },
            {
              offset: 1,
              color: 'rgba(24,144,255,0.1)'
            }
          ])
        }
      }
    ]
  }
  chartRef.value?.updateChart(options)
}

onMounted(() => {
  chartRef.value?.initChart()
  updateOptions()
})

watch(() => props.data, updateOptions, { deep: true })
watch(() => props.timeRange, updateOptions)
</script> 