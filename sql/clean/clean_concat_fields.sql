--1 订单时间合并
drop table if exists dwd_order_ts;
create table dwd_order_ts as
select
  order_id, user_id, store_id,
  concat(order_date, ' ', order_time) as order_timestamp,
  order_date,
  pay_amount, discount_amount,
  pay_type, order_status, channel
from dwd_order_final;
--验证
-- 格式应为 yyyy-MM-dd HH:mm:ss，应返回 0
select count(*) from dwd_order_ts
where order_timestamp not rlike '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$';

-- 行数 15000
select count(*) from dwd_order_ts;

-- 抽看几条
select order_id, order_date, order_timestamp from dwd_order_ts limit 5;

--2 用户 region 合并
drop table if exists dwd_user_region;
create table dwd_user_region as
select
  user_id, user_name, gender, age,
  province, city,
  concat(province, city) as region,
  register_date, member_level, phone, email
from dwd_user_final;
--验证
select count(*) from dwd_user_region;          -- 1000
select user_id, province, city, region from dwd_user_region limit 5;

--3 编码维度表
-- 会员等级维度
drop table if exists dim_member_level;
create table dim_member_level(
  level_name string
) row format delimited fields terminated by ',';
insert into dim_member_level values ('普通会员'),('银卡会员'),('金卡会员'),('钻石会员');

-- 支付方式维度
drop table if exists dim_pay_type;
create table dim_pay_type(
  pay_name string
) row format delimited fields terminated by ',';
insert into dim_pay_type values ('支付宝'),('微信支付'),('银行卡'),('货到付款');

-- 订单状态维度
drop table if exists dim_order_status;
create table dim_order_status(
  status_name string
) row format delimited fields terminated by ',';
insert into dim_order_status values ('待支付'),('已支付'),('已完成'),('已取消'),('退款中');

-- 渠道维度
drop table if exists dim_channel;
create table dim_channel(
  channel_name string
) row format delimited fields terminated by ',';
insert into dim_channel values ('APP'),('小程序'),('PC'),('门店');
--验证
select * from dim_member_level;
select * from dim_pay_type;
select * from dim_order_status;
select * from dim_channel;