import { supabase } from './supabase'

export const authService = {
  async login(email, password) {
    return await supabase.auth.signInWithPassword({ email, password })
  },
  
  async logout() {
    return await supabase.auth.signOut()
  },
  
  async getCurrentUser() {
    return await supabase.auth.getUser()
  }
} 