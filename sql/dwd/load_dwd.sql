use ydsh_ods;
--维度数据加载
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=1000;
set hive.exec.max.dynamic.partitions.pernode=1000;
-- 用户维度
insert overwrite table dwd_dim_user
select user_id, user_name, gender, age, city, province, region,
       register_date, member_level, phone, email
from dwd_user_region;

-- 商品维度（去空格+统一大写）
insert overwrite table dwd_dim_product
select product_id, trim(product_name),
       upper(trim(category)), upper(trim(sub_category)), upper(trim(brand)),
       price, cost, stock, status, launch_date
from ods_product;

-- 门店维度
insert overwrite table dwd_dim_store
select store_id, store_name, province, city, district, address,
       open_date, area, manager
from ods_store;

-- 日期维度（从订单日期生成）
insert overwrite table dwd_dim_date
select distinct
  order_date as date_key,
  cast(substr(order_date,1,4) as int) as year,
  cast(substr(order_date,6,2) as int) as month,
  cast(substr(order_date,9,2) as int) as day,
  cast(dayofweek(order_date) as int) as week
from dwd_order_ts
where order_date rlike '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';



-- 事实表动态分区加载
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;

-- 订单事实表
insert overwrite table dwd_order partition(order_date)
select order_id, user_id, store_id, order_timestamp,
       pay_amount, discount_amount, pay_type, order_status, channel,
       order_date
from dwd_order_ts;

-- 订单明细事实表（关联订单拿日期）
insert overwrite table dwd_order_item partition(order_date)
select i.item_id, i.order_id, i.product_id,
       i.quantity, i.unit_price, i.discount,
       o.order_date
from ods_order_item i
join dwd_order_ts o on i.order_id = o.order_id;

--验证
select count(*) from dwd_dim_user;      -- 1000
select count(*) from dwd_dim_product;   -- 600
select count(*) from dwd_dim_store;     -- 60
select count(*) from dwd_dim_date;      -- 日期去重数，约 200~300
select count(*) from dwd_order;         -- 15000
select count(*) from dwd_order_item;    -- 37549 左右

-- 分区验证
show partitions dwd_order;
show partitions dwd_order_item;

-- 分区裁剪验证
select count(*) from dwd_order where order_date='2024-04-12';