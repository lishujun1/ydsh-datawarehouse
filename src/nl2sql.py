import os
import warnings
from dotenv import load_dotenv
from openai import OpenAI
from pyhive import hive
import pandas as pd

warnings.filterwarnings("ignore", category=UserWarning, module="pandas")

load_dotenv()
client = OpenAI(api_key=os.environ["DEEPSEEK_API_KEY"],
                base_url="https://api.deepseek.com")
conn = hive.Connection(host='localhost', port=10000, database='ydsh_ods')

tables = {
 "dwd_order":         "订单事实(order_id,user_id,store_id,pay_amount,order_date,channel,order_status)。"
                      "order_status 取值：'待支付','已支付','已完成','已取消','退款中'；"
                      "channel 取值：'APP','小程序','PC','门店'；"
                      "order_date 格式 'yyyy-MM-dd'，数据范围 2024-01-01 至 2024-12-31",
 "dwd_order_item":    "订单明细(item_id,order_id,product_id,quantity,unit_price,discount)",
 "dwd_dim_product":   "商品维度(product_id,category,sub_category,brand,price)",
 "dwd_dim_store":     "门店维度(store_id,province,city,store_name)",
 "dwd_dim_user":      "用户维度(user_id,province,city,member_level)",
 "ads_sales_daily":   "销售日报(order_date,gmv,orders)",
 "ads_category_top10":"品类Top10(category,total_sales,orders)",
}
schema_desc = "\n".join(f"{k}: {v}" for k,v in tables.items())

PROMPT = """你是 Hive SQL 专家。可用表：
{schema}
规则：
1. 只生成 SELECT，禁止 INSERT/UPDATE/DELETE；
2. 字段名必须来自 Schema，不要编造字段；
3. 字符串常量必须用单引号包裹，如 '广东省'；
4. 取某月第一天用 trunc(日期,'MM')，禁止使用 date_format(日期,'yyyy-MM-01')；
5. 涉及订单状态时使用中文枚举值（如 '已支付'、'已完成'），不要使用 'paid' 等英文值；
6. 复购率 = 下单≥2次的用户数 ÷ 下单用户数，不要按订单状态过滤；
7. 只输出一条 SQL，不要输出解释。
示例：
问：2024年4月广东省销售额
答：select round(sum(o.pay_amount),2) from dwd_order o
    join dwd_dim_store s on o.store_id=s.store_id
    where s.province='广东省'
      and o.order_date >= '2024-04-01'
      and o.order_date <  '2024-05-01'
问：销量最高的前5个品类
答：select category, round(sum(total_sales),2) s from ads_category_top10
    group by category order by s desc limit 5
问题：{question}
"""

def fix_sql(sql: str) -> str:
    """兜底修正模型可能生成的 Hive 不兼容写法"""
    sql = sql.replace("date_format(add_months(current_date,-1),'yyyy-MM-01')",
                      "trunc(add_months(current_date,-1),'MM')")
    sql = sql.replace("date_format(current_date,'yyyy-MM-01')",
                      "trunc(current_date,'MM')")
    sql = sql.replace("'paid'", "'已支付'")
    sql = sql.replace("'completed'", "'已完成'")
    return sql

def nl2sql(question):
    resp = client.chat.completions.create(
        model="deepseek-chat",
        messages=[{"role":"user","content":PROMPT.format(schema=schema_desc, question=question)}],
        temperature=0)
    sql = resp.choices[0].message.content.strip()
    sql = sql.replace("```sql","").replace("```","").strip()
    sql = fix_sql(sql)
    sql = sql.rstrip(";").strip()
    assert sql.lower().startswith("select"), "拒绝非查询语句"
    return sql, pd.read_sql(sql, conn)

if __name__ == "__main__":
    questions = [
        "2024年4月广东省销售额是多少？",
        "销量最高的前5个品类",
        "各渠道GMV分布",
        "复购率是多少",
    ]
    for q in questions:
        print("=" * 60)
        print("Q:", q)
        try:
            sql, res = nl2sql(q)
            print("SQL:", sql)
            print(res.head(), "\n")
        except Exception as e:
            print("执行失败:", e, "\n")

# main branch edit - 主分支修改
# main branch edit
