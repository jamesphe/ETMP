# 数据库设计文档

## 1. 基础设置

### 1.1 用户档案表 (profiles)

存储用户基本信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键,关联auth.users |
| username | VARCHAR(100) | 用户名 |
| real_name | VARCHAR(100) | 真实姓名 |
| dept_code | VARCHAR(50) | 部门编码 |
| dept_name | VARCHAR(100) | 部门名称 |
| role | user_role | 用户角色(admin/teacher/student) |
| phone | VARCHAR(20) | 电话 |
| email | VARCHAR(100) | 邮箱 |
| avatar_url | TEXT | 头像URL |
| status | VARCHAR(20) | 状态,默认active |
| created_at | TIMESTAMPTZ | 创建时间 |
| updated_at | TIMESTAMPTZ | 更新时间 |

## 2. 组织机构

### 2.1 组织机构表 (organization)

存储学校组织架构信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT | 主键,自增 |
| org_code | VARCHAR(50) | 机构编码,唯一 |
| org_name | VARCHAR(100) | 机构名称 |
| org_type | org_type | 机构类型枚举 |
| parent_id | BIGINT | 父级ID |
| level_num | SMALLINT | 层级数 |
| leader_name | VARCHAR(100) | 负责人姓名 |
| leader_title | VARCHAR(50) | 负责人职务 |
| leader_phone | VARCHAR(20) | 负责人电话 |
| description | TEXT | 部门职责描述 |
| address | VARCHAR(200) | 办公地点 |
| sort_order | INT | 同级排序 |
| is_virtual | BOOLEAN | 是否虚拟部门 |
| status | SMALLINT | 状态(1:正常,0:停用) |

### 2.2 教职工表 (staff)

存储教职工基本信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT | 主键,自增 |
| staff_code | VARCHAR(50) | 工号,唯一 |
| staff_name | VARCHAR(100) | 姓名 |
| staff_type | staff_type | 教职工类型枚举 |
| org_id | BIGINT | 所属部门ID |
| id_number | VARCHAR(18) | 身份证号 |
| gender | VARCHAR(10) | 性别 |
| email | VARCHAR(100) | 邮箱 |
| phone | VARCHAR(20) | 电话 |
| entry_date | DATE | 入职日期 |
| status | SMALLINT | 状态 |
| profile_id | UUID | 关联用户档案 |

## 3. 班级管理

### 3.1 专业表 (majors)

存储专业信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| major_code | VARCHAR(50) | 专业代码,唯一 |
| major_name | VARCHAR(100) | 专业名称 |
| dept_code | VARCHAR(50) | 所属院系 |
| status | VARCHAR(20) | 状态 |

### 3.2 班级表 (classes)

存储班级信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| class_code | VARCHAR(50) | 班级编号,唯一 |
| class_name | VARCHAR(100) | 班级名称 |
| major_code | VARCHAR(50) | 专业代码 |
| grade_year | SMALLINT | 入学年份 |
| graduation_year | SMALLINT | 毕业年份 |
| study_length | SMALLINT | 学制(年) |
| dept_code | VARCHAR(50) | 所属院系 |
| status | VARCHAR(20) | 状态 |

## 4. 实训基地

### 4.1 实训基地表 (training_bases)

存储实训基地信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| base_name | VARCHAR(100) | 基地名称 |
| dept_code | VARCHAR(50) | 所属部门编码 |
| dept_name | VARCHAR(100) | 所属部门名称 |
| support_unit | VARCHAR(200) | 支持单位 |
| base_type | base_type | 基地类型(校内/校外) |
| contact_person | VARCHAR(50) | 联系人 |
| contact_phone | VARCHAR(20) | 联系电话 |
| address | TEXT | 地址 |
| capacity | INT | 容量 |
| manager_id | UUID | 管理员ID |
| status | VARCHAR(20) | 状态 |

### 4.2 实训室表 (training_rooms)

存储实训室信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| name | TEXT | 实训室名称 |
| base_id | UUID | 所属基地ID |
| room_code | TEXT | 房间编号,唯一 |
| area | NUMERIC(10,2) | 面积 |
| capacity | INTEGER | 容量 |
| equipment_count | INTEGER | 设备数量 |
| description | TEXT | 描述 |
| status | status_type | 状态 |
| created_at | TIMESTAMPTZ | 创建时间 |
| updated_at | TIMESTAMPTZ | 更新时间 |
| created_by | UUID | 创建人 |
| updated_by | UUID | 更新人 |

## 5. 安全和权限

### 5.1 行级安全(RLS)策略

所有表都启用了行级安全策略:

- 查看权限: 所有用户可查看
- 修改权限: 仅管理员可修改

### 5.2 触发器

- 自动更新updated_at字段
  - profiles
  - training_bases
  - training_rooms
  - training_room_equipment
  - training_room_majors
  - training_room_safety
  - training_room_managers
- 检查实训室容量
  - 新增或更新实训室专业时检查容量限制
- 检查班主任资格
  - 只允许教师或辅导员担任班主任

### 5.3 索引

主要索引包括:

- 用户相关
  - 用户名索引 (idx_profiles_username)
  - 部门编码索引 (idx_profiles_dept_code)
  - 用户角色索引 (idx_profiles_role)
  - 用户状态索引 (idx_profiles_status)

- 组织机构相关
  - 机构编码索引 (idx_org_code)
  - 教职工工号索引 (idx_staff_code)
  - 教职工部门索引 (idx_staff_org_id)
  - 教职工类型索引 (idx_staff_type)

- 班级相关
  - 专业代码索引 (idx_majors_dept_code)
  - 班级编号索引 (idx_classes_major_code)
  - 学生学号索引 (idx_students_class_id)
  - 班主任索引 (idx_class_advisors_class_id)

- 实训基地相关
  - 实训室编号索引 (idx_training_rooms_room_code)
  - 基地状态索引 (idx_training_bases_status)
  - 设备编号索引 (idx_training_room_equipment_room_code)
  - 预约日期索引 (idx_training_room_bookings_date)

## 6. 枚举类型

### 6.1 用户角色 (user_role)
- admin: 管理员
- teacher: 教师
- student: 学生

### 6.2 组织机构类型 (org_type)
- school: 学校
- party: 党群部门
- administrative: 行政部门
- academic: 教学院系
- teaching: 教研室
- research: 研究所
- service: 教辅部门
- other: 其他组织

### 6.3 教职工类型 (staff_type)
- leadership: 学校领导
- teacher: 专任教师
- admin: 行政人员
- both: 教师兼行政
- support: 教辅人员
- worker: 工勤人员
- counselor: 辅导员
- researcher: 科研人员
- part_time: 兼职教师
- retired: 退休返聘
- temporary: 临时聘用
- intern: 实习人员

### 9.1 学生状态 (student_status)
- active: 在读
- suspended: 休学
- transferred: 转学
- withdrawn: 退学
- graduated: 毕业

### 9.2 基地类型 (base_type)
- internal: 校内
- external: 校外

### 9.3 状态类型 (status_type)
- active: 正常
- inactive: 停用
- deleted: 已删除

## 7. 学生管理

### 7.1 学生表 (students)

存储学生基本信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| student_code | VARCHAR(50) | 学号,唯一 |
| student_name | VARCHAR(100) | 姓名 |
| profile_id | UUID | 关联用户档案 |
| class_id | UUID | 所属班级 |
| major_code | VARCHAR(50) | 专业代码 |
| dept_code | VARCHAR(50) | 院系代码 |
| grade_year | SMALLINT | 入学年份 |
| graduation_year | SMALLINT | 毕业年份 |
| gender | VARCHAR(10) | 性别 |
| birth_date | DATE | 出生日期 |
| id_number | VARCHAR(18) | 身份证号 |
| contact_phone | VARCHAR(20) | 联系电话 |
| contact_address | TEXT | 联系地址 |
| study_status | student_status | 学籍状态 |

### 7.2 学生状态变更记录表 (student_status_changes)

记录学生学籍状态变更历史。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| student_id | UUID | 学生ID |
| old_status | student_status | 原状态 |
| new_status | student_status | 新状态 |
| change_date | DATE | 变更日期 |
| reason | TEXT | 变更原因 |
| document_number | VARCHAR(50) | 文号 |

## 8. 实训室管理

### 8.1 实训室设备表 (training_room_equipment)

存储实训室设备信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| room_code | TEXT | 实训室编号 |
| equipment_name | TEXT | 设备名称 |
| model_number | TEXT | 型号 |
| manufacturer | TEXT | 制造商 |
| purchase_date | DATE | 购买日期 |
| unit_price | DECIMAL(10,2) | 单价 |
| quantity | INTEGER | 数量 |
| status | VARCHAR(20) | 状态 |

### 8.2 实训室预约表 (training_room_bookings)

存储实训室预约记录。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| room_code | TEXT | 实训室编号 |
| booker_id | UUID | 预约人ID |
| booking_date | DATE | 预约日期 |
| start_time | TIME | 开始时间 |
| end_time | TIME | 结束时间 |
| purpose | TEXT | 用途 |
| attendees_count | INTEGER | 使用人数 |
| status | VARCHAR(20) | 状态 |
| remarks | TEXT | 备注 |
| created_at | TIMESTAMPTZ | 创建时间 |
| updated_at | TIMESTAMPTZ | 更新时间 |

### 8.3 实训室使用记录表 (training_room_usage_logs)

记录实训室实际使用情况。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| room_code | TEXT | 实训室编号 |
| user_id | UUID | 使用人ID |
| check_in_time | TIMESTAMPTZ | 签到时间 |
| check_out_time | TIMESTAMPTZ | 签出时间 |
| actual_attendees | INTEGER | 实际人数 |
| equipment_used | TEXT[] | 使用设备 |
| issues_reported | TEXT | 问题报告 |

约束说明：
- check_out_time必须大于check_in_time
- actual_attendees不能超过实训室容量
- equipment_used必须是该实训室已有的设备

### 8.4 实训室安全信息表 (training_room_safety)

存储实训室安全相关信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| room_code | TEXT | 实训室编号 |
| safety_manager | TEXT | 安全负责人 |
| emergency_contact | TEXT | 紧急联系人 |
| safety_equipment | TEXT[] | 安全设备 |
| safety_rules | TEXT | 安全规程 |
| emergency_procedures | TEXT | 应急预案 |
| last_inspection_date | DATE | 上次检查日期 |
| next_inspection_date | DATE | 下次检查日期 |
| status | VARCHAR(20) | 状态 |
| created_at | TIMESTAMPTZ | 创建时间 |
| updated_at | TIMESTAMPTZ | 更新时间 |

## 9. 其他枚举类型

### 9.1 学生状态 (student_status)
- active: 在读
- suspended: 休学
- transferred: 转学
- withdrawn: 退学
- graduated: 毕业

### 9.2 基地类型 (base_type)
- internal: 校内
- external: 校外

### 9.3 状态类型 (status_type)
- active: 正常
- inactive: 停用
- deleted: 已删除

## 10. 视图

### 10.1 实训室设备统计视图 (training_room_equipment_stats)
统计每个实训室的设备数量和总价值。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| room_code | TEXT | 实训室编号 |
| room_name | TEXT | 实训室名称 |
| equipment_count | BIGINT | 设备种类数量 |
| total_equipment | BIGINT | 设备总数量 |
| total_value | NUMERIC | 设备总价值 |

### 10.2 实训基地使用情况视图 (training_base_usage)
统计每个基地的实训室数量和总容量。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| base_id | UUID | 基地ID |
| base_name | VARCHAR(100) | 基地名称 |
| room_count | BIGINT | 实训室数量 |
| total_capacity | BIGINT | 总容量 |
| manager_count | BIGINT | 管理人员数量 |

### 10.3 当前班主任视图 (current_class_advisors)
显示当前有效的班主任信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 记录ID |
| class_code | VARCHAR(50) | 班级编号 |
| class_name | VARCHAR(100) | 班级名称 |
| major_code | VARCHAR(50) | 专业代码 |
| dept_code | VARCHAR(50) | 院系代码 |
| staff_code | VARCHAR(50) | 教师工号 |
| advisor_name | VARCHAR(100) | 班主任姓名 |
| start_date | DATE | 开始日期 |
| end_date | DATE | 结束日期 |
| status | VARCHAR(20) | 状态 |

### 10.4 当前班干部视图 (current_class_officers)
显示当前在任的班干部信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 记录ID |
| class_code | VARCHAR(50) | 班级编号 |
| class_name | VARCHAR(100) | 班级名称 |
| student_code | VARCHAR(50) | 学号 |
| student_name | VARCHAR(100) | 学生姓名 |
| position | VARCHAR(50) | 职务 |
| start_date | DATE | 开始日期 |
| end_date | DATE | 结束日期 |
| status | VARCHAR(20) | 状态 |

## 11. 数据完整性

### 11.1 外键约束
- 所有关联字段都建立了相应的外键约束
  - profiles.id -> auth.users.id
  - staff.org_id -> organization.id
  - staff.profile_id -> profiles.id
  - training_room_equipment.room_code -> training_rooms.room_code
  - training_room_majors.room_code -> training_rooms.room_code
  - training_room_safety.room_code -> training_rooms.room_code
  - training_room_managers.room_code -> training_rooms.room_code
- 使用CASCADE或SET NULL确保数据一致性

### 11.2 唯一约束
- 工号、学号、身份证号等关键字段
  - staff.staff_code
  - staff.id_number
  - students.student_code
  - students.id_number
  - training_rooms.room_code
- 确保编码字段的唯一性
  - organization.org_code
  - majors.major_code
  - classes.class_code
- 复合唯一约束
  - training_base_majors(base_id, major_name)
  - training_room_majors(room_code, major_name)

### 11.3 检查约束
- 日期范围检查
  - 实训室预约时间：end_time > start_time
  - 企业合作时间：end_date >= start_date
  - 职务任期：end_date >= start_date
  - 班主任任期：end_date >= start_date
  - 班干部任期：end_date >= start_date
- 容量限制检查
  - 实训室学生容量不能超过总容量
  - 预约人数不能超过实训室容量
- 状态有效性检查
  - 实训室状态必须为有效枚举值
  - 设备状态必须为有效枚举值
  - 学生状态必须为有效枚举值
  - 教职工状态必须为有效枚举值

## 12. 班级管理相关表

### 12.1 班主任表 (class_advisors)

记录班级的班主任信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| class_id | UUID | 班级ID |
| advisor_id | BIGINT | 班主任ID(关联staff表) |
| start_date | DATE | 开始日期 |
| end_date | DATE | 结束日期 |
| status | VARCHAR(20) | 状态 |
| remarks | TEXT | 备注 |

### 12.2 班干部表 (class_officers)

记录班级干部信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| class_id | UUID | 班级ID |
| student_id | UUID | 学生ID |
| position | VARCHAR(50) | 职务 |
| start_date | DATE | 开始日期 |
| end_date | DATE | 结束日期 |
| status | VARCHAR(20) | 状态 |
| remarks | TEXT | 备注 |

## 13. 教师扩展信息

### 13.1 教师信息表 (teacher_info)

存储教师的扩展信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| staff_id | BIGINT | 主键,关联staff表 |
| education_level | VARCHAR(50) | 学历 |
| degree | VARCHAR(50) | 学位 |
| graduation_school | VARCHAR(100) | 毕业院校 |
| major_studied | VARCHAR(100) | 所学专业 |
| teaching_subject | TEXT[] | 任教学科 |
| research_direction | TEXT[] | 研究方向 |
| created_at | TIMESTAMPTZ | 创建时间 |
| updated_at | TIMESTAMPTZ | 更新时间 |

### 13.2 辅导员信息表 (counselor_info)

存储辅导员的扩展信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| staff_id | BIGINT | 主键,关联staff表 |
| student_work_years | INTEGER | 学生工作年限 |
| counseling_cert | VARCHAR(50) | 心理咨询证书 |
| managed_grades | TEXT[] | 管理的年级 |

### 13.3 行政人员信息表 (admin_info)

存储行政人员的扩展信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| staff_id | BIGINT | 主键,关联staff表 |
| admin_level | VARCHAR(50) | 行政级别 |
| duty_scope | TEXT[] | 分管工作范围 |

## 14. 职称与职务管理

### 14.1 职称记录表 (staff_title_records)

记录教职工职称信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| staff_id | BIGINT | 教职工ID |
| title_name | VARCHAR(50) | 职称名称 |
| title_level | VARCHAR(50) | 职称等级 |
| certificate_no | VARCHAR(100) | 证书编号 |
| issue_date | DATE | 获得日期 |
| issue_authority | VARCHAR(100) | 发证机构 |
| status | VARCHAR(20) | 状态 |

### 14.2 职务记录表 (staff_position_records)

记录教职工职务信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| staff_id | BIGINT | 教职工ID |
| position_name | VARCHAR(50) | 职务名称 |
| org_code | VARCHAR(50) | 所属机构 |
| start_date | DATE | 开始日期 |
| end_date | DATE | 结束日期 |
| appointment_doc | VARCHAR(100) | 任命文号 |
| status | VARCHAR(20) | 状态 |
| handover_reason | TEXT | 交接原因 |

### 14.3 教职工兼职表 (staff_organization)

记录教职工的兼职信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| staff_id | BIGINT | 教职工ID |
| org_id | BIGINT | 机构ID |
| position | VARCHAR(50) | 职务 |
| is_main | BOOLEAN | 是否主要职务 |
| start_date | DATE | 开始日期 |
| end_date | DATE | 结束日期 |
| status | VARCHAR(20) | 状态 |

## 15. 数据库维护

### 15.1 备份策略
- 每日增量备份
  - 时间：每日凌晨2:00
  - 保留期限：7天
  - 备份内容：数据变更
- 每周全量备份
  - 时间：每周日凌晨3:00
  - 保留期限：30天
  - 备份内容：全库备份
- 备份保留策略
  - 本地备份：7天
  - 异地备份：30天
  - 归档备份：1年

### 15.2 性能优化
- 定期更新统计信息
  - 每周更新表统计信息
  - 监控查询性能
  - 优化慢查询
- 定期重建索引
  - 每月重建索引
  - 监控索引使用情况
  - 优化索引策略
- 监控查询性能
  - 设置查询超时阈值
  - 记录慢查询日志
  - 优化频繁查询

### 15.3 数据清理
- 定期归档历史数据
  - 每季度归档历史数据
  - 设置归档策略
  - 保留必要索引
- 清理过期临时数据
  - 每周清理临时表
  - 清理过期会话
  - 清理日志数据
- 维护数据一致性
  - 检查外键完整性
  - 修复损坏数据
  - 处理孤立记录

## 16. 安全策略

### 16.1 访问控制
- 基于角色的访问控制(RBAC)
- 行级安全策略(RLS)
- IP白名单限制

### 16.2 审计日志
- 记录数据变更
- 记录用户操作
- 记录异常访问

### 16.3 数据加密
- 敏感字段加密存储
- 传输数据加密
- 备份数据加密

## 17. 命名规范

### 17.1 表命名
- 使用小写字母和下划线
- 使用复数形式
- 相关表使用相同前缀
- 示例：training_rooms, training_room_equipment

### 17.2 字段命名
- 使用小写字母和下划线
- 主键统一使用id
- 外键使用关联表名_id
- 创建和更新时间字段固定为created_at和updated_at

### 17.3 索引命名
- 格式：idx_表名_字段名
- 唯一索引：uk_表名_字段名
- 外键索引：fk_表名_字段名

### 17.4 约束命名
- 主键：pk_表名
- 外键：fk_从表_主表
- 唯一约束：uk_表名_字段列表
- 检查约束：ck_表名_规则描述

