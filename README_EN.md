# Yundu Life Retail Data Warehouse & Analytics System

A complete enterprise-grade data warehouse and business analytics system for a fictional new-retail company "Yundu Life".

## Overview

- **Data Scale**: 6 CSV tables, ~115,000 records, 5 types of dirty data injected for cleaning practice.
- **Architecture**: ODS → DWD → DWS → ADS four-layer data warehouse on Hive.
- **Analytics**: Core KPIs (GMV, orders, AOV, repurchase rate), time-series forecasting, NL2SQL question answering.
- **Visualization**: Apache Superset dashboard + ECharts data screen + Streamlit chatbot.

## Architecture

```
CSV → ODS → Clean → DWD → DWS → ADS → Analytics & AI → Visualization
```

## Features

- Data quality governance: missing/duplicate/abnormal/format/enum cleaning with before-after report.
- Dimensional modeling: 2 fact tables + 4 dimension tables (star schema).
- KPI computation: GMV 36.1M, 14,398 valid orders, AOV 2,508.45.
- Forecasting: Linear Regression (MAE 8,672.68, MAPE 9.26%) with documented boundaries.
- NL2SQL: natural language to Hive SQL via DeepSeek API + LangChain-style prompt.
- One-click deployment: `docker compose up -d`.

## Quick Start

```bash
cp .env.example .env
# fill in MYSQL_ROOT_PASSWORD / SUPERSET_SECRET_KEY / DEEPSEEK_API_KEY
docker compose up -d
python api_server.py        # ECharts dashboard: http://localhost:5000/dashboard
streamlit run streamlit_app.py  # chatbot: http://localhost:8501
```

## Tech Stack

Hive 4.0 / MySQL 8.0 / Python (pandas, scikit-learn) / DeepSeek API / Apache Superset / ECharts / Streamlit / Docker Compose / Git

## Core Metrics

| Metric | Value |
|---|---|
| GMV | 36,116,687.06 |
| Valid Orders | 14,398 |
| AOV | 2,508.45 |
| Active Users | 1,000 |
| Repurchase Rate | 100% (synthetic data feature) |

## Team

- Team: wbg
- Member: 厉姝君 (individual project, simulated team workflow via feature branches)

## Known Limitations

- Category sales use detail-line caliber, not additive with order-level GMV.
- order_status numeric codes 1/2/3/4 are inferred from dictionary examples, pending business confirmation.
- Dashboard uses offline snapshot data; production should query ADS tables directly.
