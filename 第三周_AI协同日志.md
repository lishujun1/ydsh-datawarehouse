# 第 3 周 AI 协同日志

- 团队：云购生活数仓小组　成员：李书君（单人项目）　填写日期：2026-11-12

---

## 一、使用的 AI 工具 / 模型

- 工具名称：DeepSeek Chat / ChatGPT 
- 模型版本：deepseek-chat（API）、GPT-4o
- （主要用于：Hive/Spark 环境排错、Python 预测脚本联调、NL2SQL Prompt 设计、报告润色）

---

## 二、AI 协同记录表（至少 5 条）

| 序号 | 提问 / 任务描述 | AI 产出摘要 | 人工修改与验证 | 是否采纳 |
|------|----------------|-------------|----------------|----------|
| 1 | HiveServer2 启动失败，报错 `+ : derby` 或 `ClassNotFoundException: com.mysql.cj.jdbc.Driver`，以及 `Input path does not exist`。 | AI 诊断出官方 `apache/hive:4.0.0` 镜像未内置 MySQL 驱动，且 Docker 卷映射未配置好导致数据文件找不到。给出了挂载 `mysql-connector-java.jar` 和修改 `docker-compose.yml` 的完整方案。 | 人工在 `docker-compose.yml` 的 `hive-metastore` 和 `hive-server` 服务中新增了 `./mysql-connector-java-8.0.28.jar:/opt/hive/lib/...` 的卷映射。重启容器后成功连上 MySQL，并查出了 33 张表。 | 是 |
| 2 | 使用 Python 的 `openai` 库调用大模型时，报错 `No matching distribution found for jiter<1,>=0.10.0`（因 Python 3.8 兼容性问题）。 | AI 指出是 `openai` 最新版（v2.7.1）不再支持 Python 3.8，并给出了降级安装 `openai==1.6.1` 的解决方案，同时修正了依赖库安装命令。 | 人工执行 `python -m pip install "openai==1.6.1"`，成功安装，并通过验证脚本调用 DeepSeek API 返回“你好”，确认环境连通。 | 是 |
| 3 | 用 PyHive 执行 NL2SQL 生成的 SQL 报错 `ParseException line 5:59 cannot recognize input near ')'`。 | AI 指出这是因为 Prompt 引导大模型生成了 Hive 4.0 不兼容的日期函数 `date_format(...,'yyyy-MM-01')`。AI 给出了改用 `trunc(add_months(current_date,-1),'MM')` 的新 Prompt，并加了执行前的正则替换兜底。 | 人工修改了 `src/nl2sql.py` 中的 Prompt 规则，在规则中明确“字符串用单引号”、“取月初用 trunc”。重跑后，4 个测试问题（如“2024年4月广东省销售额”）均生成可执行 SQL 并返回正确结果。 | 是 |
| 4 | Python 时间序列预测脚本报错 `FileNotFoundError: 'reports/trend_decompose.png'`，以及模型警告 `X does not have valid feature names`。 | AI 指出当前工作目录缺少 `reports` 文件夹，导致 `plt.savefig` 失败；同时给出了在代码顶部添加 `matplotlib.rcParams['font.sans-serif'] = ['SimHei']` 以解决中文乱码的方法。 | 人工在宿主机执行 `mkdir reports` 和 `mkdir docs`，并在脚本头部增加字体设置。重新运行后成功生成带有中文标签的趋势分解图。对比了 Linear 和 XGBoost 的误差，并采纳了 MAPE 更低的线性回归模型。 | 是 |
| 5 | 提交代码至 Git 时，GitHub 的 PR（Pull Request）页面找不到要修改的 `.md` 文件，或者显示 `Can't automatically merge` 冲突。 | AI 分析因为相关文件在两个分支的早期 commit 里已经合并过了，所以 PR 里不显示差异；然后指导在本地补充了 `<-- 补充复购率说明 -->` 的注释，重新 push 触发 PR；同时给出了本地解决 `nl2sql.py` 冲突的具体 Git 命令。 | 人工执行 `git add` 和 `git commit`，并在本地保留了合并后的有效代码，执行 `fix: 解决 nl2sql.py 合并冲突`，最终成功推送并合并 PR。 | 是 |

> 说明：请逐条记录「问了什么 → AI 给出什么 → 我改了/验证了什么 → 最终用没用」。这一步是评分重点，务必真实、具体。

---

## 三、AI 产出成果清单

- **由 AI 生成的内容**：
  - `docker-compose.yml` 修复方案（MySQL 驱动挂载）；
  - `src/predict.py` 中的时间序列特征工程与 XGBoost/Linear 模型对比代码；
  - `src/nl2sql.py` 中的 Prompt 模板（含 few-shot）及安全校验逻辑；
  - 《预测建模分析报告》的初始框架与《AI应用反思》大纲。
- **由人工编写的内容**：
  - 大部分 Hive SQL 脚本（ODS 建表、DWD 清洗、DWS/ADS 建表）；
  - `src/ai_insight.py` 中具体的异常归因数据拼接与 Prompt 构造；
  - `docs/Git协同记录.md` 的协同实操记录。
- **人机协作完成的内容**：
  - 排错过程：AI 报错定位 + 人工环境验证；
  - `src/nl2sql.py` 的 Prompt 调优（多次迭代）；
  - 业务指标口径的确认与修正。

---

## 四、问题与解决

- **遇到的问题**：
  1. 误执行了 `docker compose up -d --force-recreate`，导致 Hive 容器内的未挂载数据丢失。
  2. 更换官方 Hive 镜像后，缺少 MySQL JDBC 驱动，导致 Metastore 起不来，数据“假死”。
  3. NL2SQL 生成的 Hive SQL 存在方言兼容性问题（日期函数错误）。
- **AI 是否有效解决**：是。AI 准确识别出了“数据丢失是因为没挂载卷”以及“报 Derby 错是因为缺驱动”，避免了盲目排查。
- **最终如何解决**：
  1. 修改 compose 文件，将 `data/warehouse` 和 `mysql-connector-java.jar` 挂载到容器；
  2. 全链路重跑 ODS -> DWD -> DWS -> ADS 的 SQL 脚本；
  3. 使用 `trunc()` 替换 `date_format()` 修正 NL2SQL 语法。

---

## 五、反思与总结

- **AI 协同带来的价值**：
  - 极大缩短了排查环境错误（如 Docker 驱动缺失、Python 版本冲突）的时间。AI 能直接给出 `ClassNotFoundException` 的解决方案，比查阅官方文档快很多。
  - 提供了结构化代码框架，比如 LangChain 的 NL2SQL 模板、Python 预测模型的特征工程，节省了从零手写的时间。
- **AI 的局限与风险（准确性 / 合规性 / 依赖）**：
  - **准确性**：AI 生成 NL2SQL 时不懂 Hive 4.0 的方言限制（生成了错误的 `date_format`）；AI 写报告时容易编造虚构的数据趋势。
  - **合规性**：DeepSeek API 的 Key 绝对不能写入代码库中，必须用 `.env` 管理并加入 `.gitignore`。
  - **依赖**：过于依赖 AI 排查环境错误，导致对 Docker 卷映射、Hive Metastore 原理的理解不够透彻，下次自己动手时依然可能踩坑。
- **本次协作中我的能力提升**：
  - 掌握了 Hive 官方镜像与自定义镜像的差异，学会了如何通过 Volume 挂载解决数据持久化和依赖缺失问题；
  - 熟悉了 LangChain 的 Prompt 约束技巧，明白了 few-shot 对限制大模型生成规范的重要性；
  - 养成了“先查上游表数据是否完整，再排查下游 SQL”的数仓排错思维。
- **对 AI 协同的改进建议**：
  - 提问时要带上具体的报错堆栈信息（如 `FileNotFoundException`、`ClassNotFoundException`），AI 的定位会更准；
  - 在让 AI 生成代码后，一定要自己在本地跑一遍测试用例，不能直接盲信；
  - 涉及核心指标计算时，应由人工定义口径，AI 只做辅助代码生成，避免“AI 乱算指标”导致数据失真。