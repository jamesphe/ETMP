import { createRouter, createWebHistory } from 'vue-router'
import TrainingBaseList from '@/views/training/TrainingBaseList.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/Home.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue')
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Register.vue')
  },
  {
    path: '/training',
    name: 'Training',
    component: () => import('@/layouts/DefaultLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: 'bases',
        name: 'TrainingBases',
        component: TrainingBaseList,
        meta: {
          title: '实训基地管理',
          requiresAuth: true
        }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const user = localStorage.getItem('user')
  if (to.meta.requiresAuth && !user) {
    next('/login')
  } else {
    next()
  }
})

export default router 