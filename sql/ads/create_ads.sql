use ydsh_ods;

-- ① 核心 KPI
drop table if exists ads_core_kpi;
create table ads_core_kpi stored as orc as
select round(sum(o.pay_amount),2)                         as gmv,
       count(distinct o.order_id)                         as order_cnt,
       round(sum(o.pay_amount)/count(distinct o.order_id),2) as aov,
       count(distinct o.user_id)                          as active_users,
       round(sum(case when u.cnt>=2 then 1 else 0 end)
             / count(distinct o.user_id), 4)              as repurchase_rate
from dwd_order o
join (select user_id, count(distinct order_id) cnt
      from dwd_order where pay_amount is not null group by user_id) u
  on o.user_id = u.user_id
where o.pay_amount is not null;

-- ② 销售日报
drop table if exists ads_sales_daily;
create table ads_sales_daily stored as orc as
select order_date, round(sum(gmv),2) gmv, sum(orders) orders
from dws_order_store_day
group by order_date order by order_date;

-- ③ 品类 Top10
drop table if exists ads_category_top10;
create table ads_category_top10 stored as orc as
select category, round(sum(sales),2) total_sales, sum(orders) orders
from dws_category_day
group by category order by total_sales desc limit 10;

-- ④ 用户价值分层
drop table if exists ads_user_value;
create table ads_user_value stored as orc as
select user_id,
       datediff(current_date, max(order_date)) recency,
       count(distinct order_id) frequency,
       round(sum(pay_amount),2) monetary,
       case when sum(pay_amount)>=5000 then '高价值'
            when sum(pay_amount)>=1000 then '中价值'
            else '低价值' end value_level
from dwd_order
where pay_amount is not null
group by user_id;