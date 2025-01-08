-- 首先删除相关表（注意删除顺序，先删除引用表，再删除主表）
DROP TABLE IF EXISTS training_base_companies CASCADE;
DROP TABLE IF EXISTS training_base_majors CASCADE;
DROP TABLE IF EXISTS training_base_images CASCADE;
DROP TABLE IF EXISTS training_base CASCADE;

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

-- 为用户档案表添加更新时间触发器
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 设置用户档案表的 RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 用户档案表的访问策略
CREATE POLICY "用户可以查看所有档案信息" ON profiles
    FOR SELECT USING (true);
    
CREATE POLICY "用户可以更新自己的档案信息" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- 创建基地类型枚举
CREATE TYPE base_type AS ENUM ('internal', 'external');

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

-- 为实训基地表添加更新时间触发器
CREATE TRIGGER update_training_base_updated_at
    BEFORE UPDATE ON training_bases
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 设置 RLS 策略
ALTER TABLE training_bases ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_base_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_base_majors ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_base_companies ENABLE ROW LEVEL SECURITY;

-- 查看权限：所有认证用户可查看
CREATE POLICY "允许认证用户查看实训基地" ON training_bases
    FOR SELECT USING (true);

CREATE POLICY "允许认证用户查看实训基地图片" ON training_base_images
    FOR SELECT USING (true);

CREATE POLICY "允许认证用户查看实训基地专业" ON training_base_majors
    FOR SELECT USING (true);

CREATE POLICY "允许认证用户查看实训基地企业" ON training_base_companies
    FOR SELECT USING (true);

-- 修改权限：仅管理员可修改
CREATE POLICY "仅管理员可修改实训基地" ON training_bases
    FOR ALL USING (EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    ));

CREATE POLICY "仅管理员可修改实训基地图片" ON training_base_images
    FOR ALL USING (EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    ));

CREATE POLICY "仅管理员可修改实训基地专业" ON training_base_majors
    FOR ALL USING (EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    ));

CREATE POLICY "仅管理员可修改实训基地企业" ON training_base_companies
    FOR ALL USING (EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    ));

-- 创建索引
CREATE INDEX idx_training_base_dept_code ON training_bases(dept_code);
CREATE INDEX idx_training_base_base_type ON training_bases(base_type);
CREATE INDEX idx_training_base_status ON training_bases(status);
CREATE INDEX idx_training_base_majors_base_id ON training_base_majors(base_id);
CREATE INDEX idx_training_base_companies_base_id ON training_base_companies(base_id);

-- 添加注释
COMMENT ON TABLE training_bases IS '实训基地信息表';
COMMENT ON TABLE training_base_images IS '实训基地图片表';
COMMENT ON TABLE training_base_majors IS '实训基地适应专业关联表';
COMMENT ON TABLE training_base_companies IS '实训基地合作企业关联表';

-- 删除实训室相关表（按依赖关系顺序删除）
DROP TABLE IF EXISTS training_room_managers CASCADE;
DROP TABLE IF EXISTS training_room_safety CASCADE;
DROP TABLE IF EXISTS training_room_equipment CASCADE;
DROP TABLE IF EXISTS training_room_majors CASCADE;
DROP TABLE IF EXISTS training_rooms CASCADE;

-- 创建状态类型枚举（如果不存在）
DO $$ BEGIN
    CREATE TYPE status_type AS ENUM ('active', 'inactive', 'deleted');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 实训室主表
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

-- 添加更新时间触发器
CREATE TRIGGER update_training_rooms_updated_at
    BEFORE UPDATE ON training_rooms
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 设置 RLS 策略
ALTER TABLE training_rooms ENABLE ROW LEVEL SECURITY;

-- 查看权限：所有认证用户可查看
CREATE POLICY "允许认证用户查看实训室" ON training_rooms
    FOR SELECT USING (true);

-- 修改权限：仅管理员可修改
CREATE POLICY "仅管理员可修改实训室" ON training_rooms
    FOR ALL USING (EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    ));

-- 创建索引
CREATE INDEX idx_training_rooms_base_id ON training_rooms(base_id);
CREATE INDEX idx_training_rooms_room_code ON training_rooms(room_code);
CREATE INDEX idx_training_rooms_status ON training_rooms(status);

-- 添加注释
COMMENT ON TABLE training_rooms IS '实训室基本信息表';

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

-- 为新表添加更新时间触发器
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

-- 设置 RLS 策略
ALTER TABLE training_room_equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_room_majors ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_room_safety ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_room_managers ENABLE ROW LEVEL SECURITY;

-- 查看权限：所有认证用户可查看
CREATE POLICY "允许认证用户查看实训室设备" ON training_room_equipment
    FOR SELECT USING (true);

CREATE POLICY "允许认证用户查看实训室专业" ON training_room_majors
    FOR SELECT USING (true);

CREATE POLICY "允许认证用户查看实训室安全信息" ON training_room_safety
    FOR SELECT USING (true);

CREATE POLICY "允许认证用户查看实训室管理人员" ON training_room_managers
    FOR SELECT USING (true);

-- 修改权限：仅管理员可修改
CREATE POLICY "仅管理员可修改实训室设备" ON training_room_equipment
    FOR ALL USING (EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    ));

CREATE POLICY "仅管理员可修改实训室专业" ON training_room_majors
    FOR ALL USING (EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    ));

CREATE POLICY "仅管理员可修改实训室安全信息" ON training_room_safety
    FOR ALL USING (EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    ));

CREATE POLICY "仅管理员可修改实训室管理人员" ON training_room_managers
    FOR ALL USING (EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    ));

-- 创建索引
CREATE INDEX idx_training_room_equipment_room_code ON training_room_equipment(room_code);
CREATE INDEX idx_training_room_majors_room_code ON training_room_majors(room_code);
CREATE INDEX idx_training_room_safety_room_code ON training_room_safety(room_code);
CREATE INDEX idx_training_room_managers_room_code ON training_room_managers(room_code);
CREATE INDEX idx_training_room_managers_staff_id ON training_room_managers(staff_id);

-- 添加注释
COMMENT ON TABLE training_room_equipment IS '实训室设备信息表';
COMMENT ON TABLE training_room_majors IS '实训室专业方向关联表';
COMMENT ON TABLE training_room_safety IS '实训室安全信息表';
COMMENT ON TABLE training_room_managers IS '实训室管理人员表';

-- 为其他表添加外键约束
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