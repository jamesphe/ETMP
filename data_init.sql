------------------------------------------------------------------
-- 数据初始化主脚本
-- 包含:枚举类型、组织机构、教职工、教师、班级、实训基地等数据
------------------------------------------------------------------

-- 在文件开始添加事务控制
BEGIN;

----------------------------------
-- 第1部分: 创建枚举类型
----------------------------------
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
            'worker',         -- 工勤人员
            'counselor',      -- 辅导员
            'researcher',     -- 科研人员
            'part_time',      -- 兼职教师
            'retired',        -- 退休返聘
            'temporary',      -- 临时聘用
            'intern'          -- 实习人员
        );
    END IF;

    -- 创建学生状态枚举
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'student_status') THEN
        CREATE TYPE student_status AS ENUM (
            'active',      -- 在读
            'suspended',   -- 休学
            'transferred', -- 转学
            'withdrawn',   -- 退学
            'graduated'    -- 毕业
        );
    END IF;
END $$;

----------------------------------
-- 第2部分: 清空现有数据
----------------------------------
TRUNCATE TABLE training_room_usage_logs CASCADE;
TRUNCATE TABLE training_room_bookings CASCADE;
TRUNCATE TABLE training_room_managers CASCADE;
TRUNCATE TABLE training_room_safety CASCADE;
TRUNCATE TABLE training_room_majors CASCADE;
TRUNCATE TABLE training_room_equipment CASCADE;
TRUNCATE TABLE training_rooms CASCADE;
TRUNCATE TABLE training_base_companies CASCADE;
TRUNCATE TABLE training_base_majors CASCADE;
TRUNCATE TABLE training_base_images CASCADE;
TRUNCATE TABLE training_bases CASCADE;
TRUNCATE TABLE class_officers CASCADE;
TRUNCATE TABLE class_advisors CASCADE;
TRUNCATE TABLE student_status_changes CASCADE;
TRUNCATE TABLE students CASCADE;
TRUNCATE TABLE classes CASCADE;
TRUNCATE TABLE majors CASCADE;
TRUNCATE TABLE staff_position_records CASCADE;
TRUNCATE TABLE staff_title_records CASCADE;
TRUNCATE TABLE admin_info CASCADE;
TRUNCATE TABLE counselor_info CASCADE;
TRUNCATE TABLE teacher_info CASCADE;
TRUNCATE TABLE staff_organization CASCADE;
TRUNCATE TABLE staff CASCADE;
TRUNCATE TABLE organization CASCADE;
TRUNCATE TABLE profiles CASCADE;

----------------------------------
-- 第3部分: 插入组织机构数据
----------------------------------
-- 插入学校本级
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_name, leader_phone, status)
VALUES ('10000', '江苏工程职业技术学院', 'school', NULL, 1, '陈国强', '13900139000', 1);

-- 插入教学院系
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_name, leader_phone, status)
VALUES 
    ('13000', '智能制造学院', 'academic', 1, 2, '张志明', '13900139001', 1),
    ('13001', '电子信息工程学院', 'academic', 1, 2, '李建国', '13900139002', 1),
    ('13002', '经济管理学院', 'academic', 1, 2, '王明辉', '13900139003', 1),
    ('13003', '艺术设计学院', 'academic', 1, 2, '刘艺', '13900139004', 1);

-- 插入教研室
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_name, leader_phone, status)
VALUES 
    ('13101', '机械设计教研室', 'teaching', 2, 3, '赵学智', '13900139005', 1),
    ('13102', '数控技术教研室', 'teaching', 2, 3, '钱明亮', '13900139006', 1),
    ('13103', '工业机器人教研室', 'teaching', 2, 3, '孙志远', '13900139007', 1),
    ('13104', '智能制造教研室', 'teaching', 2, 3, '周天宇', '13900139008', 1),
    ('13105', '实训中心', 'service', 2, 2, '吴光明', '13900139009', 1);

----------------------------------
-- 第4部分: 插入教职工数据
----------------------------------
-- 插入教师数据
INSERT INTO staff (staff_code, staff_name, staff_type, org_id, id_number, gender, email, phone, status)
VALUES
    ('T2023001', '张立新', 'teacher', 2, '110101199001011234', '男', 'zhang@example.com', '13800138001', 1),
    ('T2023002', '李梅', 'teacher', 2, '110101199001011235', '女', 'li@example.com', '13800138002', 1),
    ('T2023003', '王建华', 'counselor', 2, '110101199001011236', '男', 'wang@example.com', '13800138003', 1),
    ('T2023004', '赵雪梅', 'teacher', 2, '110101199001011237', '女', 'zhao@example.com', '13800138004', 1),
    ('T2023005', '钱伟', 'teacher', 2, '110101199001011238', '男', 'qian@example.com', '13800138005', 1);

-- 插入教师扩展信息
INSERT INTO teacher_info (staff_id, education_level, degree, graduation_school, major_studied, teaching_subject, research_direction)
VALUES
    (1, '研究生', '硕士', '南京工业大学', '机械制造及其自动化', ARRAY['数控技术', 'CAD/CAM'], ARRAY['智能制造', '数字孪生']),
    (2, '研究生', '博士', '东南大学', '机械电子工程', ARRAY['机器人技术', '自动化系统'], ARRAY['工业机器人', '智能控制']),
    (4, '研究生', '硕士', '南京理工大学', '机械工程', ARRAY['机械设计', '3D打印技术'], ARRAY['增材制造', '工业设计']),
    (5, '研究生', '博士', '河海大学', '控制工程', ARRAY['PLC控制', '工业网络'], ARRAY['智能控制', '工业物联网']);

-- 插入辅导员信息
INSERT INTO counselor_info (staff_id, student_work_years, counseling_cert, managed_grades)
VALUES
    (3, 5, 'CERT2023001', ARRAY['2021', '2022', '2023']);

----------------------------------
-- 第4部分补充: 教职工职称和职务记录
----------------------------------
-- 插入职称记录
INSERT INTO staff_title_records (
    staff_id, title_name, title_level, 
    certificate_no, issue_date, issue_authority, status
) VALUES
    (1, '讲师', '中级', 'TITLE202301', '2020-01-01', '省教育厅', 'active'),
    (2, '副教授', '副高', 'TITLE202302', '2019-01-01', '省教育厅', 'active'),
    (4, '讲师', '中级', 'TITLE202303', '2021-01-01', '省教育厅', 'active'),
    (5, '教授', '正高', 'TITLE202304', '2018-01-01', '省教育厅', 'active');

-- 插入职务记录
INSERT INTO staff_position_records (
    staff_id, position_name, org_code, 
    start_date, appointment_doc, status
) VALUES
    (1, '教研室主任', 'ORG004', '2021-01-01', 'AP202101', 'active'),
    (2, '专业负责人', 'ORG002', '2021-01-01', 'AP202102', 'active'),
    (4, '实验室主任', 'ORG008', '2022-01-01', 'AP202201', 'active'),
    (5, '学术委员会委员', 'ORG002', '2022-01-01', 'AP202202', 'active');

-- 插入教职工兼职记录
INSERT INTO staff_organization (
    staff_id, org_id, position, 
    is_main, start_date, status
) VALUES
    (1, 2, '教研室主任', true, '2021-01-01', 'active'),
    (1, 8, '实训指导教师', false, '2021-01-01', 'active'),
    (2, 2, '专业负责人', true, '2021-01-01', 'active'),
    (2, 4, '教研室教师', false, '2021-01-01', 'active');

----------------------------------
-- 第5部分: 插入专业与班级数据
----------------------------------
-- 插入专业数据
INSERT INTO majors (major_code, major_name, dept_code, status, remarks) VALUES 
    ('JX', '机械设计与制造', '13000', 'active', '智能制造学院重点专业'),
    ('SK', '数控技术', '13000', 'active', '智能制造学院特色专业'),
    ('JQR', '工业机器人技术', '13000', 'active', '智能制造学院新兴专业'),
    ('ZZ', '智能制造工程技术', '13000', 'active', '智能制造学院新兴专业');

-- 插入班级数据
INSERT INTO classes (
    class_code, class_name, major_code, grade_year, 
    graduation_year, study_length, dept_code, status
) VALUES 
    -- 机械设计与制造专业
    ('JX21-1', '机械21-1班', 'JX', 2021, 2024, 3, '13000', 'active'),
    ('JX21-2', '机械21-2班', 'JX', 2021, 2024, 3, '13000', 'active'),
    ('JX22-1', '机械22-1班', 'JX', 2022, 2025, 3, '13000', 'active'),
    ('JX22-2', '机械22-2班', 'JX', 2022, 2025, 3, '13000', 'active'),
    ('JX23-1', '机械23-1班', 'JX', 2023, 2026, 3, '13000', 'active'),
    
    -- 数控技术专业
    ('SK21-1', '数控21-1班', 'SK', 2021, 2024, 3, '13000', 'active'),
    ('SK21-2', '数控21-2班', 'SK', 2021, 2024, 3, '13000', 'active'),
    ('SK22-1', '数控22-1班', 'SK', 2022, 2025, 3, '13000', 'active'),
    ('SK22-2', '数控22-2班', 'SK', 2022, 2025, 3, '13000', 'active'),
    ('SK23-1', '数控23-1班', 'SK', 2023, 2026, 3, '13000', 'active'),
    
    -- 工业机器人技术专业
    ('JQR22-1', '机器人22-1班', 'JQR', 2022, 2025, 3, '13000', 'active'),
    ('JQR22-2', '机器人22-2班', 'JQR', 2022, 2025, 3, '13000', 'active'),
    ('JQR23-1', '机器人23-1班', 'JQR', 2023, 2026, 3, '13000', 'active'),
    
    -- 智能制造工程技术专业
    ('ZZ22-1', '智造22-1班', 'ZZ', 2022, 2025, 3, '13000', 'active'),
    ('ZZ23-1', '智造23-1班', 'ZZ', 2023, 2026, 3, '13000', 'active');

-- 插入班主任数据
INSERT INTO class_advisors (class_id, advisor_id, start_date, status)
VALUES
    ((SELECT id FROM classes WHERE class_code = 'JX21-1'), 1, '2021-09-01', 'active'),
    ((SELECT id FROM classes WHERE class_code = 'JX21-2'), 2, '2021-09-01', 'active'),
    ((SELECT id FROM classes WHERE class_code = 'SK21-1'), 4, '2021-09-01', 'active'),
    ((SELECT id FROM classes WHERE class_code = 'SK21-2'), 5, '2021-09-01', 'active'),
    ((SELECT id FROM classes WHERE class_code = 'JQR22-1'), 1, '2022-09-01', 'active'),
    ((SELECT id FROM classes WHERE class_code = 'JQR22-2'), 2, '2022-09-01', 'active'),
    ((SELECT id FROM classes WHERE class_code = 'ZZ22-1'), 4, '2022-09-01', 'active'),
    ((SELECT id FROM classes WHERE class_code = 'ZZ23-1'), 5, '2023-09-01', 'active');

----------------------------------
-- 第6部分: 插入实训基地数据
----------------------------------
-- 插入实训基地基本信息
INSERT INTO training_bases (
    base_name, dept_code, dept_name, support_unit, base_type, 
    contact_person, contact_phone, address, capacity, status
) VALUES 
    ('智能制造产教融合实训基地', '13000', '智能制造学院', '江苏智能制造产业园', 'external',
    '张工', '13800138001', '江苏省南京市江宁区智能制造产业园A区', 120, 'active'),
    
    ('数控加工实训基地', '13000', '智能制造学院', '智能制造学院', 'internal',
    '李工', '13800138002', '实训楼A201', 60, 'active'),
    
    ('工业机器人实训基地', '13000', '智能制造学院', '智能制造学院', 'internal',
    '王工', '13800138003', '实训楼B301', 45, 'active');

-- 插入基地图片
INSERT INTO training_base_images (base_id, image_url, is_main)
SELECT 
    id,
    CASE 
        WHEN base_name LIKE '%智能制造%' THEN '/images/training-base/smart-manufacturing.jpg'
        WHEN base_name LIKE '%数控%' THEN '/images/training-base/cnc.jpg'
        WHEN base_name LIKE '%机器人%' THEN '/images/training-base/robot.jpg'
        WHEN base_name LIKE '%3D打印%' THEN '/images/training-base/3d-printing.jpg'
        ELSE '/images/training-base/default.jpg'
    END,
    true
FROM training_bases;

-- 插入基地专业
INSERT INTO training_base_majors (base_id, major_name)
SELECT 
    b.id,
    m.major_name
FROM training_bases b
CROSS JOIN (
    SELECT major_name 
    FROM majors 
    WHERE dept_code = 'ORG002'
) m
WHERE b.dept_code = 'ORG002';

-- 插入合作企业
INSERT INTO training_base_companies (
    base_id, company_name, cooperation_type,
    start_date, end_date
)
VALUES
    (1, '南京智能制造产业园发展有限公司', '深度合作', '2023-01-01', '2025-12-31'),
    (1, '江苏数控机床股份有限公司', '深度合作', '2023-01-01', '2025-12-31'),
    (2, 'ABB（中国）有限公司', '深度合作', '2023-01-01', '2025-12-31'),
    (2, '发那科机器人（中国）有限公司', '一般合作', '2023-01-01', '2025-12-31'),
    (3, '西门子（中国）有限公司', '深度合作', '2023-01-01', '2025-12-31'),
    (3, '三菱电机自动化（中国）有限公司', '一般合作', '2023-01-01', '2025-12-31');

----------------------------------
-- 第7部分: 插入实训室数据
----------------------------------
-- 插入实训室基本信息
INSERT INTO training_rooms (name, base_id, room_code, area, capacity, equipment_count, status)
VALUES
    ('数控加工实训室', 1, 'ROOM001', 200.0, 40, 42, 'active'),
    ('工业机器人实训室', 1, 'ROOM002', 180.0, 35, 38, 'active'),
    ('3D打印实训室', 2, 'ROOM003', 150.0, 30, 32, 'active'),
    ('模具制作实训室', 2, 'ROOM004', 160.0, 35, 37, 'active'),
    ('智能制造系统实训室', 3, 'ROOM005', 220.0, 45, 48, 'active');

-- 插入实训室设备
INSERT INTO training_room_equipment (room_code, equipment_name, model_number, manufacturer, purchase_date, unit_price, quantity, status)
VALUES
    ('ROOM001', '数控车床', 'CK6136i', '沈阳机床', '2023-01-15', 280000.00, 20, 'normal'),
    ('ROOM001', '数控铣床', 'XK7136', '沈阳机床', '2023-01-15', 320000.00, 15, 'normal'),
    ('ROOM002', '工业机器人', 'IRB 2600', 'ABB', '2023-01-15', 450000.00, 8, 'normal'),
    ('ROOM002', '机器人控制器', 'IRC5', 'ABB', '2023-01-15', 150000.00, 8, 'normal'),
    ('ROOM003', '3D打印机', 'UP300', '北京太尔时代', '2023-01-15', 85000.00, 15, 'normal'),
    ('ROOM004', '注塑机', 'HX128', '海天塑机', '2023-01-15', 380000.00, 10, 'normal'),
    ('ROOM005', 'PLC控制系统', 'S7-1500', '西门子', '2023-01-15', 120000.00, 20, 'normal');

-- 插入实训室安全信息
INSERT INTO training_room_safety (
    room_code, safety_manager, emergency_contact, safety_equipment, safety_rules, 
    last_inspection_date, next_inspection_date
)
VALUES
    ('ROOM001', '张安民', '13900139007', 
     ARRAY['灭火器', '应急灯', '急救箱', '安全防护栏'], 
     '1. 操作机床必须穿戴工作服和劳保用品\n2. 严格遵守设备操作规程\n3. 保持工作环境整洁有序\n4. 发现设备异常立即报告\n5. 禁止在实训室内追逐打闹', 
     '2023-08-01', '2024-02-01'),
    ('ROOM002', '李安平', '13900139008', 
     ARRAY['灭火器', '应急灯', '急救箱', '安全防护网'], 
     '1. 操作机器人时必须在安全区域内\n2. 确保安全防护装置正常工作\n3. 熟悉紧急停止按钮位置\n4. 严格执行操作流程\n5. 禁止擅自修改程序', 
     '2023-08-01', '2024-02-01');

----------------------------------
-- 第7部分补充: 实训室专业方向
----------------------------------
-- 补充实训室专业方向数据
INSERT INTO training_room_majors (
    room_code, major_name, training_items, 
    student_capacity, class_capacity
) VALUES
    ('ROOM001', '机械设计与制造', 
     ARRAY['数控车床操作', '数控编程', 'CAM软件应用'], 
     40, 1),
    ('ROOM002', '工业机器人技术', 
     ARRAY['机器人编程', '机器人操作与维护', '工业现场总线'], 
     35, 1),
    ('ROOM003', '机械设计与制造', 
     ARRAY['3D建模', '快速成型', '逆向工程'], 
     30, 1),
    ('ROOM004', '模具设计与制造', 
     ARRAY['模具设计', '模具加工', '注塑成型'], 
     35, 1),
    ('ROOM005', '智能制造工程技术', 
     ARRAY['PLC编程', '工业网络', '智能生产线集成'], 
     45, 1);

-- 补充实训室管理人员
INSERT INTO training_room_managers (
    room_code, staff_id, position, 
    start_date, status
) VALUES
    ('ROOM001', 1, '实训室主任', '2023-01-01', 'active'),
    ('ROOM001', 2, '实训指导教师', '2023-01-01', 'active'),
    ('ROOM002', 4, '实训室主任', '2023-01-01', 'active'),
    ('ROOM002', 5, '实训指导教师', '2023-01-01', 'active'),
    ('ROOM003', 1, '实训室主任', '2023-01-01', 'active'),
    ('ROOM003', 4, '实训指导教师', '2023-01-01', 'active'),
    ('ROOM004', 2, '实训室主任', '2023-01-01', 'active'),
    ('ROOM004', 5, '实训指导教师', '2023-01-01', 'active');

----------------------------------
-- 第8部分: 插入学生数据
----------------------------------
-- 插入学生基本信息
INSERT INTO students (
    student_code, student_name, class_id, major_code, dept_code,
    grade_year, graduation_year, gender, birth_date, id_number,
    contact_phone, contact_address, study_status
)
SELECT 
    'S' || grade_year || LPAD(ROW_NUMBER() OVER (PARTITION BY grade_year ORDER BY random()), 4, '0'),
    surname || firstname as student_name,
    c.id as class_id,
    c.major_code,
    c.dept_code,
    c.grade_year,
    c.graduation_year,
    CASE WHEN random() > 0.5 THEN '男' ELSE '女' END as gender,
    (date '2000-01-01' + (random() * 1000)::integer * '1 day'::interval)::date as birth_date,
    '1101' || TO_CHAR((date '2000-01-01' + (random() * 1000)::integer * '1 day'::interval)::date, 'YYYYMMDD') || LPAD((random() * 999)::int::text, 3, '0') || '1',
    '138' || LPAD((random() * 99999999)::int::text, 8, '0'),
    '某某省某某市某某区某某街道',
    'active'::student_status
FROM 
    classes c,
    (VALUES 
        ('张'),('李'),('王'),('赵'),('陈'),('杨'),('吴'),('刘'),
        ('孙'),('周'),('徐'),('朱'),('胡'),('高'),('林'),('何')
    ) as surnames(surname),
    (VALUES 
        ('伟'),('芳'),('娟'),('秀英'),('敏'),('静'),('丽'),('强'),
        ('磊'),('洋'),('艳'),('勇'),('军'),('杰'),('娜'),('超'),
        ('秀兰'),('霞'),('平'),('刚')
    ) as firstnames(firstname)
WHERE 
    c.status = 'active'
LIMIT 200;

----------------------------------
-- 第9部分: 插入班干部数据
----------------------------------
-- 为每个班级添加班干部
INSERT INTO class_officers (class_id, student_id, position, start_date, status)
SELECT 
    c.id as class_id,
    s.id as student_id,
    positions.position_name,
    c.grade_year || '-09-01',
    'active'
FROM classes c
CROSS JOIN (
    VALUES 
        ('班长'),
        ('团支书'),
        ('学习委员'),
        ('生活委员')
) as positions(position_name)
JOIN students s ON s.class_id = c.id
GROUP BY c.id, positions.position_name, c.grade_year
HAVING random() < 0.8;

----------------------------------
-- 第10部分: 插入学生状态变更记录
----------------------------------
-- 添加一些学生状态变更记录
INSERT INTO student_status_changes (
    student_id, old_status, new_status, 
    change_date, reason, document_number
)
SELECT 
    id as student_id,
    'active'::student_status as old_status,
    'suspended'::student_status as new_status,
    '2023-09-01'::date as change_date,
    '因病休学一年' as reason,
    'XJ2023' || LPAD(ROW_NUMBER() OVER (ORDER BY random()), 4, '0') as document_number
FROM students 
WHERE random() < 0.05; 

----------------------------------
-- 第11部分: 插入实训室预约数据
----------------------------------
-- 修改实训室预约记录
INSERT INTO training_room_bookings (
    room_code, booker_id, booking_date, start_time, end_time, 
    purpose, attendees_count, status
)
VALUES
    ('ROOM001', '550e8400-e29b-41d4-a716-446655440001', '2023-10-01', '08:00', '11:30', 
     '数控编程与加工实训', 38, 'approved'),
    ('ROOM002', '550e8400-e29b-41d4-a716-446655440002', '2023-10-01', '14:00', '17:30', 
     '工业机器人编程与应用实训', 32, 'approved'),
    ('ROOM003', '550e8400-e29b-41d4-a716-446655440003', '2023-10-02', '08:00', '11:30', 
     '3D打印与快速成型实训', 28, 'approved'),
    ('ROOM004', '550e8400-e29b-41d4-a716-446655440004', '2023-10-02', '14:00', '17:30', 
     '模具设计与制造实训', 33, 'pending'),
    ('ROOM005', '550e8400-e29b-41d4-a716-446655440001', '2023-10-03', '08:00', '11:30', 
     'PLC控制系统应用实训', 42, 'approved');

----------------------------------
-- 第12部分: 插入实训室使用记录
----------------------------------
-- 添加一些实训室使用记录
INSERT INTO training_room_usage_logs (
    room_code, user_id, check_in_time, check_out_time, 
    actual_attendees, equipment_used, issues_reported
)
VALUES
    ('ROOM001', '550e8400-e29b-41d4-a716-446655440001', 
     '2023-09-25 08:00:00', '2023-09-25 11:30:00', 
     36, ARRAY['数控车床', '数控铣床'], NULL),
    ('ROOM002', '550e8400-e29b-41d4-a716-446655440002', 
     '2023-09-25 14:00:00', '2023-09-25 17:30:00', 
     30, ARRAY['工业机器人', '机器人控制器'], '一台机器人控制器显示异常'),
    ('ROOM003', '550e8400-e29b-41d4-a716-446655440003', 
     '2023-09-26 08:00:00', '2023-09-26 11:30:00', 
     28, ARRAY['3D打印机'], '耗材不足'),
    ('ROOM004', '550e8400-e29b-41d4-a716-446655440004', 
     '2023-09-26 14:00:00', '2023-09-26 17:30:00', 
     32, ARRAY['注塑机'], '温控系统需要校准'); 

----------------------------------
-- 第13部分: 数据一致性检查
----------------------------------
-- 检查组织机构的parent_id是否有效
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM organization o 
        WHERE o.parent_id IS NOT NULL 
        AND NOT EXISTS (SELECT 1 FROM organization p WHERE p.id = o.parent_id)
    ) THEN
        RAISE EXCEPTION '存在无效的组织机构parent_id引用';
    END IF;
END $$;

-- 检查班主任关联是否有效
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM class_advisors ca 
        WHERE NOT EXISTS (SELECT 1 FROM staff s WHERE s.id = ca.advisor_id)
    ) THEN
        RAISE EXCEPTION '存在无效的班主任关联';
    END IF;
END $$;

-- 检查实训室关联是否有效
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM training_rooms tr 
        WHERE NOT EXISTS (SELECT 1 FROM training_bases tb WHERE tb.id = tr.base_id)
    ) THEN
        RAISE EXCEPTION '存在无效的实训室基地关联';
    END IF;
END $$;

-- 检查部门代码是否有效
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM majors m 
        WHERE NOT EXISTS (SELECT 1 FROM organization o WHERE o.org_code = m.dept_code)
    ) THEN
        RAISE EXCEPTION '存在无效的专业部门代码';
    END IF; 
END $$; 

----------------------------------
-- 第14部分: 插入profiles数据
----------------------------------
INSERT INTO profiles (id, username, real_name, dept_code, dept_name, role, phone, email, status)
VALUES
    ('550e8400-e29b-41d4-a716-446655440000', 'admin', '系统管理员', 'ADMIN', '系统管理部', 'admin', '13800138000', 'admin@example.com', 'active'),
    ('550e8400-e29b-41d4-a716-446655440001', 'teacher1', '张立新', '13000', '智能制造学院', 'teacher', '13800138001', 'teacher1@example.com', 'active'),
    ('550e8400-e29b-41d4-a716-446655440002', 'teacher2', '李梅', '13000', '智能制造学院', 'teacher', '13800138002', 'teacher2@example.com', 'active'),
    ('550e8400-e29b-41d4-a716-446655440003', 'teacher3', '王建华', '13000', '智能制造学院', 'teacher', '13800138003', 'teacher3@example.com', 'active'),
    ('550e8400-e29b-41d4-a716-446655440004', 'teacher4', '赵雪梅', '13000', '智能制造学院', 'teacher', '13800138004', 'teacher4@example.com', 'active');

----------------------------------
-- 第15部分: 提交事务
----------------------------------
COMMIT; 

-- 添加更多数据一致性检查
DO $$ 
BEGIN
    -- 检查实训室预约时间是否冲突
    IF EXISTS (
        SELECT 1 FROM training_room_bookings t1
        JOIN training_room_bookings t2 ON t1.room_code = t2.room_code
        AND t1.booking_date = t2.booking_date
        AND t1.id != t2.id
        AND (
            (t1.start_time, t1.end_time) OVERLAPS (t2.start_time, t2.end_time)
        )
    ) THEN
        RAISE EXCEPTION '存在实训室预约时间冲突';
    END IF;

    -- 检查实训室容量是否超限
    IF EXISTS (
        SELECT 1 FROM training_room_bookings b
        JOIN training_rooms r ON b.room_code = r.room_code
        WHERE b.attendees_count > r.capacity
    ) THEN
        RAISE EXCEPTION '存在实训室预约人数超过容量限制';
    END IF;
END $$; 