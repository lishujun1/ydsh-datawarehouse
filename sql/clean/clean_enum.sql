use ydsh_ods;

-- ========== 1. 用户枚举标准化（补钻石会员） ==========
drop table if exists dwd_user_enum;
create table dwd_user_enum as
select user_id, user_name,
  case when gender in ('男','M','male','Male') then '男'
       when gender in ('女','F','female','Female') then '女'
       else '未知' end as gender,
  age, city, province, register_date,
  case when member_level in ('钻石会员','钻石','diamond','Diamond') then '钻石会员'
       when member_level in ('金卡会员','金卡','gold','Gold') then '金卡会员'
       when member_level in ('银卡会员','银卡','silver','Silver') then '银卡会员'
       when member_level in ('普通会员','普通','normal','Normal') then '普通会员'
       else '普通会员' end as member_level,   -- 空值14条归普通会员
  phone, email
from dwd_user;

-- ========== 2. 订单枚举标准化（补 channel/status/pay_type） ==========
drop table if exists dwd_order_enum;
create table dwd_order_enum as
select order_id, user_id, store_id, order_date, order_time,
  pay_amount, discount_amount,
  case when pay_type in ('微信支付','微信','wechat','WeChat') then '微信支付'
       when pay_type in ('支付宝','alipay','AliPay') then '支付宝'
       when pay_type in ('银行卡','card','Card') then '银行卡'
       when pay_type in ('货到付款','cod','COD') then '货到付款'
       else '其他' end as pay_type,
  case when order_status in ('已完成','完成','completed') then '已完成'
       when order_status in ('已支付','已付款','2') then '已支付'      -- 2=已支付，按字典确认
       when order_status in ('待支付','1') then '待支付'              -- 1=待支付
       when order_status in ('已取消','cancelled','Cancelled','4') then '已取消'  -- 4=已取消
       when order_status in ('退款中','3') then '退款中'              -- 3=退款中，按字典确认
       else '其他' end as order_status,
  case when upper(trim(channel)) in ('APP') then 'APP'
       when trim(channel) in ('小程序','miniapp') then '小程序'
       when upper(trim(channel)) in ('PC官网','PC','PC-WEB') then 'PC'
       when trim(channel) in ('门店','线下','store') then '门店'
       else '其他' end as channel
from dwd_order;

-- ========== 3. 行为类型标准化（补 fav/收藏） ==========
drop table if exists dwd_behavior_enum;
create table dwd_behavior_enum as
select behavior_id, user_id, product_id,
  case when upper(trim(behavior_type)) in ('PV','浏览') then '浏览'
       when upper(trim(behavior_type)) in ('BUY','购买') then '购买'
       when upper(trim(behavior_type)) in ('CART','加购') then '加购'
       when upper(trim(behavior_type)) in ('FAV','收藏') then '收藏'
       else '其他' end as behavior_type,
  behavior_time, session_id
from ods_user_behavior;