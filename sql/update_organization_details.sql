-- 更新学校主要部门的办公地点和联系方式
UPDATE organization 
SET address = CASE org_code
    WHEN '10000' THEN '滨海区海洋路1号'
    WHEN '11000' THEN '行政楼201室'
    WHEN '12000' THEN '行政楼301室'
    WHEN '12001' THEN '行政楼401室'
    WHEN '12002' THEN '行政楼501室'
    WHEN '12003' THEN '行政楼601室'
    WHEN '12004' THEN '后勤服务楼101室'
    WHEN '12005' THEN '图书馆副楼201室'
    WHEN '14000' THEN '图书馆主楼'
    WHEN '14001' THEN '实训中心主楼'
    WHEN '14002' THEN '图书馆副楼301室'
    WHEN '14003' THEN '继续教育楼101室'
END,
    leader_phone = CASE org_code
    WHEN '10000' THEN '0532-88888888'
    WHEN '11000' THEN '0532-88888001'
    WHEN '12000' THEN '0532-88888101'
    WHEN '12001' THEN '0532-88888102'
    WHEN '12002' THEN '0532-88888103'
    WHEN '12003' THEN '0532-88888104'
    WHEN '12004' THEN '0532-88888105'
    WHEN '12005' THEN '0532-88888106'
    END
WHERE org_code IN ('10000', '11000', '12000', '12001', '12002', '12003', '12004', '12005', 
                  '14000', '14001', '14002', '14003');

-- 更新院系的办公地点
UPDATE organization 
SET address = CASE org_code
    WHEN '13000' THEN '智能制造楼A101室'
    WHEN '13001' THEN '电子信息楼B101室'
    WHEN '13002' THEN '汽车工程楼C101室'
    WHEN '13003' THEN '经管楼D101室'
    WHEN '13004' THEN '建工楼E101室'
END,
    leader_phone = CASE org_code
    WHEN '13000' THEN '0532-88888201'
    WHEN '13001' THEN '0532-88888202'
    WHEN '13002' THEN '0532-88888203'
    WHEN '13003' THEN '0532-88888204'
    WHEN '13004' THEN '0532-88888205'
END
WHERE org_code IN ('13000', '13001', '13002', '13003', '13004');

-- 更新实训中心的办公地点
UPDATE organization 
SET address = CASE org_code
    WHEN '14001001' THEN '智能制造实训楼101室'
    WHEN '14001002' THEN '电子信息实训楼201室'
    WHEN '14001003' THEN '汽车工程实训楼301室'
    WHEN '14001004' THEN '经管实训楼401室'
    WHEN '14001005' THEN '建工实训楼501室'
END,
    leader_phone = CASE org_code
    WHEN '14001001' THEN '0532-88888301'
    WHEN '14001002' THEN '0532-88888302'
    WHEN '14001003' THEN '0532-88888303'
    WHEN '14001004' THEN '0532-88888304'
    WHEN '14001005' THEN '0532-88888305'
END
WHERE org_code IN ('14001001', '14001002', '14001003', '14001004', '14001005'); 