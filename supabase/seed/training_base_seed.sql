-- 注意：在运行此脚本前，请先通过 Supabase Dashboard 创建测试用户
-- 然后将下面的 UUID 替换为实际创建的用户 ID

-- 假设我们已经通过 Supabase Auth 创建了这些用户：
-- admin@hcylsoft.com
-- teacher1@hcylsoft.com
-- teacher2@hcylsoft.com

-- 插入测试用户档案数据
DO $$
DECLARE
    admin_id UUID;
    teacher1_id UUID;
    teacher2_id UUID;
BEGIN
    -- 获取实际的 auth.users ID
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@hcylsoft.com' LIMIT 1;
    SELECT id INTO teacher1_id FROM auth.users WHERE email = 'teacher1@hcylsoft.com' LIMIT 1;
    SELECT id INTO teacher2_id FROM auth.users WHERE email = 'teacher2@hcylsoft.com' LIMIT 1;

    -- 插入 profiles 数据
    INSERT INTO profiles (id, username, real_name, dept_code, dept_name, role, phone, email, status)
    VALUES
        (admin_id, 'admin1', '管理员1', 'AD001', '信息中心', 'admin', '13800138001', 'admin@hcylsoft.com', 'active'),
        (teacher1_id, 'teacher1', '教师1', 'CS001', '计算机系', 'teacher', '13800138002', 'teacher1@hcylsoft.com', 'active'),
        (teacher2_id, 'teacher2', '教师2', 'EE001', '电子系', 'teacher', '13800138003', 'teacher2@hcylsoft.com', 'active');

    -- 插入实训基地数据
    INSERT INTO training_bases (
        base_name, dept_code, dept_name, support_unit, base_type, 
        contact_person, contact_phone, address, capacity, manager_id, status, remarks
    )
    VALUES
        ('计算机实训中心', 'CS001', '计算机系', '信息技术学院', 'internal',
         '张主任', '13900139001', '教学楼B区501', 120, teacher1_id,
         'active', '配备100台高配置计算机'),
        
        ('电子工程实训室', 'EE001', '电子系', '电子工程学院', 'internal',
         '李主任', '13900139002', '实训楼A区302', 60, teacher2_id,
         'active', '配备先进电子实验设备'),
        
        ('华为ICT学院', 'CS002', '计算机系', '华为技术有限公司', 'external',
         '王经理', '13900139003', '科技园区23号', 150, teacher1_id,
         'active', '华为授权培训基地'),
        
        ('智能制造实训中心', 'ME001', '机械系', '机械工程学院', 'internal',
         '刘主任', '13900139004', '实训楼B区101', 80, admin_id,
         'active', '配备工业机器人和数控设备');

END $$;

-- 插入实训基地图片数据
INSERT INTO training_base_images (base_id, image_url, is_main)
SELECT 
    id,
    'https://hcylsoft.com/images/base_' || id || '_main.jpg',
    true
FROM training_bases;

-- 插入实训基地专业数据
INSERT INTO training_base_majors (base_id, major_name)
SELECT id, '软件技术' FROM training_bases WHERE dept_code = 'CS001'
UNION ALL
SELECT id, '计算机网络技术' FROM training_bases WHERE dept_code = 'CS001'
UNION ALL
SELECT id, '电子技术' FROM training_bases WHERE dept_code = 'EE001'
UNION ALL
SELECT id, '物联网技术' FROM training_bases WHERE dept_code = 'EE001'
UNION ALL
SELECT id, '机械制造' FROM training_bases WHERE dept_code = 'ME001';

-- 插入实训基地合作企业数据
INSERT INTO training_base_companies (
    base_id, company_name, cooperation_type, start_date, end_date
)
VALUES
    ((SELECT id FROM training_bases WHERE base_name = '华为ICT学院'),
     '华为技术有限公司', '深度合作', '2023-01-01', '2025-12-31'),
    
    ((SELECT id FROM training_bases WHERE base_name = '计算机实训中心'),
     '腾讯云计算有限公司', '技术支持', '2023-03-01', '2024-02-29'),
    
    ((SELECT id FROM training_bases WHERE base_name = '电子工程实训室'),
     '中兴通讯股份有限公司', '设备支持', '2023-06-01', '2024-05-31'),
    
    ((SELECT id FROM training_bases WHERE base_name = '智能制造实训中心'),
     '发那科机器人有限公司', '设备支持', '2023-09-01', '2024-08-31'); 