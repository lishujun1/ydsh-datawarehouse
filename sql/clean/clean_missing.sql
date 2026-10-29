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

