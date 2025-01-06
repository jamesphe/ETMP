# 班级管理模块设计文档

## 一、设计目标

### 1.1 业务目标
- 实现班级信息的完整管理
- 支持学生学籍管理
- 支持班主任管理
- 支持班干部管理
- 满足教学管理的各项需求

### 1.2 技术目标
- 数据结构清晰，易于维护
- 支持灵活的查询和统计
- 确保数据一致性和完整性
- 保留完整的历史记录

## 二、业务概念

### 2.1 专业管理
- 专业归属于院系
- 包含专业代码和名称
- 记录专业状态
- 支持专业备注说明

### 2.2 班级管理
- 班级归属于专业
- 包含年级和学制信息
- 记录班级状态
- 支持班级备注说明

### 2.3 学生管理
- 学生归属于班级
- 包含学籍状态管理
- 关联用户档案系统
- 支持学生信息变更

### 2.4 班主任管理
- 班主任必须是教师
- 记录任职时间段
- 支持班主任更换
- 维护历史记录

### 2.5 班干部管理
- 班干部必须是本班学生
- 记录任职时间段
- 支持职务变更
- 维护历史记录

## 三、数据库设计

### 3.1 专业表（majors）
| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| major_code | VARCHAR(50) | 专业代码 |
| major_name | VARCHAR(100) | 专业名称 |
| dept_code | VARCHAR(50) | 所属院系 |
| status | VARCHAR(20) | 状态 |
| remarks | TEXT | 备注 |

### 3.2 班级表（classes）
| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| class_code | VARCHAR(50) | 班级代码 |
| class_name | VARCHAR(100) | 班级名称 |
| major_code | VARCHAR(50) | 所属专业 |
| grade_year | SMALLINT | 入学年份 |
| graduation_year | SMALLINT | 毕业年份 |
| study_length | SMALLINT | 学制 |
| dept_code | VARCHAR(50) | 所属院系 |
| status | VARCHAR(20) | 状态 |

### 3.3 学生表（students）
| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| student_code | VARCHAR(50) | 学号 |
| student_name | VARCHAR(100) | 姓名 |
| profile_id | UUID | 用户档案ID |
| class_id | UUID | 所属班级 |
| major_code | VARCHAR(50) | 所属专业 |
| dept_code | VARCHAR(50) | 所属院系 |
| study_status | VARCHAR(20) | 学籍状态 |

### 3.4 班主任表（class_advisors）
| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| class_id | UUID | 班级ID |
| advisor_id | UUID | 教师ID |
| start_date | DATE | 开始日期 |
| end_date | DATE | 结束日期 |
| status | VARCHAR(20) | 状态 |

### 3.5 班干部表（class_officers）
| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | UUID | 主键 |
| class_id | UUID | 班级ID |
| student_id | UUID | 学生ID |
| position | VARCHAR(50) | 职务 |
| start_date | DATE | 开始日期 |
| end_date | DATE | 结束日期 |
| status | VARCHAR(20) | 状态 |

## 四、视图设计

### 4.1 当前班主任视图（current_class_advisors）
- 显示当前有效的班主任信息
- 包含班级和教师基本信息
- 仅显示未结束的任职记录

### 4.2 当前班干部视图（current_class_officers）
- 显示当前有效的班干部信息
- 包含班级和学生基本信息
- 仅显示未结束的任职记录

## 五、权限控制

### 5.1 数据查看权限
- 所有用户可查看专业信息
- 所有用户可查看班级信息
- 所有用户可查看班主任信息
- 所有用户可查看班干部信息
- 所有用户可查看学生基本信息

### 5.2 数据修改权限
- 仅管理员可修改专业信息
- 仅管理员可修改班级信息
- 仅管理员可修改班主任信息
- 仅管理员可修改班干部信息
- 仅管理员可修改学生信息

## 六、索引优化

### 6.1 主要索引
- 专业表：major_code, dept_code
- 班级表：class_code, major_code, dept_code
- 学生表：student_code, class_id, major_code
- 班主任表：class_id, advisor_id
- 班干部表：class_id, student_id

### 6.2 索引说明
- 支持按院系查询班级
- 支持按专业统计班级
- 优化班级学生查询
- 提升班主任查询性能
- 优化班干部查询效率

## 七、数据完整性

### 7.1 约束条件
- 专业代码唯一性约束
- 班级代码唯一性约束
- 学号唯一性约束
- 班主任必须是教师
- 班干部必须是本班学生

### 7.2 触发器
- 自动更新时间戳
- 班主任身份检查
- 班干部身份检查
- 学籍状态变更记录