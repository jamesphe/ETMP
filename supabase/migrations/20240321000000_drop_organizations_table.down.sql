-- 创建必要的触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION set_updated_by()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION set_created_by()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_by = auth.uid();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 如果需要恢复 organizations 表，从 organization 表复制结构
CREATE TABLE IF NOT EXISTS public.organizations (LIKE public.organization INCLUDING ALL);

-- 启用 RLS
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;

-- 添加基本的 RLS 策略
DO $$ 
BEGIN
    -- 删除已存在的策略
    DROP POLICY IF EXISTS "允许已认证用户查看组织" ON public.organizations;
    DROP POLICY IF EXISTS "允许已认证用户添加组织" ON public.organizations;
    DROP POLICY IF EXISTS "允许已认证用户更新组织" ON public.organizations;
    DROP POLICY IF EXISTS "允许已认证用户删除组织" ON public.organizations;

    -- 创建新的策略
    CREATE POLICY "允许已认证用户查看组织" ON public.organizations
        FOR SELECT USING (auth.role() = 'authenticated');

    CREATE POLICY "允许已认证用户添加组织" ON public.organizations
        FOR INSERT WITH CHECK (auth.role() = 'authenticated');

    CREATE POLICY "允许已认证用户更新组织" ON public.organizations
        FOR UPDATE USING (auth.role() = 'authenticated');

    CREATE POLICY "允许已认证用户删除组织" ON public.organizations
        FOR DELETE USING (auth.role() = 'authenticated');
END $$;

-- 删除已存在的触发器
DROP TRIGGER IF EXISTS update_organizations_updated_at ON public.organizations;
DROP TRIGGER IF EXISTS set_organizations_updated_by ON public.organizations;
DROP TRIGGER IF EXISTS set_organizations_created_by ON public.organizations;

-- 添加触发器
CREATE TRIGGER update_organizations_updated_at
    BEFORE UPDATE ON public.organizations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_organizations_updated_by
    BEFORE UPDATE ON public.organizations
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_by();

CREATE TRIGGER set_organizations_created_by
    BEFORE INSERT ON public.organizations
    FOR EACH ROW
    EXECUTE FUNCTION set_created_by(); 