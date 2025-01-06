-- 删除 organizations 表之前先禁用 RLS
ALTER TABLE IF EXISTS public.organizations DISABLE ROW LEVEL SECURITY;

-- 删除表（会自动删除相关的策略和触发器）
DROP TABLE IF EXISTS public.organizations CASCADE;

-- 确保使用正确的表
COMMENT ON TABLE public.organization IS '组织机构表'; 