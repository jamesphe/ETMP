****# 🎓 高职院校实训管理平台  

## 📌 项目简介  
本项目是一个基于 **Vue 3 + Supabase** 构建的高职院校实训管理平台，旨在提升学校实训教学管理的数字化水平，实现对实训设备、耗材、课程、成绩等环节的全流程管理。  

**主要目标：**  
- 提高实训室和设备的使用效率  
- 实现教师、学生和管理员多角色协同  
- 提供移动端和 PC 端同步管理体验  

---

## 🚀 功能模块  

### **1. 实训基础数据管理**  
- **实训基地管理**  
- **实训室管理**  
- **实训项目管理**  

### **2. 实训设备管理**  
- **设备管理**  
  - 实训设备信息  
  - 设备申报与审核  
  - 设备采购与验收  
  - 设备日常管理  
  - 设备盘点与记录查询  

### **3. 实训耗材管理**  
- **耗材管理**  
  - 耗材申报与审核  
  - 耗材采购与入库  
  - 耗材库存管理  
  - 耗材领用与统计  

### **4. 实训课程管理**  
- **实训课程计划与课表**  
- **实训考勤与课堂互动**  
- **实训日志管理与查询**  
- **设备损坏与维修登记**  
- **实训成绩评估**  

### **5. 用户与权限管理**  
- **教师、学生和管理员权限分配**  
- **院系与班级管理**  

### **6. 数据统计与分析**  
- **实训课程与设备使用统计**  
- **学生实训成绩与考勤统计**  

---

## 🛠️ 技术栈  
- **前端**：Vue 3 + Vite + Pinia  
- **后端服务**：Supabase (PostgreSQL + GoTrue + Realtime)  
- **身份认证**：Supabase Auth  
- **存储**：Supabase Storage  
- **UI框架**：Element Plus / Tailwind CSS  

---

## 📂 目录结构  
```bash
├── src                     # 源代码文件夹
│   ├── components          # 通用组件
│   ├── views               # 页面视图
│   ├── store               # Pinia状态管理
│   ├── router              # 路由配置
│   ├── services            # Supabase服务封装
│   └── assets              # 静态资源
├── public                  # 公共资源
├── docs                    # 文档文件夹
├── tests                   # 测试代码
└── README.md               # 项目说明文件
```

---

## 💻 安装与运行  

### 1. 克隆项目到本地  
```bash
git clone https://github.com/username/project-name.git
```

### 2. 进入项目目录  
```bash
cd project-name
```

### 3. 安装依赖  
```bash
npm install
```

### 4. 配置 Supabase  
在项目根目录下创建 `.env` 文件，添加以下配置：  
```env
VITE_SUPABASE_URL=https://xyzcompany.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```
> **提示：** Supabase 控制台可获取 `URL` 和 `Anon Key`。  

### 5. 运行项目  
```bash
npm run dev
```

---

## 🔧 Supabase 配置  

1. **创建项目**  
   在 [Supabase 官网](https://supabase.com) 注册并创建一个新项目。  

2. **数据库初始化**  
   进入 Supabase SQL Editor，执行以下 SQL 初始化表结构：  
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT CHECK(role IN ('admin', 'teacher', 'student')) NOT NULL
);

CREATE TABLE training_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_name TEXT NOT NULL,
  instructor_id UUID REFERENCES users(id),
  start_date DATE,
  end_date DATE
);

CREATE TABLE equipment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT,
  quantity INT,
  purchase_date DATE,
  status TEXT CHECK(status IN ('available', 'in_use', 'damaged'))
);
```

3. **存储设置**  
   - 创建存储桶 (Storage Bucket) 用于存放实训相关资料和图片。  
   - 在 Supabase 控制台的 `Storage` 模块中添加新的存储桶，例如 `training-assets`。  

4. **身份认证设置**  
   - 在 `Authentication` 模块中启用邮箱和第三方登录方式（如 GitHub 登录）。  

---

## 📝 使用说明  
- **管理员角色**：  
  - 管理实训室与设备  
  - 审核实训课程计划与耗材申请  
  - 统计分析各类实训数据  
- **教师角色**：  
  - 创建实训课程并记录实训日志  
  - 管理学生考勤和成绩评估  
- **学生角色**：  
  - 查看实训计划，申请参加实训课程  
  - 提交实训报告并查看成绩  

---

## 🔍 常见问题  

1. **如何解决 Supabase 无法连接的问题？**  
   - 请检查 `.env` 配置文件中 Supabase URL 和 Anon Key 是否正确。  
   - 确保项目在 Supabase 控制台中状态正常且无未支付账单。  

2. **如何处理数据同步失败问题？**  
   - 确认 Supabase 数据库权限策略（RLS）是否正确设置，允许应用访问相关数据表。  

---

## 🛡️ 贡献指南  
欢迎任何形式的贡献！您可以通过以下方式参与：  
- 提交 bug 报告和功能需求  
- 优化现有功能或新增模块  
- 撰写和完善文档  

---

## 📜 许可证  
本项目遵循 **MIT License** 许可协议，欢迎自由使用和修改。  

---
