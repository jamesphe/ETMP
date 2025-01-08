------------------------------------------------------------------
-- 基础设置
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

------------------------------------------------------------------
-- 组织机构相关表
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
    'admin',           -- 行政人员
    'both',           -- 教师兼行政
    'support',        -- 教辅人员
    'worker'          -- 工勤人员
);

-- 组织机构表
CREATE TABLE organization (
    -- [原organization表的完整定义]
);

-- 教职工表
CREATE TABLE staff (
    -- [原staff表的完整定义]
);

-- 教职工兼职表
CREATE TABLE staff_organization (
    -- [原staff_organization表的完整定义]
);

------------------------------------------------------------------
-- 教师管理相关表
------------------------------------------------------------------

-- 教师基本信息表
CREATE TABLE teacher_profiles (
    -- [原teacher_profiles表的完整定义]
);

-- 教师职称记录表
CREATE TABLE teacher_title_records (
    -- [原teacher_title_records表的完整定义]
);

-- 教师职务记录表
CREATE TABLE teacher_position_records (
    -- [原teacher_position_records表的完整定义]
);

------------------------------------------------------------------
-- 班级管理相关表
------------------------------------------------------------------

-- 专业表
CREATE TABLE majors (
    -- [原majors表的完整定义]
);

-- 班级表
CREATE TABLE classes (
    -- [原classes表的完整定义]
);

-- 学生表
CREATE TABLE students (
    -- [原students表的完整定义]
);

-- 班主任表
CREATE TABLE class_advisors (
    -- [原class_advisors表的完整定义]
);

-- 班干部表
CREATE TABLE class_officers (
    -- [原class_officers表的完整定义]
);

------------------------------------------------------------------
-- 实训基地相关表
------------------------------------------------------------------

-- 创建基地类型枚举
CREATE TYPE base_type AS ENUM ('internal', 'external');
CREATE TYPE status_type AS ENUM ('active', 'inactive', 'deleted');

-- 实训基地表
CREATE TABLE training_bases (
    -- [原training_bases表的完整定义]
);

-- 实训基地图片表
CREATE TABLE training_base_images (
    -- [原training_base_images表的完整定义]
);

-- [其他实训基地相关表的定义...]

------------------------------------------------------------------
-- 触发器设置
------------------------------------------------------------------

-- 为所有需要更新时间的表添加触发器
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- [其他触发器定义...]

------------------------------------------------------------------
-- RLS 策略设置
------------------------------------------------------------------

-- 为所有表启用 RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization ENABLE ROW LEVEL SECURITY;
-- [其他表的 RLS 启用...]

-- 创建基础的访问策略
CREATE POLICY "用户可以查看所有档案信息" ON profiles
    FOR SELECT USING (true);
-- [其他访问策略定义...]

------------------------------------------------------------------
-- 索引创建
------------------------------------------------------------------

-- 为重要字段创建索引
CREATE INDEX idx_organization_parent_id ON organization(parent_id);
-- [其他索引定义...] 