-- 切换数据库
use ydsh_ods;

-- 8. 导入数据 (确保你的compose挂载了 /data)
load data local inpath '/data/ods_user.csv' into table ods_user;
load data local inpath '/data/ods_product.csv' into table ods_product;
load data local inpath '/data/ods_store.csv' into table ods_store;
load data local inpath '/data/ods_order.csv' into table ods_order;
load data local inpath '/data/ods_order_item.csv' into table ods_order_item;
load data local inpath '/data/ods_user_behavior.csv' into table ods_user_behavior;

-- 9. 验证行数（必须和预期匹配：1000, 600, 60, 15600, 37549, 60000）
select 'ods_user' as table_name, count(*) as row_count from ods_user
union all select 'ods_product', count(*) from ods_product
union all select 'ods_store', count(*) from ods_store
union all select 'ods_order', count(*) from ods_order
union all select 'ods_order_item', count(*) from ods_order_item
union all select 'ods_user_behavior', count(*) from ods_user_behavior;