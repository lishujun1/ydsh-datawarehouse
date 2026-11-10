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

def ask(prompt):
    resp = client.chat.completions.create(
        model="deepseek-chat",
        messages=[{"role":"user","content":prompt}], temperature=0.3)
    return resp.choices[0].message.content

# 1 异常归因
daily = pd.read_sql("select order_date, gmv from ads_sales_daily order by order_date", conn)
daily['chg'] = daily['gmv'].pct_change()
worst = daily.loc[daily['chg'].idxmin()]
channel = pd.read_sql("select channel, sum(gmv) gmv from dws_channel_day group by channel", conn).to_string()
cat = pd.read_sql("select * from ads_category_top10", conn).to_string()

q1 = f"""{worst['order_date']} 的GMV为 {worst['gmv']}，环比下降 {abs(worst['chg'])*100:.1f}%。
渠道数据：{channel}
品类数据：{cat}
请做异常归因分析，说明可能原因及局限。"""
print("===异常归因===\n", ask(q1))

# 2 经营摘要
kpi = pd.read_sql("select * from ads_core_kpi", conn).to_string()
q2 = f"""基于以下KPI数据生成经营分析摘要：
{kpi}
要求：只引用以上数字，不编造；结论文末注明数据来源。"""
print("===经营摘要===\n", ask(q2))