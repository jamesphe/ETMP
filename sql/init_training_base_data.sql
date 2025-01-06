-- 清空现有数据
TRUNCATE TABLE training_base_companies CASCADE;
TRUNCATE TABLE training_base_majors CASCADE;
TRUNCATE TABLE training_base_images CASCADE;
TRUNCATE TABLE training_base CASCADE;

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

-- 插入电子信息学院的实训基地
WITH dept AS (SELECT id FROM organization WHERE org_code = '13001')
INSERT INTO training_base (
    base_name, dept_code, dept_name, support_unit, base_type,
    contact_person, contact_phone, address, capacity
) VALUES 
    ('软件开发实训基地', '13001', '电子信息学院', '电子信息学院', 'internal',
    '刘工', '13800138004', '学院实训楼C201', 90),
    ('物联网产教融合基地', '13001', '电子信息学院', '滨海物联网产业园', 'external',
    '赵工', '13800138005', '滨海新区物联网产业园B区', 150);

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

-- 插入基地专业（修改后的版本）
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
    UNION ALL
    SELECT id, major_name
    FROM bases CROSS JOIN LATERAL (
        VALUES 
            ('计算机应用技术'),
            ('软件技术'),
            ('物联网应用技术')
    ) AS m(major_name)
    WHERE dept_code = '13001'
)
INSERT INTO training_base_majors (base_id, major_name)
SELECT id, major_name FROM majors;

-- 插入合作企业（修改后的版本）
WITH bases AS (SELECT id, base_name FROM training_base WHERE base_type = 'external'),
companies AS (
    SELECT id, company_name
    FROM bases CROSS JOIN LATERAL (
        VALUES 
            ('滨海智能装备有限公司'),
            ('滨海数控科技有限公司'),
            ('滨海自动化设备有限公司')
    ) AS c(company_name)
    WHERE base_name LIKE '%智能制造%'
    UNION ALL
    SELECT id, company_name
    FROM bases CROSS JOIN LATERAL (
        VALUES 
            ('滨海物联网科技有限公司'),
            ('滨海智慧城市科技有限公司')
    ) AS c(company_name)
    WHERE base_name LIKE '%物联网%'
)
INSERT INTO training_base_companies (
    base_id, company_name, cooperation_type, 
    start_date, end_date
)
SELECT 
    id, 
    company_name,
    '校企合作',
    '2023-01-01',
    '2025-12-31'
FROM companies;

-- 更新备注信息
UPDATE training_base 
SET remarks = CASE 
    WHEN base_type = 'internal' THEN '校内实训基地'
    WHEN base_type = 'external' THEN '校外实训基地'
    ELSE remarks
END; 