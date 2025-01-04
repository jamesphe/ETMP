-- 创建实训基地表
CREATE TABLE IF NOT EXISTS public.training_bases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    base_code VARCHAR(50) UNIQUE NOT NULL,
    base_name VARCHAR(100) NOT NULL,
    dept_code VARCHAR(50) NOT NULL,
    dept_name VARCHAR(100) NOT NULL,
    establish_date DATE NOT NULL DEFAULT CURRENT_DATE,
    support_unit VARCHAR(100) NOT NULL,
    major_names TEXT[] DEFAULT '{}',
    partner_companies TEXT[] DEFAULT '{}',
    base_type VARCHAR(50) NOT NULL CHECK (base_type IN ('internal', 'external')),
    contact_person VARCHAR(50) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id)
);

-- 创建更新人触发器函数
CREATE OR REPLACE FUNCTION public.set_updated_by()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建创建人触发器函数
CREATE OR REPLACE FUNCTION public.set_created_by()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_by = auth.uid();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建触发器
CREATE TRIGGER update_training_bases_updated_at
    BEFORE UPDATE ON public.training_bases
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_training_bases_updated_by
    BEFORE UPDATE ON public.training_bases
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_by();

CREATE TRIGGER set_training_bases_created_by
    BEFORE INSERT ON public.training_bases
    FOR EACH ROW
    EXECUTE FUNCTION public.set_created_by();

-- 启用 RLS
ALTER TABLE public.training_bases ENABLE ROW LEVEL SECURITY;

-- 创建策略
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
CREATE INDEX idx_training_bases_base_code ON public.training_bases(base_code);
CREATE INDEX idx_training_bases_base_name ON public.training_bases(base_name);
CREATE INDEX idx_training_bases_dept_code ON public.training_bases(dept_code);
CREATE INDEX idx_training_bases_created_at ON public.training_bases(created_at); 