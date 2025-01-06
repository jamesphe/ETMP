-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS ltree;

-- 创建组织机构类型枚举
CREATE TYPE org_type AS ENUM (
    'school',           -- 学校
    'party',           -- 党群部门
    'administrative',   -- 行政部门
    'academic',        -- 教学院系
    'teaching',        -- 教研室
    'research',        -- 研究所
    'service',         -- 教辅部门
    'project',         -- 项目组织
    'temporary',       -- 临时机构
    'other'            -- 其他组织
);

-- 创建基础状态枚举
CREATE TYPE status_type AS ENUM (
    'active',          -- 启用
    'inactive',        -- 停用
    'deleted'          -- 删除
);

-- 创建组织机构表
CREATE TABLE organization (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,                     -- 机构名称
    code text UNIQUE,                       -- 机构代码
    org_type org_type NOT NULL,            -- 机构类型
    parent_id uuid REFERENCES organization(id), -- 上级机构ID
    path ltree,                            -- 机构路径
    level_num integer,                     -- 层级深度
    sort_order integer DEFAULT 0,          -- 排序号
    description text,                      -- 描述
    status status_type DEFAULT 'active',   -- 状态
    created_at timestamptz DEFAULT now(),  -- 创建时间
    updated_at timestamptz DEFAULT now(),  -- 更新时间
    created_by uuid,                       -- 创建人
    updated_by uuid                        -- 更新人
);

-- 创建实训基地表
CREATE TABLE training_base (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,                     -- 基地名称
    org_id uuid REFERENCES organization(id),-- 所属机构
    location text,                          -- 位置
    area numeric(10,2),                    -- 面积（平方米）
    capacity integer,                       -- 容量（人数）
    description text,                       -- 描述
    status status_type DEFAULT 'active',   -- 状态
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid,
    updated_by uuid
);

-- 创建实训室表
CREATE TABLE training_room (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,                     -- 实训室名称
    base_id uuid REFERENCES training_base(id), -- 所属基地
    room_code text UNIQUE,                 -- 房间编号
    area numeric(10,2),                    -- 面积
    capacity integer,                      -- 容量
    equipment_count integer DEFAULT 0,     -- 设备数量
    description text,                      -- 描述
    status status_type DEFAULT 'active',   -- 状态
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid,
    updated_by uuid
);

-- 创建更新时间戳触发器
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为所有表添加更新时间戳触发器
CREATE TRIGGER update_organization_timestamp
    BEFORE UPDATE ON organization
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_training_base_timestamp
    BEFORE UPDATE ON training_base
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_training_room_timestamp
    BEFORE UPDATE ON training_room
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 创建索引
CREATE INDEX idx_organization_parent_id ON organization(parent_id);
CREATE INDEX idx_organization_path ON organization USING gist(path);
CREATE INDEX idx_organization_type ON organization(org_type);
CREATE INDEX idx_organization_status ON organization(status);
CREATE INDEX idx_training_base_org_id ON training_base(org_id);
CREATE INDEX idx_training_room_base_id ON training_room(base_id);

-- 启用 RLS
ALTER TABLE organization ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_base ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_room ENABLE ROW LEVEL SECURITY;

-- 创建基础访问策略
CREATE POLICY "允许所有用户查看组织机构"
    ON organization FOR SELECT
    USING (status != 'deleted');

CREATE POLICY "允许所有用户查看实训基地"
    ON training_base FOR SELECT
    USING (status != 'deleted');

CREATE POLICY "允许所有用户查看实训室"
    ON training_room FOR SELECT
    USING (status != 'deleted');

-- 添加注释
COMMENT ON TABLE organization IS '组织机构表';
COMMENT ON TABLE training_base IS '实训基地表';
COMMENT ON TABLE training_room IS '实训室表';
