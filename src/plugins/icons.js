import { 
  HomeFilled,
  OfficeBuilding,
  School,
  Fold,
  Expand
} from '@element-plus/icons-vue'

export const icons = {
  HomeFilled,
  OfficeBuilding,
  School,
  Fold,
  Expand
}

export default {
  install(app) {
    for (const [key, component] of Object.entries(icons)) {
      app.component(key, component)
    }
  }
} 