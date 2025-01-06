export const menuItems = [
  {
    path: '/dashboard',
    title: '控制台',
    icon: 'Monitor'
  },
  {
    title: '实训基础数据管理',
    icon: 'DataLine',
    children: [
      {
        path: '/training/bases',
        title: '实训基地管理',
        icon: 'OfficeBuilding'
      },
      {
        path: '/training/rooms',
        title: '实训室管理',
        icon: 'House'
      },
      {
        path: '/training/projects',
        title: '实训项目管理',
        icon: 'Collection'
      }
    ]
  },
  {
    title: '实训设备管理',
    icon: 'Tools',
    children: [
      {
        title: '设备管理',
        icon: 'Setting',
        children: [
          {
            path: '/equipment/info',
            title: '实训设备信息',
            icon: 'Document'
          },
          {
            path: '/equipment/declare',
            title: '设备申报',
            icon: 'Tickets'
          },
          {
            path: '/equipment/audit',
            title: '设备申报审核',
            icon: 'Check'
          },
          {
            path: '/equipment/purchase',
            title: '设备采购',
            icon: 'ShoppingCart'
          },
          {
            path: '/equipment/accept',
            title: '设备验收',
            icon: 'Goods'
          },
          {
            path: '/equipment/daily',
            title: '设备日常管理',
            icon: 'Management'
          }
        ]
      },
      {
        title: '设备盘点管理',
        icon: 'List',
        children: [
          {
            path: '/equipment/inventory/check',
            title: '设备盘点',
            icon: 'Operation'
          },
          {
            path: '/equipment/inventory/record',
            title: '盘点记录查询',
            icon: 'DocumentCopy'
          }
        ]
      }
    ]
  },
  {
    title: '实训耗材管理',
    icon: 'Box',
    children: [
      {
        title: '耗材申报与审核',
        icon: 'Tickets',
        children: [
          {
            path: '/materials/declare/apply',
            title: '耗材申报',
            icon: 'Edit'
          },
          {
            path: '/materials/declare/audit',
            title: '耗材申报审核',
            icon: 'Check'
          }
        ]
      },
      {
        title: '耗材采购与验收',
        icon: 'ShoppingCart',
        children: [
          {
            path: '/materials/purchase',
            title: '耗材采购',
            icon: 'Notebook'
          },
          {
            path: '/materials/accept',
            title: '耗材验收',
            icon: 'Goods'
          },
          {
            path: '/materials/storage',
            title: '耗材入库',
            icon: 'Box'
          }
        ]
      },
      {
        title: '耗材库存管理',
        icon: 'List',
        children: [
          {
            path: '/materials/stock/manage',
            title: '库存管理',
            icon: 'Management'
          },
          {
            path: '/materials/stock/query',
            title: '库存查询',
            icon: 'Search'
          }
        ]
      }
    ]
  },
  {
    title: '实训课程管理',
    icon: 'Reading',
    children: [
      {
        title: '课程计划与课表',
        icon: 'Calendar',
        children: [
          {
            path: '/course/schedule',
            title: '实训课表管理',
            icon: 'Document'
          },
          {
            path: '/course/plan',
            title: '实训计划管理',
            icon: 'Notebook'
          }
        ]
      },
      {
        title: '实训日志管理',
        icon: 'DocumentCopy',
        children: [
          {
            path: '/course/log/params',
            title: '日志参数设置',
            icon: 'Setting'
          },
          {
            path: '/course/log/write',
            title: '实训日志填写',
            icon: 'Edit'
          },
          {
            path: '/course/log/query',
            title: '日志查询',
            icon: 'Search'
          }
        ]
      }
    ]
  },
  {
    title: '实训过程管理',
    icon: 'Timer',
    children: [
      {
        path: '/process/execution',
        title: '计划执行情况',
        icon: 'Connection'
      },
      {
        path: '/process/class',
        title: '课堂管理',
        icon: 'Management'
      },
      {
        path: '/process/evaluation',
        title: '实训评估与总结',
        icon: 'Aim'
      }
    ]
  },
  {
    title: '通知与消息',
    icon: 'Bell',
    children: [
      {
        path: '/notification/notice',
        title: '通知管理',
        icon: 'Notification'
      },
      {
        path: '/notification/message',
        title: '消息管理',
        icon: 'Message'
      }
    ]
  },
  {
    title: '数据统计与分析',
    icon: 'TrendCharts',
    children: [
      {
        path: '/statistics/training',
        title: '实训数据统计',
        icon: 'DataAnalysis'
      },
      {
        path: '/statistics/student',
        title: '学生实训分析',
        icon: 'Histogram'
      }
    ]
  },
  {
    title: '系统管理',
    icon: 'Setting',
    children: [
      {
        path: '/system/organization',
        title: '组织架构管理',
        icon: 'OfficeBuilding'
      },
      {
        path: '/system/user',
        title: '用户管理',
        icon: 'User',
        children: [
          {
            path: '/system/user/teacher',
            title: '教师管理',
            icon: 'User'
          },
          {
            path: '/system/user/student',
            title: '学生管理',
            icon: 'User'
          }
        ]
      },
      {
        path: '/system/role',
        title: '角色权限管理',
        icon: 'Lock'
      },
      {
        path: '/system/dict',
        title: '字典管理',
        icon: 'Document'
      },
      {
        path: '/system/log',
        title: '系统日志',
        icon: 'Document'
      }
    ]
  }
] 