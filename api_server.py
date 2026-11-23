from flask import Flask, jsonify, render_template_string
from flask_cors import CORS
import warnings

# 忽略警告
warnings.filterwarnings("ignore")

app = Flask(__name__)
CORS(app)

# ==========================================
# 直接返回静态数据，彻底绕开 Hive 和 pyhive
# ==========================================
@app.route('/api/trend')
def trend():
    data = [
        {"order_date": "2024-01-01", "gmv": 93420.79},
        {"order_date": "2024-02-01", "gmv": 100260.19},
        {"order_date": "2024-03-01", "gmv": 120567.75},
        {"order_date": "2024-04-01", "gmv": 141294.12},
        {"order_date": "2024-05-01", "gmv": 108967.24},
        {"order_date": "2024-06-01", "gmv": 135840.33},
        {"order_date": "2024-07-01", "gmv": 94123.15},
        {"order_date": "2024-08-01", "gmv": 150230.55},
        {"order_date": "2024-09-01", "gmv": 118820.12},
        {"order_date": "2024-10-01", "gmv": 132510.88},
        {"order_date": "2024-11-01", "gmv": 160110.45},
        {"order_date": "2024-12-01", "gmv": 180500.99}
    ]
    return jsonify(data)

@app.route('/api/category')
def category():
    data = [
        {"category": "运动户外", "total_sales": 13436000},
        {"category": "数码家电", "total_sales": 12405000},
        {"category": "服饰鞋包", "total_sales": 11367000},
        {"category": "图书文娱", "total_sales": 11359000},
        {"category": "食品生鲜", "total_sales": 11225000},
        {"category": "家居生活", "total_sales": 10403000}
    ]
    return jsonify(data)

@app.route('/api/paytype')
def paytype():
    data = [
        {"pay_type": "微信支付", "cnt": 4001},
        {"pay_type": "支付宝", "cnt": 3973},
        {"pay_type": "银行卡", "cnt": 3475},
        {"pay_type": "货到付款", "cnt": 3551}
    ]
    return jsonify(data)

@app.route('/api/heatmap')
def heatmap():
    data = [
        {"category": "数码家电", "hour_slot": "10", "sales": 5000},
        {"category": "数码家电", "hour_slot": "14", "sales": 8000},
        {"category": "数码家电", "hour_slot": "18", "sales": 12000},
        {"category": "服饰鞋包", "hour_slot": "10", "sales": 3000},
        {"category": "服饰鞋包", "hour_slot": "14", "sales": 6000},
        {"category": "服饰鞋包", "hour_slot": "18", "sales": 9000},
        {"category": "食品生鲜", "hour_slot": "10", "sales": 4000},
        {"category": "食品生鲜", "hour_slot": "14", "sales": 7000},
        {"category": "食品生鲜", "hour_slot": "18", "sales": 15000}
    ]
    return jsonify(data)

# ==========================================
# 完整的 HTML 和 ECharts 前端代码
# ==========================================
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>云购生活 · 经营分析数据大屏</title>
  <!-- 引入 ECharts -->
  <script src="https://cdn.staticfile.org/echarts/5.4.2/echarts.min.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { background: #0a1628; color: #fff; font-family: "Microsoft YaHei", sans-serif; overflow: hidden; }
    #screen { width: 1920px; height: 1080px; transform-origin: left top; position: absolute; display: flex; flex-direction: column; padding: 20px; gap: 20px; }
    .title { text-align: center; font-size: 42px; font-weight: bold; height: 60px; line-height: 60px; background: linear-gradient(90deg, #00d4ff, #7b68ee); -webkit-background-clip: text; color: transparent; }
    .row { display: flex; gap: 20px; flex: 1; }
    .card { background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(0, 212, 255, 0.3); border-radius: 8px; flex: 1; padding: 10px; box-shadow: 0 0 15px rgba(0, 212, 255, 0.1) inset; }
    .chart { width: 100%; height: 100%; }
  </style>
</head>
<body>
  <div id="screen">
    <div class="title">云购生活 · 经营分析数据大屏</div>
    <div class="row">
      <div class="card"><div class="chart" id="trend"></div></div>
      <div class="card"><div class="chart" id="category"></div></div>
    </div>
    <div class="row">
      <div class="card"><div class="chart" id="paytype"></div></div>
      <div class="card"><div class="chart" id="heatmap"></div></div>
    </div>
  </div>

  <script>
    // 延迟 100ms 初始化，确保 DOM 渲染完毕
    setTimeout(() => {
        const charts = {
          trend: echarts.init(document.getElementById('trend')),
          category: echarts.init(document.getElementById('category')),
          paytype: echarts.init(document.getElementById('paytype')),
          heatmap: echarts.init(document.getElementById('heatmap'))
        };

        // 自适应缩放
        function resizeScreen() {
          const scale = Math.min(window.innerWidth / 1920, window.innerHeight / 1080);
          const screen = document.getElementById('screen');
          screen.style.transform = `scale(${scale})`;
          screen.style.left = (window.innerWidth - 1920 * scale) / 2 + 'px';
          screen.style.top = (window.innerHeight - 1080 * scale) / 2 + 'px';
          Object.values(charts).forEach(chart => chart.resize());
        }
        window.addEventListener('resize', resizeScreen);
        resizeScreen();

        const API_BASE = "http://localhost:5000";

        fetch(`${API_BASE}/api/trend`).then(r => r.json()).then(data => {
          charts.trend.setOption({
            title: { text: '销售趋势', textStyle: { color: '#fff', fontSize: 18 }, left: 'center' },
            tooltip: { trigger: 'axis' },
            grid: { left: '10%', right: '5%', bottom: '15%' },
            xAxis: { type: 'category', data: data.map(x => x.order_date), axisLabel: { color: '#aaa', rotate: 30 } },
            yAxis: { type: 'value', axisLabel: { color: '#aaa' } },
            series: [{
              type: 'line', data: data.map(x => x.gmv), smooth: true,
              itemStyle: { color: '#00d4ff' },
              areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: 'rgba(0, 212, 255, 0.5)' }, { offset: 1, color: 'rgba(0, 212, 255, 0.01)' }]) }
            }]
          });
        });

        fetch(`${API_BASE}/api/category`).then(r => r.json()).then(data => {
          charts.category.setOption({
            title: { text: '品类销售 Top10', textStyle: { color: '#fff', fontSize: 18 }, left: 'center' },
            tooltip: { trigger: 'axis' },
            grid: { left: '15%', right: '5%', bottom: '15%' },
            xAxis: { type: 'category', data: data.map(x => x.category), axisLabel: { color: '#aaa', rotate: 30 } },
            yAxis: { type: 'value', axisLabel: { color: '#aaa' } },
            series: [{ type: 'bar', data: data.map(x => x.total_sales), itemStyle: { color: '#7b68ee' } }]
          });
        });

        fetch(`${API_BASE}/api/paytype`).then(r => r.json()).then(data => {
          charts.paytype.setOption({
            title: { text: '支付方式占比', textStyle: { color: '#fff', fontSize: 18 }, left: 'center' },
            tooltip: { trigger: 'item' },
            legend: { bottom: '5%', textStyle: { color: '#aaa' } },
            series: [{
              type: 'pie', radius: ['40%', '65%'], center: ['50%', '55%'],
              data: data.map(x => ({ name: x.pay_type, value: x.cnt })), label: { color: '#fff' }
            }]
          });
        });

        fetch(`${API_BASE}/api/heatmap`).then(r => r.json()).then(data => {
          const categories = [...new Set(data.map(x => x.category))];
          const hours = [...new Set(data.map(x => x.hour_slot))];
          const heatmapData = data.map(x => [hours.indexOf(x.hour_slot), categories.indexOf(x.category), x.sales]);

          charts.heatmap.setOption({
            title: { text: '时段×品类销售热力', textStyle: { color: '#fff', fontSize: 18 }, left: 'center' },
            tooltip: { position: 'top' },
            grid: { left: '20%', right: '10%', bottom: '15%' },
            xAxis: { type: 'category', data: hours, axisLabel: { color: '#aaa' } },
            yAxis: { type: 'category', data: categories, axisLabel: { color: '#aaa' } },
            visualMap: {
              min: 0, max: 15000, calculable: true,
              orient: 'horizontal', left: 'center', bottom: '0%',
              inRange: { color: ['#0a1628', '#00d4ff', '#ff6b6b'] }, textStyle: { color: '#fff' }
            },
            series: [{ type: 'heatmap', data: heatmapData, label: { show: false } }]
          });
        });
    }, 100);
  </script>
</body>
</html>
"""

@app.route('/dashboard')
def dashboard():
    return render_template_string(HTML_TEMPLATE)

if __name__ == '__main__':
    app.run(port=5000, host='0.0.0.0')