from pyhive import hive
import pandas as pd, numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, mean_absolute_percentage_error
from xgboost import XGBRegressor
from statsmodels.tsa.seasonal import seasonal_decompose
import matplotlib.pyplot as plt

conn = hive.Connection(host='localhost', port=10000, database='ydsh_ods')
df = pd.read_sql("select order_date, gmv from ads_sales_daily order by order_date", conn)
df['order_date'] = pd.to_datetime(df['order_date'])
df = df.set_index('order_date').sort_index()

df['ma7']  = df['gmv'].rolling(7).mean()
df['ma30'] = df['gmv'].rolling(30).mean()
df['mom']  = df['gmv'].pct_change()

decomp = seasonal_decompose(df['gmv'].dropna(), model='additive', period=7)
decomp.plot()
plt.savefig('reports/trend_decompose.png')

d = df.copy()
d['lag1'] = d['gmv'].shift(1)
d['lag7'] = d['gmv'].shift(7)
d['ma7']  = d['gmv'].rolling(7).mean()
d = d.dropna()
X = d[['lag1','lag7','ma7']]; y = d['gmv']

split = len(d)-14
Xtr,Xte = X.iloc[:split],X.iloc[split:]
ytr,yte = y.iloc[:split],y.iloc[split:]

results = {}
models = {
  "Linear": LinearRegression(),
  "XGB": XGBRegressor(n_estimators=200, max_depth=3, learning_rate=0.1)
}
for name, m in models.items():
    m.fit(Xtr,ytr); p = m.predict(Xte)
    mae  = mean_absolute_error(yte,p)
    mape = mean_absolute_percentage_error(yte,p)
    results[name] = (mae, mape, m)
    print(f"{name}: MAE={mae:.2f}, MAPE={mape:.4f}")

best_name  = min(results, key=lambda k: results[k][1])
best_model = results[best_name][2]
print("选用模型:", best_name)

def forecast(model, hist, days=7):
    hist = list(hist); out=[]
    for _ in range(days):
        lag1=hist[-1]; lag7=hist[-7]; ma7=np.mean(hist[-7:])
        p=model.predict([[lag1,lag7,ma7]])[0]
        out.append(round(float(p),2)); hist.append(p)
    return out

print("未来7天GMV预测:", forecast(best_model, d['gmv'].values))