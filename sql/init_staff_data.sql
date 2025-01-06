-- 清空已有数据（如果需要）
TRUNCATE TABLE staff_organization CASCADE;
TRUNCATE TABLE staff CASCADE;

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

-- 插入院长
INSERT INTO staff (staff_code, staff_name, gender, staff_type, org_id, position_title, admin_title, 
                  education, degree, specialty, email, phone, entry_date)
SELECT 
    s.staff_code, s.staff_name, s.gender, s.staff_type,
    o.id as org_id,
    s.position_title, s.admin_title, s.education, s.degree, s.specialty,
    s.email, s.phone, s.entry_date
FROM (
    VALUES 
        ('2001', '王强', 'male'::text, 'both'::staff_type, '13000', '教授', '院长', '研究生', '博士', '机械制造',
         'wangqiang@example.com', '13900000101', '2012-01-01'::date),
        ('2002', '刘芳', 'female'::text, 'both'::staff_type, '13001', '教授', '院长', '研究生', '博士', '计算机科学',
         'liufang@example.com', '13900000102', '2012-02-01'::date),
        ('2003', '陈明', 'male'::text, 'both'::staff_type, '13002', '教授', '院长', '研究生', '博士', '汽车工程',
         'chenming@example.com', '13900000103', '2012-03-01'::date),
        ('2004', '赵燕', 'female'::text, 'both'::staff_type, '13003', '教授', '院长', '研究生', '博士', '工商管理',
         'zhaoyan@example.com', '13900000104', '2012-04-01'::date),
        ('2005', '孙伟', 'male'::text, 'both'::staff_type, '13004', '教授', '院长', '研究生', '博士', '土木工程',
         'sunwei@example.com', '13900000105', '2012-05-01'::date)
) AS s(staff_code, staff_name, gender, staff_type, org_code, position_title, admin_title, 
      education, degree, specialty, email, phone, entry_date)
JOIN organization o ON o.org_code = s.org_code;

-- 插入部分教研室主任（以智能制造学院为例）
INSERT INTO staff (staff_code, staff_name, gender, staff_type, org_id, position_title, admin_title, 
                  education, degree, specialty, email, phone, entry_date)
SELECT 
    s.staff_code, s.staff_name, s.gender, s.staff_type,
    o.id as org_id,
    s.position_title, s.admin_title, s.education, s.degree, s.specialty,
    s.email, s.phone, s.entry_date
FROM (
    VALUES 
        ('3001', '张工', 'male'::text, 'both'::staff_type, '13000401', '副教授', '教研室主任', '研究生', '硕士', '机械制造',
         'zhanggong@example.com', '13900000201', '2013-01-01'::date),
        ('3002', '李明', 'male'::text, 'both'::staff_type, '13000402', '副教授', '教研室主任', '研究生', '硕士', '数控技术',
         'liming@example.com', '13900000202', '2013-02-01'::date),
        ('3003', '王华', 'male'::text, 'both'::staff_type, '13000403', '副教授', '教研室主任', '研究生', '硕士', '机器人技术',
         'wanghua@example.com', '13900000203', '2013-03-01'::date)
) AS s(staff_code, staff_name, gender, staff_type, org_code, position_title, admin_title, 
      education, degree, specialty, email, phone, entry_date)
JOIN organization o ON o.org_code = s.org_code;

-- 插入实训中心主任
INSERT INTO staff (staff_code, staff_name, gender, staff_type, org_id, position_title, admin_title, 
                  education, degree, specialty, email, phone, entry_date)
SELECT 
    s.staff_code, s.staff_name, s.gender, s.staff_type,
    o.id as org_id,
    s.position_title, s.admin_title, s.education, s.degree, s.specialty,
    s.email, s.phone, s.entry_date
FROM (
    VALUES 
        ('4001', '周强', 'male'::text, 'both'::staff_type, '14001', '副教授', '实训中心主任', '研究生', '硕士', '机械工程',
         'zhouqiang@example.com', '13900000301', '2014-01-01'::date)
) AS s(staff_code, staff_name, gender, staff_type, org_code, position_title, admin_title, 
      education, degree, specialty, email, phone, entry_date)
JOIN organization o ON o.org_code = s.org_code;

-- 插入教师兼职数据
INSERT INTO staff_organization (staff_id, org_id, position_type, admin_title, start_date)
SELECT 
    s.id as staff_id,
    o.id as org_id,
    'part_time' as position_type,
    '实训中心主任' as admin_title,
    '2020-01-01'::date as start_date
FROM staff s
JOIN organization o ON o.org_code IN ('14001001', '14001002')
WHERE s.staff_code IN ('2001', '2002'); 