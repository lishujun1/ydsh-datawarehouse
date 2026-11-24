# 第 1 周 AI 协同日志

- 团队：wbg　成员：厉姝君　填写日期：2026-10-29

---

## 一、使用的 AI 工具 / 模型

- 工具名称：DeepSeek (Web端)　模型版本：DeepSeek-V3
- （辅助工具：Docker Desktop、Hive 4.0.0、Git）

---

## 二、AI 协同记录表（至少 5 条）

| 序号 | 提问 / 任务描述 | AI 产出摘要 | 人工修改与验证 | 是否采纳 |
|------|----------------|-------------|----------------|----------|
| 1 | 启动 docker-compose 时，hive-metastore 容器启动后立即退出，日志报错：Failed to load driver (ClassNotFoundException: com.mysql.cj.jdbc.Driver)。 | AI 指出 `apache/hive:4.0.0` 官方镜像不包含 MySQL JDBC 驱动，提供了下载 8.0.28 版本驱动、编写 Dockerfile 重新构建 `my-hive:4.0.0` 镜像的解决方案。 | 我下载了 jar 包，写了 Dockerfile 并 build，修改了 compose 中的镜像名。重新 `up -d` 后，metastore 成功常驻，没有再报错。 | 是 |
| 2 | 在 Hive beeline 中执行了建表和 `load data`，数据也导进去了，但运行 `git status` 却显示 `working tree clean`，不知道为什么。 | AI 解释：在终端里敲的代码只发给了 Hive 引擎，并没有在 Windows 本地生成实体文件。Git 只追踪本地新建或修改的文件。 | 我按照建议，在 `D:\ydsh-datawarehouse` 下建了 `sql/ods` 和 `sql/clean` 文件夹，用 VS Code 把代码存成 `.sql` 文件。再次执行 `git status` 时，成功检测到了未追踪文件。 | 是 |
| 3 | 在导入数据时，表里只有表头没有数据，行数不对。 | AI 分析可能有两个原因：一是没有跳过表头，二是 Windows 的 CSV 分隔符可能是 Tab 而不是英文逗号。建议先检查 CSV 源文件格式。 | 我检查了 CSV 文件，发现确实用了英文逗号。同时在建表语句里补充了 `tblproperties('skip.header.line.count'='1')`，重新导入后行数与预期完全一致。 | 是 |
| 4 | 用户表有缺失的年龄，订单表有重复的主键，老师要求分别用 HiveSQL 写清洗代码。 | AI 提供了 `COALESCE(age, 均值)` 填充缺失值，以及 `ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY ...)` 进行去重的代码。 | 我验证了去重前后的行数差异，并用 `select count(*) ... where age is null` 验证了清洗后为空的行数为 0。 | 是 |
| 5 | 老师要求把原先合并在一起的建表、导入、缺失值清洗、去重拆分成独立的脚本文件（4个）。 | AI 立即把原先的 `create_ods.sql` 和 `clean.sql` 拆成了 `create_ods.sql`、`load_ods.sql`、`clean_missing.sql`、`clean_duplicate.sql` 四个文件，并附带了规范的重构提交前缀 `refactor:`。 | 我按拆分后的文件结构重新 `git add .` 并提交，查看 `git log` 确认历史记录清晰，带有标准的 `refactor:` 前缀。 | 是 |

---

## 三、AI 产出成果清单

- 由 AI 生成的内容：Dockerfile 的编写逻辑、Hive 清洗窗口函数的 SQL 语句、Git 规范提交的命名建议。
- 由人工编写的内容：真实的项目结构搭建、环境的实际排错、数据的导入与验证、数据字典字段的对照。
- 人机协作完成的内容：分析五维度数据质量报告，结合真实的扫描结果（空值、负数、乱码）整合成了《数据质量预评估表》。

---

## 四、问题与解决

- 遇到的问题：Docker 启动 Hive 报错缺失驱动；本地文件与终端执行脱节导致 Git 无法追踪；清洗脚本未拆分。
- AI 是否有效解决：非常有效。AI 精准定位了容器启动日志中的 `ClassNotFoundException`，一语道破了 Git 追踪的本质原理。
- 最终如何解决：通过构建自定义镜像解决依赖问题；通过建立实体文件夹保存 `.sql` 解决 Git 追踪问题；通过对 AI 生成的代码进行本地保存、测试与重构，完成了规范的 Git 提交。


## 五、反思与总结

- AI 协同带来的价值：极大地降低了排错门槛，特别是在 Docker 容器黑盒报错和编写复杂的 Hive 窗口函数时，AI 提供了直接、高效的模板，节省了至少 50% 的查阅文档时间。
- AI 的局限与风险：AI 有时给出的代码（如建表语句）字段名可能与真实数据字典不一致，如果盲目复制会导致数据类型错位或整个表变成一列。必须在粘贴前核对真实表头。
- 本次协作中我的能力提升：熟悉了 Docker 容器的排错手段（`docker logs`）；掌握了如何使用 `ROW_NUMBER()` 进行业务主键去重；理解了代码提交规范的重要性。
- 对AI协同的改进建议：下次在提问时，最好先把原始数据的表头（字段名）和运行报错的完整日志发给 AI，AI 给出的解决方案会更加精准，避免来回返工。