-- 创建实训基地表
CREATE TABLE IF NOT EXISTS public.training_bases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    base_code VARCHAR(50) UNIQUE NOT NULL,           -- 实训基地编号
    base_name VARCHAR(100) NOT NULL,                 -- 实训基地名称
    dept_code VARCHAR(50) NOT NULL,                  -- 所属管理单位号
    dept_name VARCHAR(100) NOT NULL,                 -- 所属管理单位名称
    establish_date DATE NOT NULL DEFAULT CURRENT_DATE, -- 实训基地建立日期
    support_unit VARCHAR(100) NOT NULL,              -- 依托单位
    major_names TEXT[] DEFAULT '{}',                 -- 适应专业名称(数组)
    partner_companies TEXT[] DEFAULT '{}',           -- 基地合作企业(数组)
    base_type VARCHAR(50) NOT NULL                   -- 基地类别(internal/external)
        CHECK (base_type IN ('internal', 'external')),
    contact_person VARCHAR(50) NOT NULL,             -- 基地联系人
    contact_phone VARCHAR(20) NOT NULL,              -- 基地联系电话
    remarks TEXT,                                    -- 备注
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),       -- 创建人
    updated_by UUID REFERENCES auth.users(id)        -- 更新人
);

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建更新时间触发器
DROP TRIGGER IF EXISTS update_training_bases_updated_at ON public.training_bases;
CREATE TRIGGER update_training_bases_updated_at
    BEFORE UPDATE ON public.training_bases
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 创建更新人触发器函数
CREATE OR REPLACE FUNCTION public.set_updated_by()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建更新人触发器
DROP TRIGGER IF EXISTS set_training_bases_updated_by ON public.training_bases;
CREATE TRIGGER set_training_bases_updated_by
    BEFORE UPDATE ON public.training_bases
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_by();

-- 创建创建人触发器函数
CREATE OR REPLACE FUNCTION public.set_created_by()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_by = auth.uid();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建创建人触发器
DROP TRIGGER IF EXISTS set_training_bases_created_by ON public.training_bases;
CREATE TRIGGER set_training_bases_created_by
    BEFORE INSERT ON public.training_bases
    FOR EACH ROW
    EXECUTE FUNCTION public.set_created_by();

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
    FOR UPDATE USING (
        auth.role() = 'authenticated' AND (
            auth.uid() = created_by OR 
            EXISTS (
                SELECT 1 FROM public.user_roles 
                WHERE user_id = auth.uid() 
                AND role IN ('admin', 'manager')
            )
        )
    );

CREATE POLICY "允许已认证用户删除实训基地" ON public.training_bases
    FOR DELETE USING (
        auth.role() = 'authenticated' AND (
            auth.uid() = created_by OR 
            EXISTS (
                SELECT 1 FROM public.user_roles 
                WHERE user_id = auth.uid() 
                AND role IN ('admin', 'manager')
            )
        )
    );

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_training_bases_base_code ON public.training_bases(base_code);
CREATE INDEX IF NOT EXISTS idx_training_bases_base_name ON public.training_bases(base_name);
CREATE INDEX IF NOT EXISTS idx_training_bases_dept_code ON public.training_bases(dept_code);
CREATE INDEX IF NOT EXISTS idx_training_bases_created_at ON public.training_bases(created_at); 