# 第 2 周 AI 协同日志

- 团队：wbg　成员：厉姝君　填写日期：2026-11-03

---

## 一、使用的 AI 工具 / 模型

- 工具名称：DeepSeek（对话式 AI 编程助手）　模型版本：DeepSeek-V3
- 辅助工具：Hive beeline 1.0、Docker Desktop、Git、Markdown 编辑器
- 说明：本周主要用 AI 辅助生成 Hive SQL、排查报错、梳理枚举映射与报告文案；所有 SQL 均在本地 Hive 环境实际运行验证后才采纳。

---

## 二、AI 协同记录表（至少 5 条）

| 序号 | 提问 / 任务描述 | AI 产出摘要 | 人工修改与验证 | 是否采纳 |
|------|----------------|-------------|----------------|----------|
| 1 | 第2周枚举字段标准化，需要扫描 gender、member_level、pay_type、order_status、channel、behavior_type 的现有取值并写 case when 映射 | 给出 `select distinct` 扫描 SQL + 通用 case when 映射模板 | 先跑扫描拿到真实取值（gender 8 种、member_level 12 种、pay_type 7 种、order_status 12 种、channel 6 种、behavior_type 10 种），发现模板未覆盖“钻石会员”，手动补分支后重跑 | 是（修改后采纳） |
| 2 | 初版枚举映射跑完后 channel“其他”占 47%、order_status“其他”占 36%，如何优化 | 建议回查 `select channel, count(*) from ods_order group by channel` 原始取值，逐一补映射分支，并给出去空格+统一大小写的写法 | 按建议回查，发现 app/pc 小写、PC官网、门店等未覆盖值，补全后重跑，6 字段“其他”全部归零 | 是 |
| 3 | 金额异常扫描用 `percentile(pay_amount, 0.99)` 报 NoMatchingMethodException，怎么办 | 定位 Hive UDAFPercentile 只接受 bigint 列，建议改用 `percentile_approx`（支持 double） | 改用 `percentile_approx` 拆成单条查询，成功拿到 P50=2502.52、P95=4833.65、P99=563 万、max=995.8 万 | 是 |
| 4 | 根据 P50/P95/P99/max 确定“超大金额”阈值，避免误删正常大额订单 | 指出 P99 被极值污染（563 万），建议用 P95≈4833 作参照，阈值定 10 万，并说明负金额+超大金额统一置 NULL 保留行数 | 人工复核 `pay_amount>100000` 的 302 条（min 50.1 万、max 995.8 万、均值 530.4 万），确认均为异常值，采纳 10 万阈值，最终 602 条置 NULL | 是 |
| 5 | 设计 DWD 层星型模型：订单事实表、订单明细事实表、用户/商品/门店/日期维度表，事实表按日期分区 | 给出 2 张事实表 + 4 张维度表 DDL（stored as orc、partitioned by order_date）和动态分区 ETL 脚本，含 `set hive.exec.dynamic.partition` 参数 | 本地执行 ETL，验证 6 张表行数（15000/37549/1000/600/60/366）、`show partitions` 366 个日分区、分区裁剪 `2024-04-12` 返回 60 条，全部通过 | 是 |
| 6 | 基于 DWD 层写探索性分析 SQL：核心 KPI、支付/状态/渠道/品类/门店/省份分布、窗口函数累计消费、月度 GMV 趋势、行为漏斗 | 给出 10 条分析 SQL，并提示品类 cnt 为明细行数口径、GMV 自动忽略 NULL 金额 | 逐条运行，KPI 得 GMV 3611.67 万、客单价 2407.78（含NULL）/2508.45（有效订单），补跑有效订单口径后写入简报 | 是 |

> 说明：以上 6 条均为真实提问与验证过程，AI 产出均经本地 Hive 实跑核对后才采纳；第 1 条因模板漏“钻石会员”做了人工修正，体现“AI 给框架、人工补业务细节”的协作方式。

---

## 三、AI 产出成果清单

- **由 AI 生成的内容（代码 / SQL / 文案）**：
  - `sql/clean/clean_enum.sql`（枚举标准化 case when 框架）
  - `sql/clean/clean_abnormal_format.sql`（日期/手机号/金额清洗框架）
  - `sql/clean/clean_concat_fields.sql`（order_timestamp、region 合并）
  - `sql/dwd/create_dwd.sql`、`load_dwd.sql`（维度/事实表 DDL + 动态分区 ETL）
  - `sql/ads/explore.sql`（10 条探索分析 SQL）
  - 《探索性分析简报》《数据质量对比报告》《数仓架构设计文档》初稿文案

- **由人工编写的内容**：
  - 枚举映射的真实取值分支补全（钻石会员、app/pc 小写、PC官网、门店等）
  - 金额阈值 10 万的业务判断与 302 条异常值复核
  - 各脚本在 Hive 中的实际运行、报错排查与结果验证
  - 报告中口径说明（GMV 忽略 NULL、品类 cnt 为明细行数）

- **人机协作完成的内容**：
  - 6 张 DWD 表的建模与加载（AI 给 DDL/ETL 框架，人工跑通并验证分区）
  - 探索性分析（AI 给 SQL，人工跑结果并提炼 5 条业务发现）
  - 三份报告（AI 给结构，人工填真实数字与结论）

---

## 四、问题与解决

- **遇到的问题**：
  1. `percentile(pay_amount, 0.99)` 报 `NoMatchingMethodException`（UDAFPercentile 只收 bigint）。
  2. 初版枚举映射“其他”占比过高（channel 47%、order_status 36%）。
  3. `dwd_dim_user` 验证时手滑打成 `dselect` 报 ParseException。
  4. `load_dwd.sql` 开头缺 `use ydsh_ods;`，重连后可能表不存在。

- **AI 是否有效解决**：
  1. 有效——定位为 UDAF 参数类型限制，改 `percentile_approx` 解决。
  2. 有效——建议回查原始 distinct 取值逐一补映射，重跑后“其他”归零。
  3. 部分有效——AI 指出是拼写错误，人工修正即可。
  4. 有效——AI 指出补 `use` 和动态分区上限参数，修正后脚本更稳。

- **最终如何解决**：
  报错类问题按 AI 定位改 SQL/脚本后本地重跑验证；业务类问题（枚举分支、金额阈值）由人工结合真实数据分布判断后采纳 AI 建议；所有修改均落到 `sql/` 目录并在 Hive 实跑通过。

---

## 五、反思与总结

- **AI 协同带来的价值**：
  大幅缩短 SQL 模板编写和报错排查时间，尤其动态分区 ETL、窗口函数、case when 框架这类“结构固定、细节易错”的代码，AI 给骨架、人工填业务，效率提升明显；报告文案也由 AI 先出结构，人工填数字，节省排版时间。

- **AI 的局限与风险（准确性 / 合规性 / 依赖）**：
  1. **准确性**：枚举映射不能凭空猜，AI 初版漏了“钻石会员”，必须基于真实 `select distinct` 结果补全；金额阈值也不能只看 P99（被极值污染），要结合 P95 和业务判断。
  2. **合规性**：模拟数据虽非真实用户数据，但手机号、邮箱等字段仍按脱敏原则处理，报告中不展示明细。
  3. **依赖**：AI 给的 SQL 必须本地实跑验证，不能直接贴进交付物；报错时 AI 能定位方向，但最终修复要人工确认。

- **本次协作中我的能力提升**：
  掌握了 Hive 枚举标准化、异常值阈值判断、动态分区表建模、窗口函数累计消费的写法；学会了“先扫描真实取值、再写映射”的数据治理方法；理解了 AI 产出必须经真实数据验证才能采纳的协作原则。

- **对 AI 协同的改进建议**：
  1. 提问时附上真实 `select distinct` 结果或报错全文，AI 给的映射/修复更准。
  2. 对 AI 给的阈值、映射分支保持怀疑，先用小查询验证再全量跑。
  3. 建立“AI 出框架 → 人工补业务 → 本地实跑验证 → 采纳”的固定流程，避免直接复制未验证代码。