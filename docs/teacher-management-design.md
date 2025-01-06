# 教师管理模块设计文档

## 一、设计目标

### 1.1 业务目标
- 实现教师基本信息的完整管理
- 支持职称评定和晋升管理
- 支持职务任免和变动管理
- 满足人事管理的各项需求

### 1.2 技术目标
- 数据结构清晰，易于维护
- 支持灵活的查询和统计
- 确保数据一致性和完整性
- 保留完整的历史记录

## 二、业务概念

### 2.1 教师管理
- 教师归属于院系
- 包含基本信息和教育背景
- 记录聘用类型和在职状态
- 关联用户档案系统

### 2.2 职称管理
- 支持多级职称体系
- 记录职称评定历史
- 包含证书信息
- 支持职称变更追踪

### 2.3 职务管理
- 支持院系行政职务
- 记录任免变动历史
- 包含任命文号
- 支持任职期限管理

## 三、数据库设计

### 3.1 教师基本信息表（teacher_profiles）
| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| teacher_code | VARCHAR(50) | 教师工号（唯一） |
| profile_id | UUID | 关联用户档案（外键） |
| dept_code | VARCHAR(50) | 所属院系（外键） |
| employment_date | DATE | 入职日期 |
| employment_type | VARCHAR(50) | 聘用类型 |
| education_level | VARCHAR(50) | 学历 |
| graduation_school | VARCHAR(100) | 毕业院校 |
| major_studied | VARCHAR(100) | 所学专业 |
| status | VARCHAR(20) | 在职状态 |
| remarks | TEXT | 备注说明 |
| created_at | TIMESTAMPTZ | 创建时间 |
| updated_at | TIMESTAMPTZ | 更新时间 |
| created_by | UUID | 创建人 |
| updated_by | UUID | 更新人 |

### 3.2 教师职称记录表（teacher_title_records）
| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| teacher_id | UUID | 教师ID（外键） |
| title_name | VARCHAR(50) | 职称名称 |
| title_level | VARCHAR(50) | 职称等级 |
| certificate_no | VARCHAR(100) | 证书编号 |
| issue_date | DATE | 获得日期 |
| issue_authority | VARCHAR(100) | 发证机构 |
| status | VARCHAR(20) | 状态 |
| remarks | TEXT | 备注说明 |
| created_at | TIMESTAMPTZ | 创建时间 |
| created_by | UUID | 创建人 |

### 3.3 教师职务记录表（teacher_position_records）
| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| teacher_id | UUID | 教师ID（外键） |
| position_name | VARCHAR(50) | 职务名称 |
| org_code | VARCHAR(50) | 所属部门（外键） |
| start_date | DATE | 任职开始日期 |
| end_date | DATE | 任职结束日期 |
| appointment_doc | VARCHAR(100) | 任命文号 |
| status | VARCHAR(20) | 状态 |
| handover_reason | TEXT | 交接原因 |
| remarks | TEXT | 备注说明 |
| created_at | TIMESTAMPTZ | 创建时间 |
| created_by | UUID | 创建人 |

## 四、视图设计

### 4.1 当前职称视图（current_teacher_titles）
- 显示教师当前有效的职称信息
- 包含教师基本信息和所属部门
- 仅显示有效状态的职称记录

### 4.2 当前职务视图（current_teacher_positions）
- 显示教师当前担任的职务信息
- 包含教师基本信息和所属部门
- 仅显示未结束的任职记录

## 五、权限控制

### 5.1 数据查看权限
- 所有用户可查看教师基本信息
- 所有用户可查看教师职称信息
- 所有用户可查看教师职务信息

### 5.2 数据修改权限
- 仅管理员可修改教师基本信息
- 仅管理员可修改职称记录
- 仅管理员可修改职务记录

## 六、索引优化

### 6.1 主要索引
- 教师表：dept_code, profile_id, status
- 职称表：teacher_id
- 职务表：teacher_id, org_code

### 6.2 索引说明
- 支持按院系查询教师
- 支持按职称等级统计
- 优化职务任免查询
- 提升历史记录查询性能

## 七、数据完整性

### 7.1 约束条件
- 教师工号唯一性约束
- 职务任期时间检查约束
- 外键关联完整性约束

### 7.2 触发器
- 自动更新时间戳
- 状态变更记录 