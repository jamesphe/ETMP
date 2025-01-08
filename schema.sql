------------------------------------------------------------------
-- 1. 基础设置（扩展、函数和profiles表）
------------------------------------------------------------------

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS ltree;

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建用户角色枚举
CREATE TYPE user_role AS ENUM ('admin', 'teacher', 'student');

-- 创建用户档案表
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users,
    username VARCHAR(100) NOT NULL,
    real_name VARCHAR(100),
    dept_code VARCHAR(50),
    dept_name VARCHAR(100),
    role user_role NOT NULL DEFAULT 'teacher',
    phone VARCHAR(20),
    email VARCHAR(100),
    avatar_url TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- profiles表的触发器
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- profiles表的RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- profiles表的访问策略
CREATE POLICY "允许所有用户查看档案信息" ON profiles 
    FOR SELECT USING (true);
    
CREATE POLICY "用户可以更新自己的档案信息" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- profiles表的索引
CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_dept_code ON profiles(dept_code);
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_status ON profiles(status);

-- profiles表的注释
COMMENT ON TABLE profiles IS '用户档案表';
COMMENT ON COLUMN profiles.username IS '用户名';
COMMENT ON COLUMN profiles.real_name IS '真实姓名';
COMMENT ON COLUMN profiles.role IS '用户角色';

------------------------------------------------------------------
-- 2. 组织机构相关表
------------------------------------------------------------------

-- 组织机构类型枚举
CREATE TYPE org_type AS ENUM (
    'school',           -- 学校
    'party',           -- 党群部门
    'administrative',   -- 行政部门
    'academic',        -- 教学院系
    'teaching',        -- 教研室
    'research',        -- 研究所
    'service',         -- 教辅部门
    'other'            -- 其他组织
);

-- 教职工类型枚举
CREATE TYPE staff_type AS ENUM (
    'leadership',      -- 学校领导
    'teacher',         -- 专任教师
    'admin',          -- 行政人员
    'both',           -- 教师兼行政
    'support',        -- 教辅人员
    'worker',         -- 工勤人员
    'counselor',      -- 辅导员
    'researcher',     -- 科研人员
    'part_time',      -- 兼职教师
    'retired',        -- 退休返聘
    'temporary',      -- 临时聘用
    'intern'          -- 实习人员
);

-- 组织机构表
CREATE TABLE organization (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    org_code VARCHAR(50) NOT NULL,
    org_name VARCHAR(100) NOT NULL,
    org_type org_type NOT NULL,
    parent_id BIGINT REFERENCES organization(id),
    level_num SMALLINT NOT NULL,  -- 层级数：1-学校，2-部门，3-科室/系部，4-教研室/研究所
    leader_name VARCHAR(100),     -- 负责人姓名
    leader_title VARCHAR(50),     -- 负责人职务
    leader_phone VARCHAR(20),     -- 负责人电话
    description TEXT,             -- 部门职责描述
    address VARCHAR(200),         -- 办公地点
    sort_order INT DEFAULT 0,     -- 同级排序
    is_virtual BOOLEAN DEFAULT FALSE, -- 是否虚拟部门（如：临时机构、项目组等）
    status SMALLINT DEFAULT 1,    -- 1:正常, 0:停用
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    CONSTRAINT uk_org_code UNIQUE (org_code)
);

-- 教职工表
CREATE TABLE staff (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    staff_code VARCHAR(50) NOT NULL,
    staff_name VARCHAR(100) NOT NULL,
    staff_type staff_type NOT NULL,
    org_id BIGINT NOT NULL REFERENCES organization(id),
    id_number VARCHAR(18),
    gender VARCHAR(10),
    email VARCHAR(100),
    phone VARCHAR(20),
    entry_date DATE,
    status SMALLINT DEFAULT 1,
    profile_id UUID REFERENCES profiles(id),
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    CONSTRAINT uk_staff_code UNIQUE (staff_code),
    CONSTRAINT uk_staff_id_number UNIQUE (id_number)
);

-- 教师扩展信息表
CREATE TABLE teacher_info (
    staff_id BIGINT PRIMARY KEY REFERENCES staff(id),
    education_level VARCHAR(50),        -- 学历
    degree VARCHAR(50),                 -- 学位
    graduation_school VARCHAR(100),     -- 毕业院校
    major_studied VARCHAR(100),         -- 所学专业
    teaching_subject TEXT[],            -- 任教学科
    research_direction TEXT[],          -- 研究方向
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 辅导员扩展信息表
CREATE TABLE counselor_info (
    staff_id BIGINT PRIMARY KEY REFERENCES staff(id),
    student_work_years INTEGER,         -- 学生工作年限
    counseling_cert VARCHAR(50),        -- 心理咨询证书
    managed_grades TEXT[],              -- 管理的年级
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 行政人员扩展信息表
CREATE TABLE admin_info (
    staff_id BIGINT PRIMARY KEY REFERENCES staff(id),
    admin_level VARCHAR(50),            -- 行政级别
    duty_scope TEXT[],                  -- 分管工作范围
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 职称记录表
CREATE TABLE staff_title_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id BIGINT REFERENCES staff(id),
    title_name VARCHAR(50) NOT NULL,          -- 职称名称：讲师、副教授、教授
    title_level VARCHAR(50) NOT NULL,         -- 职称等级：初级、中级、副高、正高
    certificate_no VARCHAR(100),              -- 证书编号
    issue_date DATE NOT NULL,                 -- 获得日期
    issue_authority VARCHAR(100),             -- 发证机构
    status VARCHAR(20) DEFAULT 'active',
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- 职务记录表
CREATE TABLE staff_position_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id BIGINT REFERENCES staff(id),
    position_name VARCHAR(50) NOT NULL,       -- 职务名称
    org_code VARCHAR(50) REFERENCES organization(org_code),
    start_date DATE NOT NULL,
    end_date DATE,
    appointment_doc VARCHAR(100),             -- 任命文号
    status VARCHAR(20) DEFAULT 'active',
    handover_reason TEXT,
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    CONSTRAINT check_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- 教职工兼职表
CREATE TABLE staff_organization (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id BIGINT REFERENCES staff(id),
    org_id BIGINT REFERENCES organization(id),
    position VARCHAR(50),
    is_main BOOLEAN DEFAULT false,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT check_org_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- 触发器
CREATE TRIGGER update_staff_updated_at
    BEFORE UPDATE ON staff
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teacher_info_updated_at
    BEFORE UPDATE ON teacher_info
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_counselor_info_updated_at
    BEFORE UPDATE ON counselor_info
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_admin_info_updated_at
    BEFORE UPDATE ON admin_info
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_staff_organization_updated_at
    BEFORE UPDATE ON staff_organization
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS 策略
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE counselor_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_title_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_position_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_organization ENABLE ROW LEVEL SECURITY;

-- 基础查看权限
CREATE POLICY "允许所有用户查看教职工信息" ON staff FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看教师信息" ON teacher_info FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看辅导员信息" ON counselor_info FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看行政人员信息" ON admin_info FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看职称信息" ON staff_title_records FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看职务信息" ON staff_position_records FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看兼职信息" ON staff_organization FOR SELECT USING (true);

-- 管理员修改权限
CREATE POLICY "仅管理员可修改教职工信息" ON staff
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- 为其他表创建类似的管理员修改权限...

-- 索引
CREATE INDEX idx_staff_org_id ON staff(org_id);
CREATE INDEX idx_staff_type ON staff(staff_type);
CREATE INDEX idx_staff_status ON staff(status);

CREATE INDEX idx_teacher_info_staff_id ON teacher_info(staff_id);
CREATE INDEX idx_counselor_info_staff_id ON counselor_info(staff_id);
CREATE INDEX idx_admin_info_staff_id ON admin_info(staff_id);

CREATE INDEX idx_staff_title_records_staff_id ON staff_title_records(staff_id);
CREATE INDEX idx_staff_position_records_staff_id ON staff_position_records(staff_id);
CREATE INDEX idx_staff_organization_staff_id ON staff_organization(staff_id);
CREATE INDEX idx_staff_organization_org_id ON staff_organization(org_id);

-- 表注释
COMMENT ON TABLE staff IS '教职工主表';
COMMENT ON TABLE teacher_info IS '教师扩展信息表';
COMMENT ON TABLE counselor_info IS '辅导员扩展信息表';
COMMENT ON TABLE admin_info IS '行政人员扩展信息表';
COMMENT ON TABLE staff_title_records IS '职称记录表';
COMMENT ON TABLE staff_position_records IS '职务记录表';
COMMENT ON TABLE staff_organization IS '教职工兼职表';

------------------------------------------------------------------
-- 3. 班级管理相关表
------------------------------------------------------------------

-- 专业表
CREATE TABLE majors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    major_code VARCHAR(50) NOT NULL UNIQUE,
    major_name VARCHAR(100) NOT NULL,
    dept_code VARCHAR(50) REFERENCES organization(org_code),  -- 所属院系
    status VARCHAR(20) DEFAULT 'active',
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id)
);

-- 班级表
CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_code VARCHAR(50) NOT NULL UNIQUE,    -- 如：JZ21-1
    class_name VARCHAR(100) NOT NULL,          -- 如：机制21-1班
    major_code VARCHAR(50) REFERENCES majors(major_code),
    grade_year SMALLINT NOT NULL,              -- 入学年份：2021
    graduation_year SMALLINT NOT NULL,         -- 毕业年份：2024（届）
    study_length SMALLINT NOT NULL DEFAULT 3,  -- 学制：3年
    dept_code VARCHAR(50) REFERENCES organization(org_code),
    status VARCHAR(20) DEFAULT 'active',
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    CONSTRAINT check_graduation_year CHECK (graduation_year = grade_year + study_length)
);

-- 学生表
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_code VARCHAR(50) NOT NULL UNIQUE,   -- 学号
    student_name VARCHAR(100) NOT NULL,         -- 姓名
    profile_id UUID REFERENCES profiles(id),    -- 关联用户档案
    class_id UUID REFERENCES classes(id),       -- 所属班级
    major_code VARCHAR(50) REFERENCES majors(major_code),
    dept_code VARCHAR(50) REFERENCES organization(org_code),
    grade_year SMALLINT NOT NULL,              -- 入学年份
    graduation_year SMALLINT NOT NULL,          -- 毕业年份
    gender VARCHAR(10),                         -- 性别
    birth_date DATE,                           -- 出生日期
    id_number VARCHAR(18),                     -- 身份证号
    contact_phone VARCHAR(20),                 -- 联系电话
    contact_address TEXT,                      -- 联系地址
    study_status student_status DEFAULT 'active',  -- 学籍状态
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    CONSTRAINT uk_student_id_number UNIQUE (id_number)
);

-- 班主任表（修改关联到staff表）
CREATE TABLE class_advisors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID REFERENCES classes(id),
    advisor_id BIGINT REFERENCES staff(id),     -- 改为关联staff表
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    CONSTRAINT check_advisor_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- 班干部表
CREATE TABLE class_officers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID REFERENCES classes(id),
    student_id UUID REFERENCES students(id),
    position VARCHAR(50) NOT NULL,              -- 职务：班长、团支书等
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    CONSTRAINT check_officer_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- 触发器
CREATE TRIGGER update_majors_updated_at
    BEFORE UPDATE ON majors
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_classes_updated_at
    BEFORE UPDATE ON classes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_students_updated_at
    BEFORE UPDATE ON students
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 班主任检查触发器（更新为检查staff类型）
CREATE OR REPLACE FUNCTION check_advisor_is_teacher()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM staff 
        WHERE id = NEW.advisor_id
        AND staff_type IN ('teacher', 'counselor')  -- 允许教师和辅导员担任班主任
    ) THEN
        RAISE EXCEPTION '只有教师或辅导员才能被设置为班主任';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_advisor_is_teacher
    BEFORE INSERT OR UPDATE ON class_advisors
    FOR EACH ROW
    EXECUTE FUNCTION check_advisor_is_teacher();

-- 视图
CREATE VIEW current_class_advisors AS
SELECT 
    ca.id,
    c.class_code,
    c.class_name,
    c.major_code,
    c.dept_code,
    s.staff_code,
    s.staff_name as advisor_name,
    ca.start_date,
    ca.end_date,
    ca.status
FROM class_advisors ca
JOIN classes c ON ca.class_id = c.id
JOIN staff s ON ca.advisor_id = s.id
WHERE ca.status = 'active' 
AND (ca.end_date IS NULL OR ca.end_date > CURRENT_DATE);

CREATE VIEW current_class_officers AS
SELECT 
    co.id,
    c.class_code,
    c.class_name,
    s.student_code,
    s.student_name,
    co.position,
    co.start_date,
    co.end_date,
    co.status
FROM class_officers co
JOIN classes c ON co.class_id = c.id
JOIN students s ON co.student_id = s.id
WHERE co.status = 'active' 
AND (co.end_date IS NULL OR co.end_date > CURRENT_DATE);

-- RLS 策略
ALTER TABLE majors ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_advisors ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_officers ENABLE ROW LEVEL SECURITY;

-- 基础查看权限
CREATE POLICY "允许所有用户查看专业信息" ON majors FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看班级信息" ON classes FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看学生信息" ON students FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看班主任信息" ON class_advisors FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看班干部信息" ON class_officers FOR SELECT USING (true);

-- 管理员修改权限
CREATE POLICY "仅管理员可修改专业信息" ON majors
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- 为其他表创建类似的管理员修改权限...

-- 索引
CREATE INDEX idx_majors_dept_code ON majors(dept_code);
CREATE INDEX idx_majors_status ON majors(status);

CREATE INDEX idx_classes_major_code ON classes(major_code);
CREATE INDEX idx_classes_dept_code ON classes(dept_code);
CREATE INDEX idx_classes_grade_year ON classes(grade_year);

CREATE INDEX idx_students_class_id ON students(class_id);
CREATE INDEX idx_students_major_code ON students(major_code);
CREATE INDEX idx_students_dept_code ON students(dept_code);
CREATE INDEX idx_students_study_status ON students(study_status);

CREATE INDEX idx_class_advisors_class_id ON class_advisors(class_id);
CREATE INDEX idx_class_advisors_advisor_id ON class_advisors(advisor_id);

CREATE INDEX idx_class_officers_class_id ON class_officers(class_id);
CREATE INDEX idx_class_officers_student_id ON class_officers(student_id);

-- 表注释
COMMENT ON TABLE majors IS '专业信息表';
COMMENT ON TABLE classes IS '班级信息表';
COMMENT ON TABLE students IS '学生信息表';
COMMENT ON TABLE class_advisors IS '班主任信息表';
COMMENT ON TABLE class_officers IS '班干部信息表';

COMMENT ON COLUMN classes.class_code IS '班级编号';
COMMENT ON COLUMN classes.grade_year IS '入学年份';
COMMENT ON COLUMN classes.study_length IS '学制（年）';

COMMENT ON COLUMN students.student_code IS '学号';
COMMENT ON COLUMN students.study_status IS '学籍状态';

COMMENT ON COLUMN class_officers.position IS '职务：班长、团支书等';

------------------------------------------------------------------
-- 4. 班级管理相关表
------------------------------------------------------------------

-- 学生状态枚举
CREATE TYPE student_status AS ENUM (
    'active',      -- 在读
    'suspended',   -- 休学
    'transferred', -- 转学
    'withdrawn',   -- 退学
    'graduated'    -- 毕业
);

-- 学生状态变更记录表
CREATE TABLE student_status_changes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id),
    old_status student_status,
    new_status student_status,
    change_date DATE NOT NULL,
    reason TEXT,
    document_number VARCHAR(50),
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- 实训室预约表
CREATE TABLE training_room_bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_code TEXT REFERENCES training_rooms(room_code),
    booker_id UUID REFERENCES auth.users(id),
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    purpose TEXT NOT NULL,
    attendees_count INTEGER,
    status VARCHAR(20) DEFAULT 'pending',
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT check_booking_time CHECK (end_time > start_time)
);

-- 实训室使用记录表
CREATE TABLE training_room_usage_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_code TEXT REFERENCES training_rooms(room_code),
    user_id UUID REFERENCES auth.users(id),
    check_in_time TIMESTAMPTZ NOT NULL,
    check_out_time TIMESTAMPTZ,
    actual_attendees INTEGER,
    equipment_used TEXT[],
    issues_reported TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 为新表添加RLS策略
ALTER TABLE student_status_changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_room_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_room_usage_logs ENABLE ROW LEVEL SECURITY;

-- 添加基础查看权限
CREATE POLICY "允许所有用户查看学生状态变更记录" ON student_status_changes FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看实训室预约信息" ON training_room_bookings FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看实训室使用记录" ON training_room_usage_logs FOR SELECT USING (true);

-- 添加管理员修改权限
CREATE POLICY "仅管理员可修改学生状态变更记录" ON student_status_changes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- 添加索引
CREATE INDEX idx_student_status_changes_student_id ON student_status_changes(student_id);
CREATE INDEX idx_training_room_bookings_room_code ON training_room_bookings(room_code);
CREATE INDEX idx_training_room_bookings_date ON training_room_bookings(booking_date);
CREATE INDEX idx_training_room_usage_logs_room_code ON training_room_usage_logs(room_code);

-- 添加注释
COMMENT ON TABLE student_status_changes IS '学生状态变更记录表';
COMMENT ON TABLE training_room_bookings IS '实训室预约表';
COMMENT ON TABLE training_room_usage_logs IS '实训室使用记录表';

------------------------------------------------------------------
-- 5. 实训基地相关表
------------------------------------------------------------------

-- 创建基地类型枚举
CREATE TYPE base_type AS ENUM ('internal', 'external');
CREATE TYPE status_type AS ENUM ('active', 'inactive', 'deleted');

-- 实训基地表
CREATE TABLE training_bases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    base_name VARCHAR(100) NOT NULL,
    dept_code VARCHAR(50),
    dept_name VARCHAR(100) NOT NULL,
    support_unit VARCHAR(200) NOT NULL,
    base_type base_type NOT NULL DEFAULT 'internal',
    contact_person VARCHAR(50) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    address TEXT,
    capacity INT,
    manager_id UUID REFERENCES profiles(id),
    status VARCHAR(20) DEFAULT 'active',
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 实训基地图片表
CREATE TABLE training_base_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    base_id UUID REFERENCES training_bases(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_main BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 实训基地专业关联表
CREATE TABLE training_base_majors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    base_id UUID REFERENCES training_bases(id) ON DELETE CASCADE,
    major_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 实训基地合作企业关联表
CREATE TABLE training_base_companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    base_id UUID REFERENCES training_bases(id) ON DELETE CASCADE,
    company_name VARCHAR(200) NOT NULL,
    cooperation_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 实训室表
CREATE TABLE training_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,                     -- 实训室名称
    base_id UUID REFERENCES training_bases(id), -- 所属基地
    room_code TEXT UNIQUE,                  -- 房间编号
    area NUMERIC(10,2),                     -- 面积
    capacity INTEGER,                       -- 容量
    equipment_count INTEGER DEFAULT 0,      -- 设备数量
    description TEXT,                       -- 描述
    status status_type DEFAULT 'active',    -- 状态
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- 实训室设备表
CREATE TABLE training_room_equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_code TEXT NOT NULL,
    equipment_name TEXT NOT NULL,
    model_number TEXT,
    manufacturer TEXT,
    purchase_date DATE,
    unit_price DECIMAL(10,2),
    quantity INTEGER,
    status VARCHAR(20) DEFAULT 'normal',
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 实训室专业方向表
CREATE TABLE training_room_majors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_code TEXT NOT NULL,
    major_name TEXT NOT NULL,
    training_items TEXT[],
    student_capacity INTEGER,
    class_capacity INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 实训室安全信息表
CREATE TABLE training_room_safety (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_code TEXT NOT NULL,
    safety_manager TEXT NOT NULL,
    emergency_contact TEXT,
    safety_equipment TEXT[],
    safety_rules TEXT,
    emergency_procedures TEXT,
    last_inspection_date DATE,
    next_inspection_date DATE,
    status VARCHAR(20) DEFAULT 'normal',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 实训室管理人员表
CREATE TABLE training_room_managers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_code TEXT NOT NULL,
    staff_id BIGINT REFERENCES staff(id),
    position TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 触发器
CREATE TRIGGER update_training_bases_updated_at
    BEFORE UPDATE ON training_bases
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_training_rooms_updated_at
    BEFORE UPDATE ON training_rooms
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_training_room_equipment_updated_at
    BEFORE UPDATE ON training_room_equipment
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_training_room_majors_updated_at
    BEFORE UPDATE ON training_room_majors
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_training_room_safety_updated_at
    BEFORE UPDATE ON training_room_safety
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_training_room_managers_updated_at
    BEFORE UPDATE ON training_room_managers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS 策略
ALTER TABLE training_bases ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_base_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_base_majors ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_base_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_room_equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_room_majors ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_room_safety ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_room_managers ENABLE ROW LEVEL SECURITY;

-- 基础查看权限
CREATE POLICY "允许所有用户查看实训基地信息" ON training_bases FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看实训基地图片" ON training_base_images FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看实训基地专业" ON training_base_majors FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看实训基地企业" ON training_base_companies FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看实训室信息" ON training_rooms FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看实训室设备" ON training_room_equipment FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看实训室专业" ON training_room_majors FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看实训室安全信息" ON training_room_safety FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看实训室管理人员" ON training_room_managers FOR SELECT USING (true);

-- 管理员修改权限
CREATE POLICY "仅管理员可修改实训基地信息" ON training_bases
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "仅管理员可修改实训基地图片" ON training_base_images
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "仅管理员可修改实训基地专业" ON training_base_majors
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "仅管理员可修改实训基地企业" ON training_base_companies
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "仅管理员可修改实训室信息" ON training_rooms
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- 索引
CREATE INDEX idx_training_bases_dept_code ON training_bases(dept_code);
CREATE INDEX idx_training_bases_status ON training_bases(status);
CREATE INDEX idx_training_bases_base_type ON training_bases(base_type);

CREATE INDEX idx_training_base_images_base_id ON training_base_images(base_id);
CREATE INDEX idx_training_base_majors_base_id ON training_base_majors(base_id);
CREATE INDEX idx_training_base_companies_base_id ON training_base_companies(base_id);

CREATE INDEX idx_training_rooms_base_id ON training_rooms(base_id);
CREATE INDEX idx_training_rooms_status ON training_rooms(status);
CREATE INDEX idx_training_rooms_room_code ON training_rooms(room_code);

CREATE INDEX idx_training_room_equipment_room_code ON training_room_equipment(room_code);
CREATE INDEX idx_training_room_majors_room_code ON training_room_majors(room_code);
CREATE INDEX idx_training_room_safety_room_code ON training_room_safety(room_code);
CREATE INDEX idx_training_room_managers_room_code ON training_room_managers(room_code);
CREATE INDEX idx_training_room_managers_staff_id ON training_room_managers(staff_id);

-- 表注释
COMMENT ON TABLE training_bases IS '实训基地表';
COMMENT ON TABLE training_base_images IS '实训基地图片表';
COMMENT ON TABLE training_base_majors IS '实训基地专业关联表';
COMMENT ON TABLE training_base_companies IS '实训基地合作企业表';
COMMENT ON TABLE training_rooms IS '实训室表';
COMMENT ON TABLE training_room_equipment IS '实训室设备表';
COMMENT ON TABLE training_room_majors IS '实训室专业方向表';
COMMENT ON TABLE training_room_safety IS '实训室安全信息表';
COMMENT ON TABLE training_room_managers IS '实训室管理人员表';

COMMENT ON COLUMN training_bases.base_type IS '基地类型：internal-校内，external-校外';
COMMENT ON COLUMN training_rooms.room_code IS '实训室编号';
COMMENT ON COLUMN training_rooms.capacity IS '容纳人数';

------------------------------------------------------------------
-- 6. 补充约束、视图和函数
------------------------------------------------------------------

-- 外键约束
ALTER TABLE training_room_equipment 
    ADD CONSTRAINT fk_room_equipment_room_code 
    FOREIGN KEY (room_code) REFERENCES training_rooms(room_code);

ALTER TABLE training_room_majors 
    ADD CONSTRAINT fk_room_majors_room_code 
    FOREIGN KEY (room_code) REFERENCES training_rooms(room_code);

ALTER TABLE training_room_safety 
    ADD CONSTRAINT fk_room_safety_room_code 
    FOREIGN KEY (room_code) REFERENCES training_rooms(room_code);

ALTER TABLE training_room_managers 
    ADD CONSTRAINT fk_room_managers_room_code 
    FOREIGN KEY (room_code) REFERENCES training_rooms(room_code);

-- 日期检查约束
ALTER TABLE training_base_companies 
    ADD CONSTRAINT check_company_dates 
    CHECK (end_date IS NULL OR end_date >= start_date);

-- 唯一约束
ALTER TABLE training_base_majors 
    ADD CONSTRAINT uk_base_major 
    UNIQUE (base_id, major_name);

ALTER TABLE training_room_majors 
    ADD CONSTRAINT uk_room_major 
    UNIQUE (room_code, major_name);

-- 非空约束
ALTER TABLE training_room_equipment 
    ALTER COLUMN quantity SET NOT NULL;

ALTER TABLE training_room_safety 
    ALTER COLUMN emergency_contact SET NOT NULL;

-- 实训室设备统计视图
CREATE VIEW training_room_equipment_stats AS
SELECT 
    tr.room_code,
    tr.name as room_name,
    COUNT(tre.id) as equipment_count,
    SUM(tre.quantity) as total_equipment,
    SUM(tre.unit_price * tre.quantity) as total_value
FROM training_rooms tr
LEFT JOIN training_room_equipment tre ON tr.room_code = tre.room_code
GROUP BY tr.room_code, tr.name;

-- 实训基地使用情况视图
CREATE VIEW training_base_usage AS
SELECT 
    tb.id as base_id,
    tb.base_name,
    COUNT(tr.id) as room_count,
    SUM(tr.capacity) as total_capacity,
    COUNT(trm.id) as manager_count
FROM training_bases tb
LEFT JOIN training_rooms tr ON tb.id = tr.base_id
LEFT JOIN training_room_managers trm ON tr.room_code = trm.room_code
GROUP BY tb.id, tb.base_name;

-- 检查实训室容量函数
CREATE OR REPLACE FUNCTION check_room_capacity()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.student_capacity > (
        SELECT capacity 
        FROM training_rooms 
        WHERE room_code = NEW.room_code
    ) THEN
        RAISE EXCEPTION '学生容量不能超过实训室总容量';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 容量检查触发器
CREATE TRIGGER ensure_room_capacity
    BEFORE INSERT OR UPDATE ON training_room_majors
    FOR EACH ROW
    EXECUTE FUNCTION check_room_capacity();

-- 为视图添加注释
COMMENT ON VIEW training_room_equipment_stats IS '实训室设备统计视图';
COMMENT ON VIEW training_base_usage IS '实训基地使用情况视图';
COMMENT ON VIEW current_class_advisors IS '当前班主任视图';
COMMENT ON VIEW current_class_officers IS '当前班干部视图';
