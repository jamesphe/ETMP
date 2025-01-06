-- 删除已存在的视图和表
DROP VIEW IF EXISTS current_teacher_titles;
DROP VIEW IF EXISTS current_teacher_positions;
DROP TABLE IF EXISTS teacher_title_records CASCADE;
DROP TABLE IF EXISTS teacher_position_records CASCADE;
DROP TABLE IF EXISTS teacher_profiles CASCADE;

-- 教师基本信息表
CREATE TABLE teacher_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    teacher_code VARCHAR(50) NOT NULL UNIQUE,      -- 教师工号
    profile_id UUID REFERENCES profiles(id),       -- 关联用户档案
    dept_code VARCHAR(50) REFERENCES organization(org_code), -- 所属院系
    employment_date DATE NOT NULL,                 -- 入职日期
    employment_type VARCHAR(50),                   -- 聘用类型：在编、合同工等
    education_level VARCHAR(50),                   -- 学历：本科、硕士、博士
    graduation_school VARCHAR(100),                -- 毕业院校
    major_studied VARCHAR(100),                    -- 所学专业
    status VARCHAR(20) DEFAULT 'active',           -- 在职状态
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id)
);

-- 教师职称记录表
CREATE TABLE teacher_title_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    teacher_id UUID REFERENCES teacher_profiles(id),
    title_name VARCHAR(50) NOT NULL,               -- 职称名称：讲师、副教授、教授
    title_level VARCHAR(50) NOT NULL,              -- 职称等级：初级、中级、副高、正高
    certificate_no VARCHAR(100),                   -- 证书编号
    issue_date DATE NOT NULL,                      -- 获得日期
    issue_authority VARCHAR(100),                  -- 发证机构
    status VARCHAR(20) DEFAULT 'active',
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- 教师职务记录表
CREATE TABLE teacher_position_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    teacher_id UUID REFERENCES teacher_profiles(id),
    position_name VARCHAR(50) NOT NULL,            -- 职务名称：系主任、教研室主任等
    org_code VARCHAR(50) REFERENCES organization(org_code), -- 所属部门
    start_date DATE NOT NULL,                      -- 任职开始日期
    end_date DATE,                                 -- 任职结束日期
    appointment_doc VARCHAR(100),                  -- 任命文号
    status VARCHAR(20) DEFAULT 'active',           -- active: 当前职务
    handover_reason TEXT,                          -- 交接原因
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    CONSTRAINT check_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- 创建更新时间触发器
CREATE TRIGGER update_teacher_profiles_updated_at
    BEFORE UPDATE ON teacher_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 创建视图：当前职称
CREATE VIEW current_teacher_titles AS
SELECT 
    tp.teacher_code,
    p.real_name as teacher_name,
    ttr.title_name,
    ttr.title_level,
    ttr.issue_date,
    o.org_name as dept_name
FROM teacher_profiles tp
JOIN profiles p ON tp.profile_id = p.id
JOIN organization o ON tp.dept_code = o.org_code
LEFT JOIN teacher_title_records ttr ON tp.id = ttr.teacher_id
WHERE ttr.status = 'active';

-- 创建视图：当前职务
CREATE VIEW current_teacher_positions AS
SELECT 
    tp.teacher_code,
    p.real_name as teacher_name,
    tpr.position_name,
    o.org_name as dept_name,
    tpr.start_date,
    tpr.appointment_doc
FROM teacher_profiles tp
JOIN profiles p ON tp.profile_id = p.id
JOIN organization o ON tp.dept_code = o.org_code
LEFT JOIN teacher_position_records tpr ON tp.id = tpr.teacher_id
WHERE tpr.status = 'active'
AND tpr.end_date IS NULL;

-- 添加表注释
COMMENT ON TABLE teacher_profiles IS '教师基本信息表';
COMMENT ON TABLE teacher_title_records IS '教师职称记录表';
COMMENT ON TABLE teacher_position_records IS '教师职务记录表';

-- 创建索引
CREATE INDEX idx_teacher_profiles_dept_code ON teacher_profiles(dept_code);
CREATE INDEX idx_teacher_profiles_profile_id ON teacher_profiles(profile_id);
CREATE INDEX idx_teacher_profiles_status ON teacher_profiles(status);
CREATE INDEX idx_teacher_title_records_teacher_id ON teacher_title_records(teacher_id);
CREATE INDEX idx_teacher_position_records_teacher_id ON teacher_position_records(teacher_id);
CREATE INDEX idx_teacher_position_records_org_code ON teacher_position_records(org_code);

-- 启用 RLS
ALTER TABLE teacher_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_title_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_position_records ENABLE ROW LEVEL SECURITY;

-- 创建基础的 RLS 策略
CREATE POLICY "允许所有用户查看教师基本信息" ON teacher_profiles FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看教师职称信息" ON teacher_title_records FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看教师职务信息" ON teacher_position_records FOR SELECT USING (true);

-- 仅允许管理员修改
CREATE POLICY "仅管理员可修改教师信息" ON teacher_profiles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "仅管理员可修改职称信息" ON teacher_title_records
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "仅管理员可修改职务信息" ON teacher_position_records
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    ); 