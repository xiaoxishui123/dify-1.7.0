# Dify AI 工作流开发平台

## 项目简介

Dify 是一个生产就绪的 AI 工作流开发平台，支持构建和测试强大的 AI 工作流。本项目已成功部署在您的服务器上，可通过 `http://8.148.70.18:8080/` 访问。

## 部署信息

- **访问地址**: http://8.148.70.18:8080/
- **部署时间**: 2025年7月25日
- **部署方式**: Docker Compose
- **端口**: 8080
- **状态**: 运行中

## 主要功能

### 1. 工作流构建
- 在可视化画布上构建和测试强大的 AI 工作流
- 支持复杂的业务流程编排

### 2. 模型支持
- 无缝集成数百个专有/开源 LLM
- 支持 GPT、Mistral、Llama3 等模型
- 兼容任何 OpenAI API 兼容的模型

### 3. Prompt IDE
- 直观的提示词编写界面
- 模型性能比较
- 支持文本转语音等功能

### 4. RAG 管道
- 全面的 RAG 功能
- 支持 PDF、PPT 等文档格式
- 从文档摄取到检索的完整流程

### 5. Agent 能力
- 基于 LLM Function Calling 或 ReAct 定义 Agent
- 50+ 内置工具（Google Search、DALL·E、Stable Diffusion 等）
- 支持自定义工具

### 6. LLMOps
- 监控和分析应用日志
- 基于生产数据持续改进
- 性能分析

### 7. 后端即服务
- 所有功能都提供对应的 API
- 轻松集成到业务逻辑中

## 技术架构

### 核心组件
- **API 服务**: Python Flask 后端
- **Web 前端**: React 前端界面
- **数据库**: PostgreSQL 15
- **缓存**: Redis 6
- **向量数据库**: Weaviate
- **反向代理**: Nginx
- **任务队列**: Celery
- **沙箱环境**: 代码执行环境

### 端口配置
- **主服务**: 8080 (Nginx)
- **API 服务**: 5001 (内部)
- **插件调试**: 5003
- **数据库**: 5432 (内部)
- **Redis**: 6379 (内部)

## 使用方法

### 1. 访问平台
打开浏览器访问: http://8.148.70.18:8080/

### 2. 初始化设置
首次访问时需要进行初始化设置：
- 创建管理员账户
- 配置模型提供商
- 设置工作空间

### 3. 创建应用
- 选择应用类型（对话应用或文本生成应用）
- 配置模型和参数
- 设计工作流

### 4. 集成使用
- 通过 API 集成到您的应用
- 使用 SDK 进行开发
- 嵌入到现有系统中

## 管理命令

### 查看服务状态
```bash
cd /home/dify/docker
docker compose ps
```

### 启动服务
```bash
cd /home/dify/docker
docker compose up -d
```

### 停止服务
```bash
cd /home/dify/docker
docker compose down
```

### 查看日志
```bash
cd /home/dify/docker
docker compose logs -f [服务名]
```

### 重启服务
```bash
cd /home/dify/docker
docker compose restart [服务名]
```

## 配置说明

### 环境变量
主要配置文件位于 `/home/dify/docker/.env`，包含：
- 数据库配置
- Redis 配置
- 向量数据库配置
- 存储配置
- 模型提供商配置

### 端口修改
如需修改访问端口，编辑 `.env` 文件中的：
```
NGINX_PORT=8080
EXPOSE_NGINX_PORT=8080
```

## 数据备份

### 数据库备份
```bash
cd /home/dify/docker
docker compose exec db pg_dump -U postgres dify > backup.sql
```

### 文件存储备份
```bash
cd /home/dify/docker
tar -czf storage_backup.tar.gz volumes/
```

## 故障排除

### 常见问题

1. **服务无法启动**
   - 检查端口是否被占用
   - 查看 Docker 日志
   - 确认系统资源充足

2. **无法访问网页**
   - 检查防火墙设置
   - 确认端口映射正确
   - 查看 Nginx 日志

3. **数据库连接失败**
   - 检查数据库容器状态
   - 确认环境变量配置
   - 查看数据库日志

### 日志查看
```bash
# 查看所有服务日志
docker compose logs

# 查看特定服务日志
docker compose logs api
docker compose logs web
docker compose logs nginx
```

## 安全建议

1. **修改默认密码**
   - 及时修改管理员密码
   - 使用强密码策略

2. **网络安全**
   - 配置防火墙规则
   - 限制访问IP
   - 启用HTTPS（生产环境）

3. **数据安全**
   - 定期备份数据
   - 加密敏感信息
   - 监控访问日志

## 更新升级

### 更新 Dify
```bash
cd /home/dify
git pull origin main
cd docker
docker compose down
docker compose up -d
```

### 更新镜像
```bash
cd /home/dify/docker
docker compose pull
docker compose up -d
```

## 技术支持

- **官方文档**: https://docs.dify.ai/
- **GitHub**: https://github.com/langgenius/dify
- **社区**: https://discord.gg/dify

## 许可证

本项目使用 Dify Open Source License，基于 Apache 2.0 许可证。

---

**部署完成时间**: 2025年7月25日 16:39  
**部署状态**: ✅ 成功  
**访问地址**: http://8.148.70.18:8080/
