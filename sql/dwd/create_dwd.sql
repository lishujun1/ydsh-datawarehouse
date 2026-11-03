use ydsh_ods;
--1 维度表 DDL
-- 用户维度
drop table if exists dwd_dim_user;
create table dwd_dim_user(
  user_id string, user_name string, gender string, age int,
  city string, province string, region string,
  register_date string, member_level string, phone string, email string
) stored as orc;

-- 商品维度（category/brand 去空格统一大写）
drop table if exists dwd_dim_product;
create table dwd_dim_product(
  product_id string, product_name string, category string,
  sub_category string, brand string, price double, cost double,
  stock int, status string, launch_date string
) stored as orc;

-- 门店维度
drop table if exists dwd_dim_store;
create table dwd_dim_store(
  store_id string, store_name string, province string, city string,
  district string, address string, open_date string, area double, manager string
) stored as orc;

-- 日期维度
drop table if exists dwd_dim_date;
create table dwd_dim_date(
  date_key string, year int, month int, day int, week int
) stored as orc;

--2 订单事实表（分区表）+ 订单明细事实表
-- 订单事实表：订单粒度，按 order_date 分区
drop table if exists dwd_order;
create table dwd_order(
  order_id string, user_id string, store_id string,
  order_timestamp string,
  pay_amount double, discount_amount double,
  pay_type string, order_status string, channel string
) partitioned by (order_date string)
stored as orc;

-- 订单明细事实表：商品粒度，用于关联商品维度
drop table if exists dwd_order_item;
create table dwd_order_item(
  item_id string, order_id string, product_id string,
  quantity int, unit_price double, discount double
) partitioned by (order_date string)
stored as orc;