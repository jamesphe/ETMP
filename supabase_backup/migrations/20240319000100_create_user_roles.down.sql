-- 删除用户角色表
DROP TABLE IF EXISTS public.user_roles;

-- 删除角色枚举类型
DROP TYPE IF EXISTS public.user_role;

-- 删除触发器函数
DROP FUNCTION IF EXISTS public.update_updated_at_column CASCADE; 