-- 清空现有数据
TRUNCATE TABLE teacher_position_records CASCADE;
TRUNCATE TABLE teacher_title_records CASCADE;
TRUNCATE TABLE teacher_profiles CASCADE;

-- 首先创建auth用户和profiles
DO $$
DECLARE
    user_id uuid;
    email text;
BEGIN
    FOR i IN 1..10 LOOP
        -- 生成UUID和邮箱
        user_id := gen_random_uuid();
        email := 'teacher' || i || '@school.com';
        
        -- 创建 auth.users 记录
        INSERT INTO auth.users (
            id,
            email,
            raw_user_meta_data,
            created_at,
            updated_at,
            email_confirmed_at
        ) 
        VALUES (
            user_id,
            email,
            jsonb_build_object('role', 'teacher'),
            now(),
            now(),
            now()
        );

        -- 创建对应的 profiles 记录
        INSERT INTO profiles (
            id,
            username,
            real_name,
            role,
            status
        ) VALUES (
            user_id,
            email,
            '教师' || i,
            'teacher',
            'active'
        );
    END LOOP;
END;
$$;

-- 插入教师基本信息
WITH teacher_profiles_data AS (
    SELECT 
        id,
        real_name,
        ROW_NUMBER() OVER (ORDER BY id) as rn
    FROM profiles 
    WHERE role = 'teacher'
    LIMIT 10
)
INSERT INTO teacher_profiles (
    teacher_code,
    profile_id,
    dept_code,
    employment_date,
    employment_type,
    education_level,
    graduation_school,
    major_studied,
    status,
    remarks
) 
SELECT 
    CASE 
        WHEN rn <= 5 THEN 'T13000' || LPAD(CAST(rn AS TEXT), 3, '0')
        ELSE 'T13001' || LPAD(CAST(rn - 5 AS TEXT), 3, '0')
    END,
    id,
    CASE 
        WHEN rn <= 5 THEN '13000'
        ELSE '13001'
    END,
    CASE 
        WHEN rn <= 2 THEN DATE '2015-09-01'
        WHEN rn <= 4 THEN DATE '2016-07-01'
        WHEN rn <= 6 THEN DATE '2017-09-01'
        WHEN rn <= 8 THEN DATE '2018-07-01'
        ELSE DATE '2019-09-01'
    END,
    CASE WHEN rn IN (4, 9) THEN '合同工' ELSE '在编' END,
    CASE 
        WHEN rn IN (1, 5, 6, 10) THEN '博士'
        WHEN rn = 9 THEN '学士'
        ELSE '硕士'
    END,
    CASE rn
        WHEN 1 THEN '华中科技大学'
        WHEN 2 THEN '武汉理工大学'
        WHEN 3 THEN '华南理工大学'
        WHEN 4 THEN '湖南大学'
        WHEN 5 THEN '西安交通大学'
        WHEN 6 THEN '华中科技大学'
        WHEN 7 THEN '武汉大学'
        WHEN 8 THEN '中南大学'
        WHEN 9 THEN '湖南科技大学'
        ELSE '电子科技大学'
    END,
    CASE 
        WHEN rn <= 5 THEN CASE rn
            WHEN 1 THEN '机械工程'
            WHEN 2 THEN '机械设计'
            WHEN 3 THEN '机器人工程'
            WHEN 4 THEN '机械电子'
            ELSE '控制工程'
        END
        ELSE CASE rn - 5
            WHEN 1 THEN '计算机科学'
            WHEN 2 THEN '软件工程'
            WHEN 3 THEN '物联网工程'
            WHEN 4 THEN '通信工程'
            ELSE '信息工程'
        END
    END,
    'active',
    CASE 
        WHEN rn <= 5 THEN CASE rn
            WHEN 1 THEN '机械专业带头人'
            WHEN 2 THEN '数控技术骨干'
            WHEN 3 THEN '工业机器人方向'
            WHEN 4 THEN '实训指导教师'
            ELSE '智能制造方向'
        END
        ELSE CASE rn - 5
            WHEN 1 THEN '软件工程带头人'
            WHEN 2 THEN 'Java技术骨干'
            WHEN 3 THEN '物联网方向'
            WHEN 4 THEN '实训指导教师'
            ELSE '人工智能方向'
        END
    END
FROM teacher_profiles_data;

-- 插入职称记录
INSERT INTO teacher_title_records (
    teacher_id,
    title_name,
    title_level,
    certificate_no,
    issue_date,
    issue_authority,
    status,
    remarks
)
SELECT 
    t.id,
    CASE floor(random() * 4)
        WHEN 0 THEN '助教'
        WHEN 1 THEN '讲师'
        WHEN 2 THEN '副教授'
        WHEN 3 THEN '教授'
    END as title_name,
    CASE floor(random() * 4)
        WHEN 0 THEN '初级'
        WHEN 1 THEN '中级'
        WHEN 2 THEN '副高'
        WHEN 3 THEN '正高'
    END as title_level,
    'CERT-' || t.teacher_code || '-' || date_part('year', t.employment_date) as certificate_no,
    t.employment_date + interval '2 year' as issue_date,
    '湖南省教育厅',
    'active',
    '正常晋升'
FROM teacher_profiles t;

-- 插入部分历史职称记录
INSERT INTO teacher_title_records (
    teacher_id,
    title_name,
    title_level,
    certificate_no,
    issue_date,
    issue_authority,
    status,
    remarks
)
SELECT 
    t.id,
    '讲师',
    '中级',
    'CERT-' || t.teacher_code || '-OLD',
    t.employment_date,
    '湖南省教育厅',
    'inactive',
    '已晋升'
FROM teacher_profiles t
WHERE random() < 0.5;

-- 插入职务记录
INSERT INTO teacher_position_records (
    teacher_id,
    position_name,
    org_code,
    start_date,
    end_date,
    appointment_doc,
    status,
    remarks
)
SELECT 
    t.id,
    CASE floor(random() * 5)
        WHEN 0 THEN '系主任'
        WHEN 1 THEN '教研室主任'
        WHEN 2 THEN '实训中心主任'
        WHEN 3 THEN '专业带头人'
        WHEN 4 THEN '教学秘书'
    END as position_name,
    t.dept_code,
    t.employment_date + interval '1 year' as start_date,
    NULL as end_date,
    'APPOINTMENT-' || date_part('year', t.employment_date) || '-' || floor(random() * 100) as appointment_doc,
    'active',
    '正常任职'
FROM teacher_profiles t
WHERE random() < 0.6;

-- 插入部分历史职务记录
INSERT INTO teacher_position_records (
    teacher_id,
    position_name,
    org_code,
    start_date,
    end_date,
    appointment_doc,
    status,
    handover_reason,
    remarks
)
SELECT 
    t.id,
    '教研室主任',
    t.dept_code,
    t.employment_date,
    t.employment_date + interval '2 year',
    'APPOINTMENT-OLD-' || date_part('year', t.employment_date) || '-' || floor(random() * 100),
    'inactive',
    '工作调动',
    '任期已满'
FROM teacher_profiles t
WHERE random() < 0.3;

-- 更新部分教师状态
UPDATE teacher_profiles 
SET status = status_value
FROM (
    SELECT id, 
        CASE floor(random() * 10)
            WHEN 0 THEN 'leave'    -- 请假
            WHEN 1 THEN 'retired'  -- 退休
            ELSE 'active'          -- 在职
        END as status_value
    FROM teacher_profiles
) as subquery
WHERE teacher_profiles.id = subquery.id; 