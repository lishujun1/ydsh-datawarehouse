use ydsh_ods;

-- ① 按天+门店
drop table if exists dws_order_store_day;
create table dws_order_store_day stored as orc as
select store_id, order_date,
       round(sum(pay_amount),2) as gmv,
       count(distinct order_id) as orders,
       count(distinct user_id)  as users,
       round(sum(pay_amount)/count(distinct order_id),2) as aov
from dwd_order
where pay_amount is not null
group by store_id, order_date;

-- ② 按天+品类
drop table if exists dws_category_day;
create table dws_category_day stored as orc as
select p.category, o.order_date,
       round(sum(i.quantity * i.unit_price * (1 - coalesce(i.discount,0))),2) as sales,
       count(distinct o.order_id) as orders
from dwd_order_item i
join dwd_order o       on i.order_id = o.order_id
join dwd_dim_product p on i.product_id = p.product_id
where o.pay_amount is not null
group by p.category, o.order_date;

-- ③ 按天+渠道
drop table if exists dws_channel_day;
create table dws_channel_day stored as orc as
select channel, order_date,
       round(sum(pay_amount),2) gmv,
       count(distinct order_id) orders
from dwd_order
where pay_amount is not null
group by channel, order_date;

-- ④ 按月
drop table if exists dws_month;
create table dws_month stored as orc as
select substr(order_date,1,7) as month,
       round(sum(pay_amount),2) gmv,
       count(distinct order_id) orders,
       count(distinct user_id)  users
from dwd_order
where pay_amount is not null
group by substr(order_date,1,7);