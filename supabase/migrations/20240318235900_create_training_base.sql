-- 创建实训基地表
CREATE TABLE IF NOT EXISTS public.training_bases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    base_code VARCHAR(50) UNIQUE NOT NULL,           -- 实训基地编号
    base_name VARCHAR(100) NOT NULL,                 -- 实训基地名称
    dept_code VARCHAR(50) NOT NULL,                  -- 所属管理单位号
    dept_name VARCHAR(100) NOT NULL,                 -- 所属管理单位名称
    establish_date DATE NOT NULL,                    -- 实训基地建立日期
    support_unit VARCHAR(100) NOT NULL,              -- 依托单位
    major_names TEXT[] NOT NULL,                     -- 适应专业名称(数组)
    partner_companies TEXT[] NOT NULL,               -- 基地合作企业(数组)
    base_type VARCHAR(50) NOT NULL,                  -- 实训基地类别码
    contact_person VARCHAR(50) NOT NULL,             -- 基地联系人
    contact_phone VARCHAR(20) NOT NULL,              -- 基地联系电话
    remarks TEXT,                                    -- 备注
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 创建更新时间触发器函数
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
        CREATE FUNCTION public.update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ language 'plpgsql';
    END IF;
END $$;

-- 创建触发器
DROP TRIGGER IF EXISTS update_training_bases_updated_at ON public.training_bases;
CREATE TRIGGER update_training_bases_updated_at
    BEFORE UPDATE ON public.training_bases
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 启用行级安全策略
ALTER TABLE public.training_bases ENABLE ROW LEVEL SECURITY;

-- 删除可能存在的旧策略
DROP POLICY IF EXISTS "允许已认证用户查看实训基地" ON public.training_bases;
DROP POLICY IF EXISTS "允许已认证用户添加实训基地" ON public.training_bases;
DROP POLICY IF EXISTS "允许已认证用户更新实训基地" ON public.training_bases;
DROP POLICY IF EXISTS "允许已认证用户删除实训基地" ON public.training_bases;

-- 创建访问策略
CREATE POLICY "允许已认证用户查看实训基地" ON public.training_bases
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "允许已认证用户添加实训基地" ON public.training_bases
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "允许已认证用户更新实训基地" ON public.training_bases
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "允许已认证用户删除实训基地" ON public.training_bases
    FOR DELETE USING (auth.role() = 'authenticated'); 