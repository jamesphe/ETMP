<template>
  <div class="chart-wrapper relative">
    <loading-overlay :loading="loading" />
    <div ref="chartRef" class="chart-container" />
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue'
import * as echarts from 'echarts'
import { useThemeStore } from '@/store/theme'
import LoadingOverlay from '@/components/common/LoadingOverlay.vue'

const props = defineProps({
  loading: {
    type: Boolean,
    default: false
  }
})

const chartRef = ref(null)
let chart = null
const themeStore = useThemeStore()

// 主题配置
const themes = {
  light: {
    backgroundColor: '#ffffff',
    textColor: '#333333',
    axisLineColor: '#e0e0e0',
    splitLineColor: '#f0f0f0'
  },
  dark: {
    backgroundColor: '#1e1e1e',
    textColor: '#ffffff',
    axisLineColor: '#434343',
    splitLineColor: '#303030'
  }
}

// 获取当前主题配置
const getCurrentTheme = () => {
  return themes[themeStore.currentTheme]
}

// 初始化图表
const initChart = async () => {
  await nextTick()
  
  if (chart) {
    chart.dispose()
  }

  if (!chartRef.value) return null

  try {
    const container = chartRef.value
    const rendererOpts = {
      devicePixelRatio: window.devicePixelRatio,
      width: container.clientWidth,
      height: container.clientHeight,
      useDirtyRect: true,
      // 添加更多事件相关配置
      renderer: 'canvas',
      pointerOptions: {
        passive: true
      }
    }
    
    chart = echarts.init(chartRef.value, null, rendererOpts)
    
    // 手动添加事件监听器
    const chartDom = chartRef.value
    chartDom.addEventListener('wheel', () => {}, { passive: true })
    chartDom.addEventListener('mousewheel', () => {}, { passive: true })
    
    // 监听容器大小变化
    const resizeObserver = new ResizeObserver(() => {
      if (chart) {
        chart.resize()
      }
    })
    resizeObserver.observe(chartRef.value)

    // 监听窗口大小变化
    window.addEventListener('resize', () => {
      if (chart) {
        chart.resize()
      }
    })

    return chart
  } catch (error) {
    console.error('Chart initialization error:', error)
    return null
  }
}

// 提供给子组件的方法
const updateChart = (options) => {
  if (!chart) return

  const theme = getCurrentTheme()
  const themeOptions = {
    backgroundColor: theme.backgroundColor,
    textStyle: {
      color: theme.textColor
    },
    axisLine: {
      lineStyle: {
        color: theme.axisLineColor
      }
    },
    splitLine: {
      lineStyle: {
        color: theme.splitLineColor
      }
    }
  }

  try {
    chart.setOption({
      ...options,
      ...themeOptions
    })
  } catch (error) {
    console.error('Chart update error:', error)
  }
}

// 暴露方法给子组件
defineExpose({
  initChart,
  updateChart
})

// 监听主题变化
watch(
  () => themeStore.currentTheme,
  () => {
    if (chart) {
      const options = chart.getOption()
      updateChart(options)
    }
  }
)

onUnmounted(() => {
  if (chart) {
    chart.dispose()
    chart = null
  }
})
</script>

<style scoped>
.chart-wrapper {
  @apply w-full h-full relative;
  min-height: 300px;
}

.chart-container {
  @apply w-full h-full absolute inset-0;
  min-height: inherit;
  /* 添加以下 CSS 属性来优化触摸和滚动行为 */
  touch-action: pan-x pan-y;
  -webkit-overflow-scrolling: touch;
  overscroll-behavior: none;
}
</style> 