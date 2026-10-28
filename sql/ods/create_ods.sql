-- 1. 创建数据库
create database if not exists ydsh_ods;
use ydsh_ods;

-- 2. 创建订单表 (ods_order) - 根据你发来的真实表头
create table if not exists ods_order(
  order_id string, user_id string, store_id string, order_date string, order_time string,
  pay_amount double, discount_amount double, pay_type string, order_status string, channel string
) row format delimited fields terminated by ','
tblproperties('skip.header.line.count'='1');

-- 3. 创建订单明细表 (ods_order_item) - 注意字段名是 item_id 不是 order_item_id
create table if not exists ods_order_item(
  item_id string, order_id string, product_id string, quantity int,
  unit_price double, discount double
) row format delimited fields terminated by ','
tblproperties('skip.header.line.count'='1');

-- 4. 创建其他4张表 (假设字段如下，如果不对请修改字段名)
-- 用户表
create table if not exists ods_user(
  user_id string, user_name string, gender string, age int,
  city string, province string, register_date string,
  member_level string, phone string, email string
) row format delimited fields terminated by ',' tblproperties('skip.header.line.count'='1');

-- 商品表
create table if not exists ods_product(
  product_id string, product_name string, category_id string, category_name string,
  price double, stock int, launch_date string, brand string, status string
) row format delimited fields terminated by ',' tblproperties('skip.header.line.count'='1');

-- 门店表
create table if not exists ods_store(
  store_id string, store_name string, city string, province string,
  address string, manager_name string, open_date string, store_level string
) row format delimited fields terminated by ',' tblproperties('skip.header.line.count'='1');

-- 用户行为表
create table if not exists ods_user_behavior(
  behavior_id string, user_id string, product_id string, behavior_type string,
  behavior_time string, channel string
) row format delimited fields terminated by ',' tblproperties('skip.header.line.count'='1');

-- 5. 导入数据 (容器内的 /data 对应你宿主机的 模拟数据 文件夹)
load data local inpath '/data/ods_user.csv' into table ods_user;
load data local inpath '/data/ods_product.csv' into table ods_product;
load data local inpath '/data/ods_store.csv' into table ods_store;
load data local inpath '/data/ods_order.csv' into table ods_order;
load data local inpath '/data/ods_order_item.csv' into table ods_order_item;
load data local inpath '/data/ods_user_behavior.csv' into table ods_user_behavior;

-- 6. 验证行数 (必须对上：user=1000, product=600, store=60, order=15600, item=37549, behavior=60000)
select 'ods_user' as table_name, count(*) as row_count from ods_user
union all select 'ods_product', count(*) from ods_product
union all select 'ods_store', count(*) from ods_store
union all select 'ods_order', count(*) from ods_order
union all select 'ods_order_item', count(*) from ods_order_item
union all select 'ods_user_behavior', count(*) from ods_user_behavior;