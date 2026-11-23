# 云购生活数据仓库项目

## 团队信息
- 队名：wbg
- 成员：厉姝君
- 口号：做大做强，再创辉煌！

## 角色分工
- 项目经理：厉姝君
- 数据工程师：厉姝君
- 数据分析师：厉姝君
- 可视化工程师：厉姝君

> 说明：本项目为个人独立完成，采用同仓库功能分支模拟团队协作流程，详见 `Git协同记录.md`。

## 项目目标
构建 ODS → DWD → DWS → ADS 四层数仓 + 可视化系统，覆盖数据采集、清洗、建模、分析、预测、NL2SQL 智能问数、大屏可视化全链路。

## 技术栈
Docker + Hive 4.0 + MySQL 8.0 + Python（pandas/scikit-learn）+ DeepSeek API + Apache Superset + ECharts + Streamlit + Git

## 目录结构

```
ydsh-datawarehouse/
├── docker-compose.yml                # 一键部署编排
├── Dockerfile                        # 自定义镜像（如 Superset 预装依赖）
├── .env.example                      # 环境变量模板
├── .env                              # 本地真实环境变量（不入 Git）
├── superset_config.py                # Superset 配置
├── mysql-connector-java-8.0.28.jar   # JDBC 驱动（手动放置）
├── requirements.txt                  # Python 依赖
├── README.md                         # 本文件
├── 部署手册.md                        # 部署与 API 配置指南
├── API配置指南.md                     # 大模型 API 配置
├── 压力测试记录.md                    # 压测记录
├── 数仓架构设计文档.docx              # 四层架构设计
├── 数据质量对比报告.docx              # 清洗前后质量对比
├── 数据质量预评估表.xlsx              # 五维度预评估
├── 探索性分析简报.docx                # EDA 简报
├── wbg_第1周_AI协同日志.md            # 第1周 AI 协同日志
├── 第2周_AI协同日志.md                # 第2周 AI 协同日志
├── 模拟数据/                          # 6 个 CSV（不入 Git，需单独获取）
│   ├── ods_user.csv
│   ├── ods_product.csv
│   ├── ods_store.csv
│   ├── ods_order.csv
│   ├── ods_order_item.csv
│   └── ods_user_behavior.csv
├── sql/
│   ├── ods/     create_ods.sql, load_ods.sql
│   ├── clean/   clean_missing → clean_duplicate → clean_enum → clean_abnormal_format → clean_concat_fields
│   ├── dwd/     create_dwd.sql, load_dwd.sql
│   ├── dws/     create_dws.sql
│   └── ads/     create_ads.sql, explore.sql
├── src/                              # 分析与建模脚本
│   ├── ai_insight.py
│   ├── predict.py
│   └── llm_test.py
├── api_server.py                     # Flask 大屏服务（根目录）
├── nl2sql.py                         # NL2SQL 入口（根目录）
├── streamlit_app.py                  # Streamlit 问数（根目录）
├── stress_test.py                    # 压力测试脚本
├── index.html                        # ECharts 大屏页面
├── echarts.min.js                    # 离线 ECharts 库
├── dashboard/                        # 大屏前端资源
├── docs/                             # 文档
│   ├── Git协同记录.md
│   ├── 指标定义.md
│   └── 环境搭建笔记.md
├── reports/                          # 分析报告
│   ├── AI智能洞察报告.md
│   ├── 预测建模分析报告.md
│   ├── AI应用反思.md
│   ├── 答辩Q&A.md
│   └── trend_decompose.png
└── superset_home/                    # Superset 持久化目录
    └── superset.db
```

## 快速启动

```bash
# 1. 配置环境变量
copy .env.example .env
# 编辑 .env，填入 MYSQL_ROOT_PASSWORD / SUPERSET_SECRET_KEY / DEEPSEEK_API_KEY

# 2. 放置 JDBC 驱动到根目录
# mysql-connector-java-8.0.28.jar

# 3. 启动容器
docker compose up -d
docker ps   # 确认 mysql / hive-metastore / hive-server / superset 均为 Up

# 4. 按顺序执行 SQL（详见 部署手册.md 第四节）
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000

# 5. 启动前端
python api_server.py               # ECharts 大屏 http://localhost:5000/dashboard
streamlit run streamlit_app.py     # 智能问数 http://localhost:8501
```

## Superset 访问

- 地址：http://localhost:8088
- 账号：admin
- 密码：admin123

## 数据说明

- 模拟数据集共 6 张 CSV，约 11.5 万条，刻意植入五类脏数据（缺失、重复、异常、格式不一致、业务逻辑错误）。
- `.gitignore` 忽略 `*.csv`，clone 后需单独获取数据放入 `模拟数据/` 目录。
- 数据时间范围：2024-01-01 至 2024-12-31。
- MySQL 宿主机端口为 **3307**（容器内 3306），连接串用 `localhost:3307`。

## 核心指标（ADS 层）

| 指标 | 值 | 说明 |
|---|---|---|
| GMV | 36,116,687.06 | 有效订单实付金额之和 |
| 订单量 | 14,398 | 去重订单数 |
| 客单价 | 2,508.45 | GMV ÷ 订单量 |
| 活跃用户 | 1,000 | 有下单行为的去重用户 |
| 复购率 | 100% | 模拟数据人均 14.4 单，属构造特征 |

## 阶段计划
- 第1周：环境 / 数据导入 / 清洗（一）
- 第2周：清洗进阶 / 数仓建模 / 探索分析
- 第3周：分析 / 预测 / AI协同
- 第4周：可视化 / 部署
- 第5周：整合 / 文档 / 答辩

## 已知局限
- 品类销售额为明细行口径，与订单口径 GMV 不可加总，详见 `docs/指标定义.md`；
- order_status 数字编码 1/2/3/4 按字典示例推断，待业务方确认；
- api_server.py 大屏为 mock 数据，生产应改直连 ADS 表。

详见 `reports/答辩Q&A.md` 第 12 条。