-- 创建组织架构相关表
-- Enable RLS
alter table organization enable row level security;
alter table department enable row level security;
alter table employee enable row level security;
alter table position enable row level security;
alter table org_relation enable row level security;

-- 组织表
create table organization (
    id bigint primary key generated always as identity,
    org_code varchar(50) not null,
    org_name varchar(100) not null,
    parent_id bigint references organization(id),
    status smallint default 1,
    sort_order int default 0,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    created_by uuid references auth.users(id),
    updated_by uuid references auth.users(id),
    constraint uk_org_code unique (org_code)
);

comment on table organization is '组织表';
comment on column organization.org_code is '组织编码';
comment on column organization.org_name is '组织名称';
comment on column organization.parent_id is '父组织ID';
comment on column organization.status is '状态：1-启用，0-禁用';
comment on column organization.sort_order is '排序号';

-- 部门表
create table department (
    id bigint primary key generated always as identity,
    dept_code varchar(50) not null,
    dept_name varchar(100) not null,
    org_id bigint not null references organization(id),
    parent_id bigint references department(id),
    leader_id bigint references employee(id),
    status smallint default 1,
    sort_order int default 0,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    created_by uuid references auth.users(id),
    updated_by uuid references auth.users(id),
    constraint uk_dept_code unique (dept_code)
);

comment on table department is '部门表';
comment on column department.dept_code is '部门编码';
comment on column department.dept_name is '部门名称';
comment on column department.org_id is '所属组织ID';
comment on column department.parent_id is '父部门ID';
comment on column department.leader_id is '部门负责人ID';
comment on column department.status is '状态：1-启用，0-禁用';
comment on column department.sort_order is '排序号';

-- 员工表
create table employee (
    id bigint primary key generated always as identity,
    emp_code varchar(50) not null,
    emp_name varchar(100) not null,
    dept_id bigint not null references department(id),
    position_id bigint references position(id),
    email varchar(100),
    phone varchar(20),
    status smallint default 1,
    entry_date date,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    created_by uuid references auth.users(id),
    updated_by uuid references auth.users(id),
    constraint uk_emp_code unique (emp_code)
);

comment on table employee is '员工表';
comment on column employee.emp_code is '员工编号';
comment on column employee.emp_name is '员工姓名';
comment on column employee.dept_id is '所属部门ID';
comment on column employee.position_id is '职位ID';
comment on column employee.email is '邮箱';
comment on column employee.phone is '手机号';
comment on column employee.status is '状态：1-在职，0-离职';
comment on column employee.entry_date is '入职日期';

-- 职位表
create table position (
    id bigint primary key generated always as identity,
    position_code varchar(50) not null,
    position_name varchar(100) not null,
    position_level int,
    status smallint default 1,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    created_by uuid references auth.users(id),
    updated_by uuid references auth.users(id),
    constraint uk_position_code unique (position_code)
);

comment on table position is '职位表';
comment on column position.position_code is '职位编码';
comment on column position.position_name is '职位名称';
comment on column position.position_level is '职级';
comment on column position.status is '状态：1-启用，0-禁用';

-- 组织关系表
create table org_relation (
    id bigint primary key generated always as identity,
    emp_id bigint not null references employee(id),
    org_id bigint not null references organization(id),
    dept_id bigint not null references department(id),
    relation_type smallint,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    created_by uuid references auth.users(id),
    updated_by uuid references auth.users(id),
    constraint uk_emp_org_dept unique (emp_id, org_id, dept_id)
);

comment on table org_relation is '组织关系表';
comment on column org_relation.emp_id is '员工ID';
comment on column org_relation.org_id is '组织ID';
comment on column org_relation.dept_id is '部门ID';
comment on column org_relation.relation_type is '关系类型：1-主要，2-次要';

-- 创建更新时间触发器函数
create or replace function update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

-- 为所有表添加更新时间触发器
create trigger update_organization_updated_at
    before update on organization
    for each row
    execute function update_updated_at_column();

create trigger update_department_updated_at
    before update on department
    for each row
    execute function update_updated_at_column();

create trigger update_employee_updated_at
    before update on employee
    for each row
    execute function update_updated_at_column();

create trigger update_position_updated_at
    before update on position
    for each row
    execute function update_updated_at_column();

create trigger update_org_relation_updated_at
    before update on org_relation
    for each row
    execute function update_updated_at_column(); 