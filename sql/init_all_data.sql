------------------------------------------------------------------
-- 数据初始化主脚本
-- 包含:枚举类型、组织机构、教职工、教师、班级、实训基地等数据
------------------------------------------------------------------

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
            'worker'          -- 工勤人员
        );
    END IF;
END $$;

----------------------------------
-- 第2部分: 清空现有数据
----------------------------------
TRUNCATE TABLE training_base_companies CASCADE;
TRUNCATE TABLE training_base_majors CASCADE;
TRUNCATE TABLE training_base_images CASCADE;
TRUNCATE TABLE training_base CASCADE;
TRUNCATE TABLE class_officers CASCADE;
TRUNCATE TABLE class_advisors CASCADE;
TRUNCATE TABLE students CASCADE;
TRUNCATE TABLE classes CASCADE;
TRUNCATE TABLE majors CASCADE;
TRUNCATE TABLE teacher_position_records CASCADE;
TRUNCATE TABLE teacher_title_records CASCADE;
TRUNCATE TABLE teacher_profiles CASCADE;
TRUNCATE TABLE staff_organization CASCADE;
TRUNCATE TABLE staff CASCADE;
TRUNCATE TABLE organization CASCADE;

----------------------------------
-- 第3部分: 插入组织机构数据
----------------------------------
-- 插入学校本级
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, description, sort_order)
VALUES ('10000', '滨海职业技术学院', 'school', NULL, 1, '校长', '公办全日制高等职业院校', 1);

-- 插入党群部门
WITH school AS (SELECT id FROM organization WHERE org_code = '10000')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('11000', '党委办公室', 'party', (SELECT id FROM school), 2, '党委书记', 1),
    ('11001', '党委组织部', 'party', (SELECT id FROM school), 2, '组织部长', 2),
    ('11002', '党委宣传部', 'party', (SELECT id FROM school), 2, '宣传部长', 3),
    ('11003', '工会', 'party', (SELECT id FROM school), 2, '工会主席', 4),
    ('11004', '团委', 'party', (SELECT id FROM school), 2, '团委书记', 5),
    ('11005', '纪检监察室', 'party', (SELECT id FROM school), 2, '纪委书记', 6);

-- 插入行政职能部门
WITH school AS (SELECT id FROM organization WHERE org_code = '10000')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('12000', '教务处', 'administrative', (SELECT id FROM school), 2, '教务处长', 1),
    ('12001', '学生处', 'administrative', (SELECT id FROM school), 2, '学生处长', 2),
    ('12002', '人事处', 'administrative', (SELECT id FROM school), 2, '人事处长', 3),
    ('12003', '财务处', 'administrative', (SELECT id FROM school), 2, '财务处长', 4),
    ('12004', '后勤管理处', 'administrative', (SELECT id FROM school), 2, '后勤处长', 5),
    ('12005', '招生就业处', 'administrative', (SELECT id FROM school), 2, '招就处长', 6);

-- 插入教学院系
WITH school AS (SELECT id FROM organization WHERE org_code = '10000')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('13000', '智能制造学院', 'academic', (SELECT id FROM school), 2, '院长', 1),
    ('13001', '电子信息学院', 'academic', (SELECT id FROM school), 2, '院长', 2),
    ('13002', '汽车工程学院', 'academic', (SELECT id FROM school), 2, '院长', 3),
    ('13003', '经济管理学院', 'academic', (SELECT id FROM school), 2, '院长', 4),
    ('13004', '建筑工程学院', 'academic', (SELECT id FROM school), 2, '院长', 5);

-- 插入教辅部门
WITH school AS (SELECT id FROM organization WHERE org_code = '10000')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('14000', '图书馆', 'service', (SELECT id FROM school), 2, '馆长', 1),
    ('14001', '实训中心', 'service', (SELECT id FROM school), 2, '主任', 2),
    ('14002', '信息中心', 'service', (SELECT id FROM school), 2, '主任', 3),
    ('14003', '继续教育中心', 'service', (SELECT id FROM school), 2, '主任', 4);

-- 插入智能制造学院下属机构
WITH smart_manu AS (SELECT id FROM organization WHERE org_code = '13000')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('13000100', '院长办公室', 'administrative', (SELECT id FROM smart_manu), 3, '主任', 1),
    ('13000200', '教务办公室', 'administrative', (SELECT id FROM smart_manu), 3, '主任', 2),
    ('13000300', '学工办公室', 'administrative', (SELECT id FROM smart_manu), 3, '主任', 3),
    -- 教研室
    ('13000401', '机械制造教研室', 'teaching', (SELECT id FROM smart_manu), 3, '主任', 4),
    ('13000402', '数控技术教研室', 'teaching', (SELECT id FROM smart_manu), 3, '主任', 5),
    ('13000403', '工业机器人教研室', 'teaching', (SELECT id FROM smart_manu), 3, '主任', 6),
    ('13000404', '模具设计教研室', 'teaching', (SELECT id FROM smart_manu), 3, '主任', 7);

----------------------------------
-- 第4部分: 插入教职工数据
----------------------------------
-- 插入学校领导
INSERT INTO staff (staff_code, staff_name, gender, staff_type, org_id, position_title, admin_title, 
                  education, degree, email, phone, entry_date)
WITH school_leaders AS (
    SELECT id FROM organization WHERE org_code IN ('10000', '11000')
)
SELECT 
    '1001', '张明', 'male'::text, 'leadership'::staff_type,
    (SELECT id FROM organization WHERE org_code = '10000'),
    '教授', '校长', '研究生', '博士',
    'zhangming@example.com', '13900000001', '2010-01-01'::date
WHERE EXISTS (SELECT 1 FROM school_leaders)
UNION ALL
SELECT 
    '1002', '李红', 'female'::text, 'leadership'::staff_type,
    (SELECT id FROM organization WHERE org_code = '11000'),
    '教授', '党委书记', '研究生', '博士',
    'lihong@example.com', '13900000002', '2011-01-01'::date
WHERE EXISTS (SELECT 1 FROM school_leaders);

----------------------------------
-- 第5部分: 插入专业与班级数据
----------------------------------
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

----------------------------------
-- 第6部分: 插入实训基地数据
----------------------------------
-- 插入智能制造学院的实训基地
WITH dept AS (SELECT id FROM organization WHERE org_code = '13000')
INSERT INTO training_base (
    base_name, dept_code, dept_name, support_unit, base_type, 
    contact_person, contact_phone, address, capacity
) VALUES 
    ('智能制造产教融合实训基地', '13000', '智能制造学院', '滨海智能制造产业园', 'external',
    '张工', '13800138001', '滨海新区智能制造产业园区A区', 120),
    ('数控加工实训基地', '13000', '智能制造学院', '智能制造学院', 'internal',
    '李工', '13800138002', '学院实训楼A201', 60),
    ('工业机器人实训基地', '13000', '智能制造学院', '智能制造学院', 'internal',
    '王工', '13800138003', '学院实训楼B301', 45);

-- 插入基地图片
WITH bases AS (SELECT id, base_name FROM training_base)
INSERT INTO training_base_images (base_id, image_url, is_main)
SELECT 
    id,
    CASE 
        WHEN base_name LIKE '%智能制造%' THEN '/images/training-base/smart-manufacturing.jpg'
        WHEN base_name LIKE '%数控%' THEN '/images/training-base/cnc.jpg'
        WHEN base_name LIKE '%机器人%' THEN '/images/training-base/robot.jpg'
        WHEN base_name LIKE '%软件%' THEN '/images/training-base/software.jpg'
        WHEN base_name LIKE '%物联网%' THEN '/images/training-base/iot.jpg'
    END,
    true
FROM bases;

-- 插入基地专业
WITH bases AS (SELECT id, dept_code FROM training_base),
majors AS (
    SELECT id, major_name
    FROM bases CROSS JOIN LATERAL (
        VALUES 
            ('机械制造及自动化'),
            ('数控技术'),
            ('工业机器人技术')
    ) AS m(major_name)
    WHERE dept_code = '13000'
)
INSERT INTO training_base_majors (base_id, major_name)
SELECT id, major_name FROM majors;

-- 更新备注信息
UPDATE training_base 
SET remarks = CASE 
    WHEN base_type = 'internal' THEN '校内实训基地'
    WHEN base_type = 'external' THEN '校外实训基地'
    ELSE remarks
END; 

----------------------------------
-- 第7部分: 插入实训室数据
----------------------------------
-- 插入实训室基本信息
INSERT INTO training_rooms (
    id, name, base_id, room_code, area, capacity, 
    equipment_count, description, status, created_at, updated_at,
    created_by, updated_by
) 
WITH base_ids AS (
    SELECT id, base_name FROM training_bases
)
SELECT 
    gen_random_uuid(),
    room_name,
    base_id,
    room_code,
    area,
    capacity,
    equipment_count,
    description,
    'active'::status_type,
    NOW(), NOW(),
    (SELECT id FROM profiles WHERE username = 'admin@school.com'),
    (SELECT id FROM profiles WHERE username = 'admin@school.com')
FROM (
    VALUES
    -- 智能制造产教融合实训基地
    ('数控加工实训室', '14001001001', 180.5, 30, 14, '配备数控车床、铣床等设备，可同时容纳30人实训'),
    ('工业机器人实训室', '14001001002', 150.0, 24, 8, '配备ABB、发那科等品牌工业机器人，可同时容纳24人实训'),
    ('3D打印实验室', '14001001003', 100.0, 30, 15, '配备工业级3D打印设备，支持快速成型实训'),
    ('模具制作实训室', '14001001004', 120.0, 30, 10, '配备模具加工设备，支持模具设计与制作实训'),
    ('智能制造系统实训室', '14001001005', 200.0, 40, 20, '配备智能制造生产线，支持智能制造系统集成实训'),
    ('CAD/CAM实训室', '14001001006', 90.0, 45, 45, '配备专业设计软件工作站，支持计算机辅助设计与制造实训'),
    ('精密测量实训室', '14001001007', 80.0, 30, 25, '配备三坐标测量仪等精密检测设备，支持质量检测实训'),
    ('PLC控制实训室', '14001001008', 100.0, 36, 18, '配备西门子、三菱等品牌PLC设备，支持工业控制实训'),
    
    -- 数控加工实训基地
    ('数控综合加工中心', '14001002001', 250.0, 40, 12, '配备五轴加工中心等高端设备，支持复杂零件加工实训'),
    ('特种加工实训室', '14001002002', 150.0, 30, 8, '配备电火花、线切割等特种加工设备，支持特种加工工艺实训'),
    ('刀具技术实训室', '14001002003', 80.0, 25, 30, '配备各类刀具检测与维护设备，支持刀具应用与维护实训'),
    
    -- 工业机器人实训基地
    ('机器人焊接实训室', '14001003001', 180.0, 20, 10, '配备焊接机器人工作站，支持自动化焊接实训'),
    ('机器人视觉实训室', '14001003002', 120.0, 24, 12, '配备机器视觉系统，支持视觉识别与控制实训'),
    ('协作机器人实训室', '14001003003', 100.0, 30, 15, '配备协作机器人，支持人机协作应用开发实训')
) AS rooms(room_name, room_code, area, capacity, equipment_count, description)
CROSS JOIN LATERAL (
    SELECT id AS base_id 
    FROM base_ids 
    WHERE base_name = '智能制造产教融合实训基地' 
    LIMIT 1
) AS base_lookup;

-- 插入实训室专业方向（扩充）
INSERT INTO training_room_majors (
    id, room_code, major_name, training_items, student_capacity, class_capacity
) VALUES
    -- 数控加工实训室
    (gen_random_uuid(), '14001001001', '机械制造及自动化', 
     ARRAY['数控车床操作', '数控铣床操作', '数控编程', '工艺编制'], 30, 1),
    (gen_random_uuid(), '14001001001', '数控技术',
     ARRAY['数控加工工艺', '精密加工技术', '自动化生产'], 30, 1),
     
    -- 工业机器人实训室
    (gen_random_uuid(), '14001001002', '工业机器人技术',
     ARRAY['机器人操作', '机器人编程', '工作站应用开发', '系统集成'], 24, 1),
    (gen_random_uuid(), '14001001002', '机械制造及自动化',
     ARRAY['机器人应用技术', '智能制造单元', '柔性制造'], 24, 1),
     
    -- 智能制造系统实训室
    (gen_random_uuid(), '14001001005', '机械制造及自动化',
     ARRAY['智能制造系统集成', '生产线调试', '系统运维'], 40, 1),
    (gen_random_uuid(), '14001001005', '工业机器人技术',
     ARRAY['智能产线编程', '系统集成应用', '工业网络'], 40, 1),
     
    -- CAD/CAM实训室
    (gen_random_uuid(), '14001001006', '机械制造及自动化',
     ARRAY['CAD建模', 'CAM编程', '逆向工程'], 45, 1),
    
    -- 机器人焊接实训室
    (gen_random_uuid(), '14001003001', '工业机器人技术',
     ARRAY['焊接机器人编程', '焊接工艺参数设置', '质量检测'], 20, 1);

-- 插入实训室设备数据（扩充）
INSERT INTO training_room_equipment (
    id, room_code, equipment_name, model_number, manufacturer,
    purchase_date, unit_price, quantity, status, remarks
) VALUES 
    -- 数控加工实训室新增设备
    (gen_random_uuid(), '14001001001', '五轴加工中心', 'DMU50', 'DMG森精机', 
     '2023-06-15', 1500000.00, 2, 'normal', '德国进口五轴联动加工中心'),
    (gen_random_uuid(), '14001001001', '数控磨床', 'MK7120', '上海机床厂', 
     '2023-06-15', 200000.00, 3, 'normal', '精密磨削设备'),
     
    -- 工业机器人实训室新增设备
    (gen_random_uuid(), '14001001002', 'SCARA机器人', 'T3-401S', '爱普生', 
     '2023-07-20', 180000.00, 4, 'normal', '适用于精密装配'),
    (gen_random_uuid(), '14001001002', '视觉系统', 'In-Sight 7000', 'Cognex', 
     '2023-07-20', 80000.00, 4, 'normal', '工业视觉系统'),
     
    -- 智能制造系统实训室
    (gen_random_uuid(), '14001001005', '智能生产线', 'IML-2000', '大福自动化', 
     '2023-08-10', 2500000.00, 1, 'normal', '柔性制造生产线'),
    (gen_random_uuid(), '14001001005', 'AGV小车', 'AGV-100', '新松机器人', 
     '2023-08-10', 150000.00, 4, 'normal', '智能物流搬运车'),
     
    -- 机器人焊接实训室
    (gen_random_uuid(), '14001003001', '焊接机器人', 'AR-1440', '安川电机', 
     '2023-09-15', 450000.00, 3, 'normal', '焊接专用机器人'),
    (gen_random_uuid(), '14001003001', '焊机', 'TPS-4000', '福尼斯', 
     '2023-09-15', 80000.00, 3, 'normal', '数字化焊机');

-- 插入实训室安全信息（扩充）
INSERT INTO training_room_safety (
    id, room_code, safety_manager, emergency_contact,
    safety_equipment, safety_rules, emergency_procedures,
    last_inspection_date, next_inspection_date, status
) VALUES
    -- 智能制造系统实训室
    (gen_random_uuid(), '14001001005', '王工', '13800138004',
     ARRAY['安全光栅', '急停按钮', '警示标识', '监控设备'],
     '1. 严格遵守安全操作规程\n2. 进入区域必须佩戴安全帽\n3. 非操作人员禁止进入警戒区',
     '1. 立即按下急停按钮\n2. 切断总电源\n3. 疏散人员\n4. 报告安全负责人',
     '2024-01-25', '2024-07-25', 'normal'),
     
    -- 机器人焊接实训室
    (gen_random_uuid(), '14001003001', '赵工', '13800138005',
     ARRAY['焊接防护屏', '通风系统', '消防设备', '防护用品'],
     '1. 必须穿戴完整防护装备\n2. 确保通风系统正常运行\n3. 严格遵守焊接操作规程',
     '1. 关闭焊机电源\n2. 启动应急通风\n3. 使用灭火器处理\n4. 报告安全负责人',
     '2024-02-01', '2024-08-01', 'normal');

-- 为实训室添加管理人员
WITH random_teachers AS (
    SELECT t.id, t.teacher_code::bigint as staff_id
    FROM teacher_profiles t
    ORDER BY random() 
    LIMIT 14  -- 获取足够数量的教师
)
INSERT INTO training_room_managers (
    id, room_code, staff_id, position, start_date, status
)
SELECT 
    gen_random_uuid(),
    room_code,
    staff_id,  -- 直接使用teacher_code作为staff_id
    position,
    start_date,
    'active'
FROM (
    VALUES
    ('14001001001', '数控加工实训室主任', '2023-07-01'::date),
    ('14001001002', '工业机器人实训室主任', '2023-07-01'::date),
    ('14001001003', '3D打印实验室主任', '2023-07-01'::date),
    ('14001001004', '模具制作实训室主任', '2023-07-01'::date),
    ('14001001005', '智能制造系统实训室主任', '2023-08-01'::date),
    ('14001001006', 'CAD/CAM实训室主任', '2023-08-01'::date),
    ('14001001007', '精密测量实训室主任', '2023-08-01'::date),
    ('14001001008', 'PLC控制实训室主任', '2023-08-01'::date),
    ('14001002001', '数控综合加工中心主任', '2023-09-01'::date),
    ('14001002002', '特种加工实训室主任', '2023-09-01'::date),
    ('14001002003', '刀具技术实训室主任', '2023-09-01'::date),
    ('14001003001', '机器人焊接实训室主任', '2023-10-01'::date),
    ('14001003002', '机器人视觉实训室主任', '2023-10-01'::date),
    ('14001003003', '协作机器人实训室主任', '2023-10-01'::date)
) AS t(room_code, position, start_date)
CROSS JOIN LATERAL (
    SELECT staff_id
    FROM random_teachers 
    LIMIT 1
) AS teacher_lookup; 