-- 创建枚举类型（这个文件需要最先执行）
DO $$ BEGIN
    -- 创建组织机构类型枚举
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'org_type') THEN
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
    END IF;

    -- 创建教职工类型枚举
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'staff_type') THEN
        CREATE TYPE staff_type AS ENUM (
            'leadership',      -- 学校领导
            'teacher',         -- 专任教师
            'admin',          -- 行政人员
            'both',           -- 教师兼行政
            'support',        -- 教辅人员
            'worker'          -- 工勤人员
        );
    END IF;
END $$; 