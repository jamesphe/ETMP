import { createRouter, createWebHistory } from 'vue-router'
import DefaultLayout from '@/layouts/DefaultLayout.vue'
import TrainingBaseList from '@/views/training/TrainingBaseList.vue'

const routes = [
  {
    path: '/',
    component: DefaultLayout,
    children: [
      {
        path: '',
        name: 'Home',
        component: () => import('@/views/Home.vue'),
        meta: { 
          requiresAuth: true,
          title: '首页'
        }
      },
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue'),
        meta: { 
          requiresAuth: true,
          title: '控制台'
        }
      },
      {
        path: '/training/bases',
        name: 'TrainingBases',
        component: () => import('@/views/training/TrainingBaseList.vue'),
        meta: {
          title: '实训基地管理',
          requiresAuth: true
        }
      },
      {
        path: '/training/bases/create',
        name: 'TrainingBaseCreate',
        component: () => import('@/views/training/TrainingBaseForm.vue'),
        meta: {
          title: '新增实训基地',
          requiresAuth: true
        }
      },
      {
        path: '/training/bases/edit/:id',
        name: 'TrainingBaseEdit',
        component: () => import('@/views/training/TrainingBaseForm.vue'),
        meta: {
          title: '编辑实训基地',
          requiresAuth: true
        }
      },
      {
        path: 'training/rooms',
        name: 'TrainingRooms',
        component: () => import('@/views/training/TrainingRoomList.vue'),
        meta: {
          title: '实训室管理',
          requiresAuth: true
        }
      },
      {
        path: 'training/projects',
        name: 'TrainingProjects',
        component: () => import('@/views/training/TrainingProjectList.vue'),
        meta: {
          title: '实训项目管理',
          requiresAuth: true
        }
      },
      {
        path: 'training/equipment',
        name: 'TrainingEquipment',
        component: () => import('@/views/training/EquipmentList.vue'),
        meta: {
          title: '实训设备管理',
          requiresAuth: true
        }
      },
      {
        path: 'training/materials',
        name: 'TrainingMaterials',
        component: () => import('@/views/training/MaterialList.vue'),
        meta: {
          title: '实训耗材管理',
          requiresAuth: true
        }
      },
      {
        path: 'training/courses',
        name: 'TrainingCourses',
        component: () => import('@/views/training/CourseList.vue'),
        meta: {
          title: '实训课程管理',
          requiresAuth: true
        }
      },
      {
        path: 'training/process',
        name: 'TrainingProcess',
        component: () => import('@/views/training/ProcessList.vue'),
        meta: {
          title: '实训过程管理',
          requiresAuth: true
        }
      },
      {
        path: 'training/notifications',
        name: 'TrainingNotifications',
        component: () => import('@/views/training/NotificationList.vue'),
        meta: {
          title: '通知与消息管理',
          requiresAuth: true
        }
      },
      {
        path: 'training/statistics',
        name: 'TrainingStatistics',
        component: () => import('@/views/training/Statistics.vue'),
        meta: {
          title: '数据统计与分析',
          requiresAuth: true
        }
      },
      {
        path: 'system/organization',
        name: 'SystemOrganization',
        component: () => import('@/views/system/organization/OrganizationList.vue'),
        meta: {
          title: '组织机构管理',
          requiresAuth: true
        }
      }
    ]
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue')
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Register.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  console.log('路由跳转开始 =>', {
    to: {
      path: to.path,
      name: to.name,
      meta: to.meta
    },
    from: {
      path: from.path,
      name: from.name
    }
  })
  
  const user = localStorage.getItem('user')
  if (to.meta.requiresAuth && !user) {
    console.log('用户未登录，重定向到登录页')
    next('/login')
  } else {
    console.log('路由验证通过')
    next()
  }
})

// 添加全局后置钩子
router.afterEach((to, from) => {
  console.log('路由跳转完成 =>', to.path)
})

export default router 