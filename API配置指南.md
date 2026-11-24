# 云购生活系统 - API 配置与密钥安全指南

## 一、 密钥安全管理规范
本项目严格遵循企业级密钥安全规范，所有敏感信息（大模型 API Key、数据库密码）均不得以硬编码形式出现在代码或配置文件中。

1. **环境变量注入**：使用 `.env` 文件统一管理敏感信息。
2. **防泄漏措施**：`.env` 文件已加入 `.gitignore`，绝不提交至 Git 仓库。
3. **配置模板**：仓库中仅保留 `.env.example` 作为配置参考。
4. **权限最小化**：API Key 仅拥有调用大模型的基础权限；数据库账户仅在容器内部网络通信。

## 二、 大模型 API 接入配置
系统使用 DeepSeek API 进行 NL2SQL 解析。
1. 前往 DeepSeek 开放平台申请 API Key。
2. 在根目录 `.env` 文件中配置：
   ```env
   DEEPSEEK_API_KEY=sk-你的真实密钥
   MYSQL_ROOT_PASSWORD=root
## 三、密钥轮换与应急处理
1. **轮换周期**：建议每 90 天轮换一次 `DEEPSEEK_API_KEY`，在 DeepSeek 平台重新生成后更新 `.env` 并重启服务。
2. **泄露应急**：
   - 立即在 DeepSeek 平台 revoke 旧 Key；
   - 更新本地 `.env` 的 `DEEPSEEK_API_KEY`；
   - 执行 `docker compose restart app`（或重启对应服务）。
3. **数据库端口说明**：`docker-compose.yml` 中 MySQL 映射 `3307:3306` 仅用于本地调试；生产环境应移除 `ports` 段，仅保留容器内网通信。
4. **Superset 弱密钥校验**：`superset_config.py` 中若 `SUPERSET_SECRET_KEY` 为空或为默认值，启动应直接报错，避免用弱密钥运行。