-- 清空已有数据（如果需要）
TRUNCATE TABLE staff_organization CASCADE;
TRUNCATE TABLE staff CASCADE;
TRUNCATE TABLE organization CASCADE;

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

-- 插入实训中心下属机构
WITH training_center AS (SELECT id FROM organization WHERE org_code = '14001')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('14001001', '智能制造实训中心', 'service', (SELECT id FROM training_center), 3, '主任', 1),
    ('14001002', '电子信息实训中心', 'service', (SELECT id FROM training_center), 3, '主任', 2),
    ('14001003', '汽车工程实训中心', 'service', (SELECT id FROM training_center), 3, '主任', 3),
    ('14001004', '经管实训中心', 'service', (SELECT id FROM training_center), 3, '主任', 4),
    ('14001005', '建筑工程实训中心', 'service', (SELECT id FROM training_center), 3, '主任', 5);

-- 插入智能制造实训中心下属实训室
WITH smart_training AS (SELECT id FROM organization WHERE org_code = '14001001')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('14001001001', '数控加工实训室', 'service', (SELECT id FROM smart_training), 4, '负责人', 1),
    ('14001001002', '工业机器人实训室', 'service', (SELECT id FROM smart_training), 4, '负责人', 2),
    ('14001001003', '3D打印实验室', 'service', (SELECT id FROM smart_training), 4, '负责人', 3),
    ('14001001004', '模具制作实训室', 'service', (SELECT id FROM smart_training), 4, '负责人', 4);

-- 更新部门描述信息
UPDATE organization 
SET description = CASE org_code
    WHEN '13000' THEN '主要培养智能制造、自动化等相关专业人才'
    WHEN '13001' THEN '主要培养计算机、软件、物联网等相关专业人才'
    WHEN '14001' THEN '承担全校实践教学任务，设备总值超1.5亿元'
    ELSE description
END
WHERE org_code IN ('13000', '13001', '14001'); 