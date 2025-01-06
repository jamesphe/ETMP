-- 删除已存在的视图和表
DROP VIEW IF EXISTS current_class_officers;
DROP VIEW IF EXISTS current_class_advisors;
DROP TABLE IF EXISTS class_officers CASCADE;
DROP TABLE IF EXISTS class_advisors CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS classes CASCADE;
DROP TABLE IF EXISTS majors CASCADE;

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
    grade_year SMALLINT NOT NULL,               -- 入学年份
    graduation_year SMALLINT NOT NULL,          -- 毕业年份
    study_status VARCHAR(20) DEFAULT 'active',  -- 学籍状态：在读、休学、退学等
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id)
);

-- 班主任表
CREATE TABLE class_advisors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID REFERENCES classes(id),
    advisor_id UUID REFERENCES teacher_profiles(id),  -- 改为关联teacher_profiles
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

-- 创建更新时间触发器
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

-- 创建班主任检查触发器
CREATE OR REPLACE FUNCTION check_advisor_is_teacher()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM teacher_profiles 
        WHERE id = NEW.advisor_id
    ) THEN
        RAISE EXCEPTION '只有教师才能被设置为班主任';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_advisor_is_teacher
BEFORE INSERT OR UPDATE ON class_advisors
FOR EACH ROW
EXECUTE FUNCTION check_advisor_is_teacher();

-- 创建视图：当前班主任
CREATE VIEW current_class_advisors AS
SELECT 
    ca.id,
    c.class_code,
    c.class_name,
    c.major_code,
    c.dept_code,
    tp.teacher_code,
    p.real_name as advisor_name,
    ca.start_date,
    ca.end_date,
    ca.status
FROM class_advisors ca
JOIN classes c ON ca.class_id = c.id
JOIN teacher_profiles tp ON ca.advisor_id = tp.id
JOIN profiles p ON tp.profile_id = p.id
WHERE ca.status = 'active' 
AND (ca.end_date IS NULL OR ca.end_date > CURRENT_DATE);

-- 创建视图：当前班干部
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

-- 创建索引
CREATE INDEX idx_classes_major_code ON classes(major_code);
CREATE INDEX idx_classes_dept_code ON classes(dept_code);
CREATE INDEX idx_classes_grade_year ON classes(grade_year);
CREATE INDEX idx_students_class_id ON students(class_id);
CREATE INDEX idx_students_major_code ON students(major_code);
CREATE INDEX idx_students_dept_code ON students(dept_code);
CREATE INDEX idx_students_study_status ON students(study_status);
CREATE INDEX idx_class_advisors_advisor_id ON class_advisors(advisor_id);
CREATE INDEX idx_class_officers_student_id ON class_officers(student_id);

-- 启用 RLS
ALTER TABLE majors ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_advisors ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_officers ENABLE ROW LEVEL SECURITY;

-- 创建基础的 RLS 策略
CREATE POLICY "允许所有用户查看专业信息" ON majors FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看班级信息" ON classes FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看学生信息" ON students FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看班主任信息" ON class_advisors FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看班干部信息" ON class_officers FOR SELECT USING (true);

-- 仅允许管理员修改
CREATE POLICY "仅管理员可修改专业信息" ON majors
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "仅管理员可修改班级信息" ON classes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "仅管理员可修改班主任信息" ON class_advisors
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "仅管理员可修改班干部信息" ON class_officers
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "仅管理员可修改学生信息" ON students
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- 添加表注释
COMMENT ON TABLE majors IS '专业信息表';
COMMENT ON TABLE classes IS '班级信息表';
COMMENT ON TABLE students IS '学生信息表';
COMMENT ON TABLE class_advisors IS '班主任信息表';
COMMENT ON TABLE class_officers IS '班干部信息表'; 