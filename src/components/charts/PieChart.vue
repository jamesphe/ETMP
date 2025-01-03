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
  }
})

const chartRef = ref(null)

const updateOptions = () => {
  const options = {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: 20,
      top: 'center',
      itemWidth: 12,
      itemHeight: 12,
      icon: 'circle'
    },
    series: [
      {
        type: 'pie',
        radius: ['50%', '70%'],
        center: ['35%', '50%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 6,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false
        },
        emphasis: {
          label: {
            show: true,
            fontSize: '14',
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: props.data
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
</script> 