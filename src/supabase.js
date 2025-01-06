import { createClient } from '@supabase/supabase-js'

// 使用单例模式确保只创建一个 Supabase 客户端实例
let supabaseInstance = null

export const getSupabaseClient = () => {
  if (!supabaseInstance) {
    supabaseInstance = createClient(
      import.meta.env.VITE_SUPABASE_URL,
      import.meta.env.VITE_SUPABASE_ANON_KEY
    )
  }
  return supabaseInstance
}

export const supabase = getSupabaseClient() 