-- 清空现有数据
TRUNCATE TABLE class_officers CASCADE;
TRUNCATE TABLE class_advisors CASCADE;
TRUNCATE TABLE students CASCADE;
TRUNCATE TABLE classes CASCADE;
TRUNCATE TABLE majors CASCADE;

-- 插入专业数据
INSERT INTO majors (major_code, major_name, dept_code, status, remarks) VALUES 
    ('JZ', '机械制造及自动化', '13000', 'active', '智能制造学院重点专业'),
    ('SK', '数控技术', '13000', 'active', '智能制造学院特色专业'),
    ('JQR', '工业机器人技术', '13000', 'active', '智能制造学院新兴专业'),
    ('RJ', '软件技术', '13001', 'active', '电子信息学院重点专业'),
    ('WL', '物联网应用技术', '13001', 'active', '电子信息学院特色专业'),
    ('JSJ', '计算机应用技术', '13001', 'active', '电子信息学院基础专业');

-- 插入班级数据
INSERT INTO classes (
    class_code, class_name, major_code, grade_year, 
    graduation_year, study_length, dept_code, status
) VALUES 
    -- 机械制造及自动化专业
    ('JZ21-1', '机制21-1班', 'JZ', 2021, 2024, 3, '13000', 'active'),
    ('JZ21-2', '机制21-2班', 'JZ', 2021, 2024, 3, '13000', 'active'),
    ('JZ22-1', '机制22-1班', 'JZ', 2022, 2025, 3, '13000', 'active'),
    ('JZ22-2', '机制22-2班', 'JZ', 2022, 2025, 3, '13000', 'active'),
    ('JZ23-1', '机制23-1班', 'JZ', 2023, 2026, 3, '13000', 'active'),
    
    -- 软件技术专业
    ('RJ21-1', '软件21-1班', 'RJ', 2021, 2024, 3, '13001', 'active'),
    ('RJ21-2', '软件21-2班', 'RJ', 2021, 2024, 3, '13001', 'active'),
    ('RJ22-1', '软件22-1班', 'RJ', 2022, 2025, 3, '13001', 'active'),
    ('RJ22-2', '软件22-2班', 'RJ', 2022, 2025, 3, '13001', 'active'),
    ('RJ23-1', '软件23-1班', 'RJ', 2023, 2026, 3, '13001', 'active');

-- 为每个班级创建学生用户并插入学生数据
DO $$
DECLARE
    v_class RECORD;
    v_student_id UUID;
    v_profile_id UUID;
    v_student_code TEXT;
    v_student_name TEXT;
BEGIN
    FOR v_class IN SELECT id, class_code, major_code, dept_code, grade_year, graduation_year FROM classes
    LOOP
        FOR i IN 1..30 LOOP
            -- 生成UUID
            v_profile_id := gen_random_uuid();
            
            -- 生成学号和姓名
            v_student_code := v_class.class_code || '-' || LPAD(i::TEXT, 2, '0');
            v_student_name := '学生' || v_student_code;
            
            -- 创建用户档案
            INSERT INTO auth.users (
                id,                    -- 显式指定 UUID
                email,
                raw_user_meta_data,
                created_at,
                updated_at,
                email_confirmed_at
            ) VALUES (
                v_profile_id,         -- 使用生成的 UUID
                v_student_code || '@student.com',
                jsonb_build_object('role', 'student'),
                now(),
                now(),
                now()
            );

            -- 创建profiles记录
            INSERT INTO profiles (
                id,
                username,
                real_name,
                role,
                status
            ) VALUES (
                v_profile_id,
                v_student_code || '@student.com',
                v_student_name,
                'student',
                'active'
            );

            -- 创建学生记录
            INSERT INTO students (
                student_code,
                student_name,
                profile_id,
                class_id,
                major_code,
                dept_code,
                grade_year,
                graduation_year,
                study_status
            ) VALUES (
                v_student_code,
                v_student_name,
                v_profile_id,
                v_class.id,
                v_class.major_code,
                v_class.dept_code,
                v_class.grade_year,
                v_class.graduation_year,
                'active'
            );
        END LOOP;
    END LOOP;
END;
$$;

-- 插入班主任数据
INSERT INTO class_advisors (
    class_id,
    advisor_id,
    start_date,
    status
)
SELECT 
    c.id,
    t.id,
    CASE 
        WHEN c.class_code LIKE '%21%' THEN DATE '2021-09-01'
        WHEN c.class_code LIKE '%22%' THEN DATE '2022-09-01'
        ELSE DATE '2023-09-01'
    END,
    'active'
FROM classes c
CROSS JOIN (
    SELECT id 
    FROM teacher_profiles 
    WHERE dept_code IN ('13000', '13001')
    ORDER BY random()
    LIMIT 10
) t;

-- 为每个班级插入班干部数据
WITH class_students AS (
    SELECT 
        c.id as class_id,
        s.id as student_id,
        c.class_code,
        ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY random()) as rn
    FROM classes c
    JOIN students s ON c.id = s.class_id
    WHERE s.study_status = 'active'
)
INSERT INTO class_officers (
    class_id,
    student_id,
    position,
    start_date,
    status
)
SELECT 
    class_id,
    student_id,
    CASE 
        WHEN rn = 1 THEN '班长'
        WHEN rn = 2 THEN '团支书'
        WHEN rn = 3 THEN '学习委员'
        WHEN rn = 4 THEN '生活委员'
        WHEN rn = 5 THEN '体育委员'
    END as position,
    CASE 
        WHEN class_code LIKE '%21%' THEN DATE '2021-09-01'
        WHEN class_code LIKE '%22%' THEN DATE '2022-09-01'
        ELSE DATE '2023-09-01'
    END as start_date,
    'active'
FROM class_students
WHERE rn <= 5;

-- 更新部分学生状态
UPDATE students 
SET study_status = status_value
FROM (
    SELECT id, 
        CASE floor(random() * 10)
            WHEN 0 THEN 'leave'   -- 休学
            WHEN 1 THEN 'quit'    -- 退学
            ELSE 'active'         -- 在读
        END as status_value
    FROM students
) as subquery
WHERE students.id = subquery.id; 