--1 核心 KPI
use ydsh_ods;

select
  count(distinct order_id) as order_cnt,
  count(distinct user_id) as user_cnt,
  round(sum(pay_amount),2) as gmv,
  round(sum(pay_amount)/count(distinct order_id),2) as avg_order_amt,
  round(sum(pay_amount)/count(distinct user_id),2) as arpu
from dwd_order;

--2 多维分布
-- 支付方式分布
select pay_type, count(*) cnt, round(sum(pay_amount),2) gmv
from dwd_order group by pay_type order by gmv desc;

-- 订单状态分布
select order_status, count(*) cnt
from dwd_order group by order_status order by cnt desc;

-- 渠道分布
select channel, count(*) cnt, round(sum(pay_amount),2) gmv
from dwd_order group by channel order by gmv desc;

-- 品类销售分布
select p.category, count(*) cnt, round(sum(o.pay_amount),2) sales
from dwd_order_item i
join dwd_order o on i.order_id = o.order_id
join dwd_dim_product p on i.product_id = p.product_id
group by p.category order by sales desc;

-- 门店销售排行
select s.store_name, count(*) cnt, round(sum(o.pay_amount),2) sales
from dwd_order o join dwd_dim_store s on o.store_id = s.store_id
group by s.store_name order by sales desc limit 10;

-- 省份销售分布
select u.province, round(sum(o.pay_amount),2) sales
from dwd_order o join dwd_dim_user u on o.user_id = u.user_id
group by u.province order by sales desc;

--3 窗口函数：用户累计消费
select user_id, order_date, pay_amount,
  sum(pay_amount) over(partition by user_id order by order_date) as cum_amount,
  row_number() over(partition by user_id order by order_date) as rn
from dwd_order
where pay_amount is not null
order by user_id, order_date
limit 20;




--4 月度 GMV 趋势（写简报用）
select substr(order_date,1,7) as month,
       count(*) order_cnt,
       round(sum(pay_amount),2) gmv
from dwd_order
group by substr(order_date,1,7)
order by month;

--5 用户行为漏斗（写简报用） 品类 cnt 为订单商品明细行数，一个订单可包含多个商品明细。
select behavior_type, count(*) cnt
from dwd_behavior_final group by behavior_type order by cnt desc;


-- 有效订单客单价（只算有金额的订单）
select round(sum(pay_amount)/count(*),2) as avg_amt_valid
from dwd_order where pay_amount is not null;