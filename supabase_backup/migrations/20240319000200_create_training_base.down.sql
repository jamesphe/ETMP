-- 删除索引
DROP INDEX IF EXISTS idx_training_bases_base_code;
DROP INDEX IF EXISTS idx_training_bases_base_name;
DROP INDEX IF EXISTS idx_training_bases_dept_code;
DROP INDEX IF EXISTS idx_training_bases_created_at;

-- 删除策略
DROP POLICY IF EXISTS "允许已认证用户查看实训基地" ON public.training_bases;
DROP POLICY IF EXISTS "允许已认证用户添加实训基地" ON public.training_bases;
DROP POLICY IF EXISTS "允许已认证用户更新实训基地" ON public.training_bases;
DROP POLICY IF EXISTS "允许已认证用户删除实训基地" ON public.training_bases;

-- 删除触发器
DROP TRIGGER IF EXISTS update_training_bases_updated_at ON public.training_bases;
DROP TRIGGER IF EXISTS set_training_bases_updated_by ON public.training_bases;
DROP TRIGGER IF EXISTS set_training_bases_created_by ON public.training_bases;

-- 删除触发器函数
DROP FUNCTION IF EXISTS public.set_updated_by CASCADE;
DROP FUNCTION IF EXISTS public.set_created_by CASCADE;

-- 删除表
DROP TABLE IF EXISTS public.training_bases CASCADE; 