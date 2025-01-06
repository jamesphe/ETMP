-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS ltree;

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
    'admin',           -- 行政人员
    'both',           -- 教师兼行政
    'support',        -- 教辅人员
    'worker'          -- 工勤人员
);

-- 组织机构表（支持多级组织架构）
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

COMMENT ON TABLE organization IS '组织机构表';
COMMENT ON COLUMN organization.org_code IS '机构编码';
COMMENT ON COLUMN organization.org_name IS '机构名称';
COMMENT ON COLUMN organization.org_type IS '机构类型';
COMMENT ON COLUMN organization.parent_id IS '上级机构ID';
COMMENT ON COLUMN organization.level_num IS '层级数：1-学校，2-部门，3-科室/系部，4-教研室/研究所';
COMMENT ON COLUMN organization.is_virtual IS '是否虚拟部门';

-- 教职工表
CREATE TABLE staff (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    staff_code VARCHAR(50) NOT NULL,
    staff_name VARCHAR(100) NOT NULL,
    id_number VARCHAR(18),        -- 身份证号
    gender VARCHAR(10) CHECK (gender IN ('male', 'female')),
    staff_type staff_type NOT NULL,
    org_id BIGINT NOT NULL REFERENCES organization(id), -- 主要部门
    position_title VARCHAR(50),   -- 职称
    admin_title VARCHAR(50),      -- 行政职务
    education VARCHAR(50),        -- 学历
    degree VARCHAR(50),          -- 学位
    specialty VARCHAR(100),      -- 专业特长
    email VARCHAR(100),
    phone VARCHAR(20),
    entry_date DATE,            -- 入职日期
    status SMALLINT DEFAULT 1,  -- 1:在职, 0:离职
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    CONSTRAINT uk_staff_code UNIQUE (staff_code),
    CONSTRAINT uk_staff_id_number UNIQUE (id_number)
);

-- 教职工兼职表（处理一人多岗的情况）
CREATE TABLE staff_organization (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    staff_id BIGINT NOT NULL REFERENCES staff(id),
    org_id BIGINT NOT NULL REFERENCES organization(id),
    position_type VARCHAR(20) NOT NULL DEFAULT 'part_time' CHECK (position_type IN ('main', 'part_time')), -- main:主要岗位, part_time:兼职岗位
    admin_title VARCHAR(50),      -- 在该部门的职务
    start_date DATE,             -- 任职开始日期
    end_date DATE,               -- 任职结束日期
    status SMALLINT DEFAULT 1,   -- 1:有效, 0:无效
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    CONSTRAINT uk_staff_org UNIQUE (staff_id, org_id, position_type)
);

-- 为所有表添加更新时间触发器
CREATE TRIGGER update_organization_updated_at
    BEFORE UPDATE ON organization
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_staff_updated_at
    BEFORE UPDATE ON staff
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_staff_organization_updated_at
    BEFORE UPDATE ON staff_organization
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 启用 RLS
ALTER TABLE organization ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_organization ENABLE ROW LEVEL SECURITY;

-- 创建基础的 RLS 策略
CREATE POLICY "允许所有用户查看组织机构" ON organization FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看教职工基本信息" ON staff FOR SELECT USING (true);
CREATE POLICY "允许所有用户查看教职工任职信息" ON staff_organization FOR SELECT USING (true);

-- 创建索引
CREATE INDEX idx_organization_parent_id ON organization(parent_id);
CREATE INDEX idx_organization_type ON organization(org_type);
CREATE INDEX idx_organization_level ON organization(level_num);
CREATE INDEX idx_organization_status ON organization(status);
CREATE INDEX idx_staff_org_id ON staff(org_id);
CREATE INDEX idx_staff_type ON staff(staff_type);
CREATE INDEX idx_staff_status ON staff(status);
CREATE INDEX idx_staff_organization_staff_id ON staff_organization(staff_id);
CREATE INDEX idx_staff_organization_org_id ON staff_organization(org_id); 