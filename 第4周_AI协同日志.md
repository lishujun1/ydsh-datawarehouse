# 第 4 周 AI 协同日志

- 团队：[wbg]　成员：[厉姝君]　填写日期：2026-11-18

---

## 一、使用的 AI 工具 / 模型

- 工具名称：DeepSeek 对话助手、ChatGPT　模型版本：DeepSeek-V3、GPT-4o
- 辅助工具：GitHub Copilot（IDE 代码补全）

---

## 二、AI 协同记录表

| 序号 | 提问 / 任务描述 | AI 产出摘要 | 人工修改与验证 | 是否采纳 |
|------|----------------|-------------|----------------|----------|
| 1 | 编写一键部署的 Docker Compose 编排，要求包含 Hive、MySQL 和 Superset，并处理依赖顺序和敏感信息。 | 给出了包含 healthcheck 和 depends_on 的完整 YAML 脚本，并指导使用 `${MYSQL_ROOT_PASSWORD}` 进行环境变量注入。 | 人工创建了 `.env` 文件并在 `docker-compose.yml` 中引入了 `${MYSQL_ROOT_PASSWORD}`，经过 `docker compose up -d` 测试，四个容器全部处于 healthy 和 up 状态。 | 是 |
| 2 | 编写 ECharts 经营分析数据大屏，要求包含折线、柱状、饼图、热力图，且必须自适应 1920x1080 分辨率。 | 生成了完整的 HTML/CSS/JS 代码，并提供了一个基于 `window.innerWidth` 动态计算 `transform: scale()` 的自适应缩放方案。 | 人工调整了卡片的边框色和标题渐变色。发现直接打开 HTML 文件因跨域请求 Flask 接口失败，采纳了 AI 的 Flask 内置 `render_template_string` 方案，成功渲染。 | 是 |
| 3 | 编写 Streamlit 智能问数前端，需要接入 DeepSeek API 并实现自然语言到 Hive SQL 的闭环。 | 提供了基于 `streamlit-echarts` 和自定义 `nl2sql` 函数的界面代码，带有加载状态和侧边栏历史对话。 | 人工验证了大模型生成的 SQL 准确率，并对 `nl2sql.py` 中不兼容 Hive 的函数（如 `date_format` 替换为 `trunc`）增加了正则替换兜底。 | 是 |
| 4 | 运行 Python 压测脚本时，报错 `SyntaxError: invalid syntax`，提示 `time.sleep(1)d:` 错误。 | 识别出是复制代码时末尾带了乱码，提供了干净版的压测脚本。 | 人工删除了多余字符，重新运行脚本，成功输出了 1、3、5、10 并发下的平均响应时间和 100% 成功率。 | 是 |
| 5 | 编写 Flask API 给大屏提供数据时，报错 `TTransportException: Length exceeded max allowed: 16384000`。 | 诊断出是 `pyhive` 读取 Hive 元数据时的包大小限制缺陷，给出了通过 `limit` 限制数据量以及绕过 Hive 直接返回静态数据的终极保底方案。 | 人工为了不耽误大屏展示进度，采纳了返回静态数据的方案，保证了答辩演示的稳定性。 | 是 |

---

## 三、AI 产出成果清单

- **由 AI 生成的内容**：Docker Compose 基础架构、ECharts 大屏全套 HTML/JS/CSS 代码、Streamlit 前端界面框架、Python 并发压测脚本。
- **由人工编写的内容**：数仓 ODS/DWD/DWS/ADS 各层的 ETL SQL 脚本、项目业务背景与指标体系（GMV、AOV等）、`.env` 密钥管理规范、系统整体业务逻辑串联。
- **人机协作完成的内容**：`nl2sql.py` 中大模型 Prompt 的约束规则、大屏接口与 Flask 后端的联调、Superset 数据源连接与图表配置。

---

## 四、问题与解决

- **遇到的问题**：
  1. ECharts 前端加载时报错 `echarts is not defined`，尝试了多个 CDN 都无法加载。
  2. Flask 后端连接 Hive 时，底层 `pyhive` 频繁报错 `Length exceeded max allowed`，导致接口 500。
  3. Docker 启动 Superset 后，宿主机 `localhost:8088` 无法访问，报错 `Empty reply from server`。
- **AI 是否有效解决**：是，AI 提供了极具针对性的排查思路。
- **最终如何解决**：
  1. 针对 CDN 问题，AI 建议将 `echarts.min.js` 下载到本地并直接通过 Flask 渲染；同时排查出 `localhost` 被浏览器插件拦截，改用 `127.0.0.1` 及无痕模式成功。
  2. 针对 Hive 连接崩溃，AI 分析了 Python Traceback，定位到 Thrift 通信的 16MB 限制，指导通过限制 `limit` 和使用假数据兜底解决了接口崩溃问题。
  3. 针对 Superset 无法访问，在 AI 指导下重新配置了 WSL2 的网络模式 (`networkingMode=nat`)，并重启 Docker 服务，最终成功访问。

---

## 五、反思与总结

- **AI 协同带来的价值**：极大提升了全栈开发效率。从零手写 ECharts 自适应大屏的样式和复杂的 Docker 依赖编排非常耗时，AI 能瞬间给出高质量的基础模板，让团队能将精力聚焦在数仓业务逻辑和真实数据验证上。
- **AI 的局限与风险**：
  1. **环境差异**：AI 的代码在理想环境下完美，但在实际 Windows + WSL2 + Hive 环境中，会遭遇网络拦截、内存限制等真实问题，必须人工 Debug。
  2. **幻觉与版本问题**：AI 给出的部分 Python 库用法可能过时，或存在未闭合的符号等低级语法错误，不能无脑复制。
- **本次协作中我的能力提升**：掌握了如何通过分析 `Traceback` 和浏览器 `F12` 控制台来定位前后端问题；深入理解了 Docker 网络转发原理以及 `pyhive` 的底层痛点；学会了通过调整 Prompt 来限制大模型生成 SQL 的准确率。
- **对 AI 协同的改进建议**：以后在向 AI 提问时，应提供更完整的错误上下文（如终端截图、完整代码段、环境操作系统），并在给代码前先让它自查是否有网络或环境依赖风险。