use ydsh_ods;
--第一段用户表清洗（日期 + 手机号）
drop table if exists dwd_user_final;
create table dwd_user_final as
select
  user_id, user_name, gender, age, city, province,
  -- 日期统一 yyyy-MM-dd：处理 2023/06/04、20241125 两种脏格式
  case
    when register_date rlike '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
      then regexp_replace(register_date, '/', '-')
    when register_date rlike '^[0-9]{8}$'
      then concat(substr(register_date,1,4),'-',substr(register_date,5,2),'-',substr(register_date,7,2))
    else register_date
  end as register_date,
  member_level,
  -- 手机号去分隔符，统一 11 位纯数字
  regexp_replace(phone, '[^0-9]', '') as phone,
  email
from dwd_user_enum;

--验证
-- 日期格式：应返回 0
select count(*) from dwd_user_final
where register_date not rlike '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- 手机号格式：应返回 0
select count(*) from dwd_user_final
where phone not rlike '^[0-9]{11}$';

-- 行数应仍为 1000
select count(*) from dwd_user_final;


--第二段订单表清洗（金额异常 + 日期格式）
use ydsh_ods;

drop table if exists dwd_order_final;
create table dwd_order_final as
select
  order_id, user_id, store_id,
  -- 订单日期统一 yyyy-MM-dd（处理斜杠格式）
  case
    when order_date rlike '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
      then regexp_replace(order_date, '/', '-')
    when order_date rlike '^[0-9]{8}$'
      then concat(substr(order_date,1,4),'-',substr(order_date,5,2),'-',substr(order_date,7,2))
    else order_date
  end as order_date,
  order_time,
  -- 金额异常处理：负金额或 > 10万 置 NULL；折扣同理
  case when pay_amount < 0 or pay_amount > 100000 then cast(null as double)
       else pay_amount end as pay_amount,
  case when discount_amount < 0 or discount_amount > 100000 then cast(null as double)
       else discount_amount end as discount_amount,
  pay_type, order_status, channel
from dwd_order_enum;

--验证
-- 负金额：应返回 0
select count(*) from dwd_order_final where pay_amount < 0;

-- 超大金额：应返回 0
select count(*) from dwd_order_final where pay_amount > 100000;

-- 金额为 NULL 的条数（= 300 负 + 超大数，记录到报告）
select count(*) from dwd_order_final where pay_amount is null;

-- 日期格式：应返回 0
select count(*) from dwd_order_final
where order_date not rlike '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- 行数应仍为 15000
select count(*) from dwd_order_final;



--第三段行为表清洗（时间格式）
use ydsh_ods;

drop table if exists dwd_behavior_final;
create table dwd_behavior_final as
select
  behavior_id, user_id, product_id, behavior_type,
  -- 行为时间统一 yyyy-MM-dd HH:mm:ss：
  -- 处理 2024/11/14 00:13（斜杠+缺秒）和 2024-11-14 00:13:05（标准）
  case
    when behavior_time rlike '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$'
      then concat(regexp_replace(substr(behavior_time,1,10), '/', '-'),
                  substr(behavior_time,11), ':00')
    when behavior_time rlike '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
      then regexp_replace(substr(behavior_time,1,10), '/', '-') || substr(behavior_time,11)
    when behavior_time rlike '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$'
      then concat(behavior_time, ':00')
    else behavior_time
  end as behavior_time,
  session_id
from dwd_behavior_enum;
--验证
-- 时间格式：应返回 0
select count(*) from dwd_behavior_final
where behavior_time not rlike '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$';

-- 行数应仍为 60000
select count(*) from dwd_behavior_final;
