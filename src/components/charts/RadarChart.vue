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
      trigger: 'item'
    },
    radar: {
      indicator: [
        { name: '考勤率', max: 100 },
        { name: '作业完成率', max: 100 },
        { name: '实训成绩', max: 100 },
        { name: '课堂参与度', max: 100 },
        { name: '实训报告', max: 100 }
      ],
      radius: '65%',
      splitNumber: 4,
      axisName: {
        color: '#999'
      },
      splitLine: {
        lineStyle: {
          color: ['#eee']
        }
      },
      splitArea: {
        show: true,
        areaStyle: {
          color: ['rgba(250,250,250,0.3)', 'rgba(200,200,200,0.1)']
        }
      }
    },
    series: [
      {
        type: 'radar',
        data: [
          {
            value: props.data,
            name: '实训质量评估',
            symbol: 'circle',
            symbolSize: 6,
            lineStyle: {
              width: 2
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