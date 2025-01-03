-- 删除表和相关对象
DROP POLICY IF EXISTS "允许已认证用户查看实训基地" ON public.training_bases;
DROP POLICY IF EXISTS "允许已认证用户添加实训基地" ON public.training_bases;
DROP POLICY IF EXISTS "允许已认证用户更新实训基地" ON public.training_bases;
DROP POLICY IF EXISTS "允许已认证用户删除实训基地" ON public.training_bases;

DROP TRIGGER IF EXISTS update_training_bases_updated_at ON public.training_bases;
DROP TABLE IF EXISTS public.training_bases CASCADE;
DROP FUNCTION IF EXISTS public.update_updated_at_column CASCADE; 