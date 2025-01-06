-- 插入电子信息学院下属机构
WITH ele_info AS (SELECT id FROM organization WHERE org_code = '13001')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('13001100', '院长办公室', 'academic', (SELECT id FROM ele_info), 3, '主任', 1),
    ('13001200', '教务办公室', 'academic', (SELECT id FROM ele_info), 3, '主任', 2),
    ('13001300', '学工办公室', 'academic', (SELECT id FROM ele_info), 3, '主任', 3),
    -- 教研室
    ('13001401', '计算机应用教研室', 'teaching', (SELECT id FROM ele_info), 3, '主任', 4),
    ('13001402', '软件技术教研室', 'teaching', (SELECT id FROM ele_info), 3, '主任', 5),
    ('13001403', '物联网技术教研室', 'teaching', (SELECT id FROM ele_info), 3, '主任', 6),
    ('13001404', '人工智能教研室', 'teaching', (SELECT id FROM ele_info), 3, '主任', 7);

-- 插入汽车工程学院下属机构
WITH auto_eng AS (SELECT id FROM organization WHERE org_code = '13002')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('13002100', '院长办公室', 'academic', (SELECT id FROM auto_eng), 3, '主任', 1),
    ('13002200', '教务办公室', 'academic', (SELECT id FROM auto_eng), 3, '主任', 2),
    ('13002300', '学工办公室', 'academic', (SELECT id FROM auto_eng), 3, '主任', 3),
    -- 教研室
    ('13002401', '汽车检测与维修教研室', 'teaching', (SELECT id FROM auto_eng), 3, '主任', 4),
    ('13002402', '新能源汽车教研室', 'teaching', (SELECT id FROM auto_eng), 3, '主任', 5),
    ('13002403', '汽车制造教研室', 'teaching', (SELECT id FROM auto_eng), 3, '主任', 6);

-- 插入经济管理学院下属机构
WITH business AS (SELECT id FROM organization WHERE org_code = '13003')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('13003100', '院长办公室', 'academic', (SELECT id FROM business), 3, '主任', 1),
    ('13003200', '教务办公室', 'academic', (SELECT id FROM business), 3, '主任', 2),
    ('13003300', '学工办公室', 'academic', (SELECT id FROM business), 3, '主任', 3),
    -- 教研室
    ('13003401', '会计教研室', 'teaching', (SELECT id FROM business), 3, '主任', 4),
    ('13003402', '物流管理教研室', 'teaching', (SELECT id FROM business), 3, '主任', 5),
    ('13003403', '电子商务教研室', 'teaching', (SELECT id FROM business), 3, '主任', 6),
    ('13003404', '工商管理教研室', 'teaching', (SELECT id FROM business), 3, '主任', 7);

-- 插入建筑工程学院下属机构
WITH construction AS (SELECT id FROM organization WHERE org_code = '13004')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('13004100', '院长办公室', 'academic', (SELECT id FROM construction), 3, '主任', 1),
    ('13004200', '教务办公室', 'academic', (SELECT id FROM construction), 3, '主任', 2),
    ('13004300', '学工办公室', 'academic', (SELECT id FROM construction), 3, '主任', 3),
    -- 教研室
    ('13004401', '建筑工程教研室', 'teaching', (SELECT id FROM construction), 3, '主任', 4),
    ('13004402', '工程造价教研室', 'teaching', (SELECT id FROM construction), 3, '主任', 5),
    ('13004403', '建筑装饰教研室', 'teaching', (SELECT id FROM construction), 3, '主任', 6),
    ('13004404', '建筑设备教研室', 'teaching', (SELECT id FROM construction), 3, '主任', 7);

-- 插入各实训中心下属实训室
-- 电子信息实训中心
WITH ele_training AS (SELECT id FROM organization WHERE org_code = '14001002')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('14001002001', '软件开发实训室', 'service', (SELECT id FROM ele_training), 4, '负责人', 1),
    ('14001002002', '物联网技术实训室', 'service', (SELECT id FROM ele_training), 4, '负责人', 2),
    ('14001002003', '人工智能实训室', 'service', (SELECT id FROM ele_training), 4, '负责人', 3),
    ('14001002004', '大数据实训室', 'service', (SELECT id FROM ele_training), 4, '负责人', 4);

-- 汽车工程实训中心
WITH auto_training AS (SELECT id FROM organization WHERE org_code = '14001003')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('14001003001', '汽车检测实训室', 'service', (SELECT id FROM auto_training), 4, '负责人', 1),
    ('14001003002', '新能源汽车实训室', 'service', (SELECT id FROM auto_training), 4, '负责人', 2),
    ('14001003003', '汽车维修实训室', 'service', (SELECT id FROM auto_training), 4, '负责人', 3);

-- 经管实训中心
WITH business_training AS (SELECT id FROM organization WHERE org_code = '14001004')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('14001004001', 'ERP沙盘实训室', 'service', (SELECT id FROM business_training), 4, '负责人', 1),
    ('14001004002', '电子商务实训室', 'service', (SELECT id FROM business_training), 4, '负责人', 2),
    ('14001004003', '现代物流实训室', 'service', (SELECT id FROM business_training), 4, '负责人', 3);

-- 建筑工程实训中心
WITH construction_training AS (SELECT id FROM organization WHERE org_code = '14001005')
INSERT INTO organization (org_code, org_name, org_type, parent_id, level_num, leader_title, sort_order)
VALUES 
    ('14001005001', 'BIM技术实训室', 'service', (SELECT id FROM construction_training), 4, '负责人', 1),
    ('14001005002', '建筑材料实训室', 'service', (SELECT id FROM construction_training), 4, '负责人', 2),
    ('14001005003', '工程测量实训室', 'service', (SELECT id FROM construction_training), 4, '负责人', 3);

-- 更新院系描述信息
UPDATE organization 
SET description = CASE org_code
    WHEN '13001' THEN '主要培养计算机、软件、物联网等相关专业人才'
    WHEN '13002' THEN '主要培养汽车检测与维修、新能源汽车等相关专业人才'
    WHEN '13003' THEN '主要培养会计、物流管理、电子商务等相关专业人才'
    WHEN '13004' THEN '主要培养建筑工程、工程造价等相关专业人才'
    ELSE description
END
WHERE org_code IN ('13001', '13002', '13003', '13004'); 