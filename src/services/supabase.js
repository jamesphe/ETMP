import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// 创建 Supabase 客户端时添加配置以禁用日志
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    storage: window.localStorage,
    autoRefreshToken: true,
    debug: false  // 禁用调试日志
  },
  // 全局禁用日志
  logger: {
    debug: () => {},
    info: () => {},
    warn: () => {},
    error: () => {}
  }
})

// 添加会话检查
export const checkSession = async () => {
  try {
    const { data: { session }, error } = await supabase.auth.getSession()
    return { session, error }
  } catch (err) {
    return { session: null, error: err }
  }
} 