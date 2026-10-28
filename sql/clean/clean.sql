-- 步骤8
-- 1. 算一下平均年龄 (假设算出来是 35.5)
select avg(age) from ods_user where age is not null and age between 1 and 120;

-- 2. 创建清洗后的目标表 dwd_user
create table if not exists dwd_user as
select 
  user_id, user_name, gender,
  -- 如果年龄为空、负数或超过120，用35.5填充 (请把35.5换成你上一步算出的真实值)
  case when age is null or age < 0 or age > 120 then cast(35.5 as int) else age end as age,
  city, province, register_date, member_level, phone, email
from ods_user;

-- 3. 验证是否还有异常年龄
select count(*) from dwd_user where age is null or age < 0 or age > 120; 
-- 结果应该是 0

-- 步骤9
-- 1. 统计去重前的总行数 (预期 15600+)
select count(*) from ods_order;

-- 2. 统计有重复的 order_id 数量
select count(distinct order_id) from ods_order;

-- 3. 使用窗口函数去重，生成 dwd_order 表
create table if not exists dwd_order as
select order_id, user_id, store_id, order_date, order_time,
       pay_amount, discount_amount, pay_type, order_status, channel
from (
  select *, 
         row_number() over(partition by order_id order by order_time desc) as rn
  from ods_order
) t 
where rn = 1;

-- 4. 验证去重后的总行数 (预期应该等于 distinct order_id 的数量)
select count(*) from dwd_order;

-- 5. 再次验证 dwd_order 里是否还有重复的 order_id (应该返回 0 行)
select order_id, count(*) from dwd_order group by order_id having count(*) > 1;

