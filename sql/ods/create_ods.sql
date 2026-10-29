-- 1. 创建并切换数据库
create database if not exists ydsh_ods;
use ydsh_ods;

-- 2. 创建用户表 (ods_user)
create table if not exists ods_user(
  user_id string, user_name string, gender string, age int,
  city string, province string, register_date string,
  member_level string, phone string, email string
) row format delimited fields terminated by ','
tblproperties('skip.header.line.count'='1');

-- 3. 创建商品表 (ods_product) - 按真实表头修正
create table if not exists ods_product(
  product_id string, product_name string, category string, sub_category string,
  brand string, price double, cost double, stock int, status string, launch_date string
) row format delimited fields terminated by ','
tblproperties('skip.header.line.count'='1');

-- 4. 创建门店表 (ods_store) - 按真实表头修正
create table if not exists ods_store(
  store_id string, store_name string, province string, city string,
  district string, address string, open_date string, area double, manager string
) row format delimited fields terminated by ','
tblproperties('skip.header.line.count'='1');

-- 5. 创建订单表 (ods_order)
create table if not exists ods_order(
  order_id string, user_id string, store_id string, order_date string, order_time string,
  pay_amount double, discount_amount double, pay_type string, order_status string, channel string
) row format delimited fields terminated by ','
tblproperties('skip.header.line.count'='1');

-- 6. 创建订单明细表 (ods_order_item) - 注意是 item_id
create table if not exists ods_order_item(
  item_id string, order_id string, product_id string, quantity int,
  unit_price double, discount double
) row format delimited fields terminated by ','
tblproperties('skip.header.line.count'='1');

-- 7. 创建用户行为表 (ods_user_behavior) - 按真实表头修正
create table if not exists ods_user_behavior(
  behavior_id string, user_id string, product_id string, behavior_type string,
  behavior_time string, session_id string
) row format delimited fields terminated by ','
tblproperties('skip.header.line.count'='1');

