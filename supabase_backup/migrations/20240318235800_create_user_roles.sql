-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建角色枚举类型
CREATE TYPE public.user_role AS ENUM ('admin', 'manager', 'teacher', 'student');

-- 创建用户角色表
CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, role)
);

-- 创建更新时间触发器
CREATE TRIGGER update_user_roles_updated_at
    BEFORE UPDATE ON public.user_roles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 启用 RLS
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- 创建策略
CREATE POLICY "允许管理员查看所有角色" ON public.user_roles
    FOR SELECT USING (
        auth.role() = 'authenticated' AND EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "允许用户查看自己的角色" ON public.user_roles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "只允许管理员添加角色" ON public.user_roles
    FOR INSERT WITH CHECK (
        auth.role() = 'authenticated' AND EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "只允许管理员修改角色" ON public.user_roles
    FOR UPDATE USING (
        auth.role() = 'authenticated' AND EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "只允许管理员删除角色" ON public.user_roles
    FOR DELETE USING (
        auth.role() = 'authenticated' AND EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    ); 