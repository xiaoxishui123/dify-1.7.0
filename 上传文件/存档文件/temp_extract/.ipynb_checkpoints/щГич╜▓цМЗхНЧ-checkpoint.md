# 🚀 Sora2 文生视频插件部署指南

## 📋 部署步骤

### 1. 准备工作

确保您已经:
- ✅ 安装了 Dify 平台
- ✅ 拥有 302.AI 账户和 API Key
- ✅ Python 3.12+ 环境

### 2. 安装插件

#### 方法一: 直接复制
```bash
# 将 sora2_plugin 目录复制到 Dify 插件目录
cp -r sora2_plugin /path/to/dify/plugins/
```

#### 方法二: 使用 Dify CLI (如果可用)
```bash
dify plugin install sora2_plugin
```

### 3. 配置 API Key

1. 登录 Dify 管理后台
2. 进入 "插件管理" → "Sora2 文生视频"
3. 配置 302.AI API Key (格式: `sk-xxxxxx`)
4. 保存配置

### 4. 验证安装

在 Dify 工作流中:
1. 添加 "Sora2 文生视频" 工具
2. 输入测试提示词: "一只可爱的小猫在玩毛线球"
3. 选择视频方向: "landscape"
4. 运行工作流
5. 等待视频生成 (约 30-120 秒)
6. 获取视频播放链接

## 📦 依赖说明

插件依赖:
- `dify-plugin >= 0.0.1`

Python 标准库:
- `http.client` - HTTP 客户端
- `json` - JSON 处理
- `re` - 正则表达式
- `time` - 时间控制

## 🔧 配置选项

### 环境变量 (可选)

```bash
# 超时设置 (秒)
SORA2_TIMEOUT=600

# API 基础 URL (默认: api.302.ai)
SORA2_API_BASE=api.302.ai
```

### 插件配置

在 `manifest.yaml` 中可调整:
- `memory`: 内存限制 (默认: 2097152 = 2MB)
- `version`: 插件版本

在 `main.py` 中可调整:
- `MAX_REQUEST_TIMEOUT`: 请求超时时间 (默认: 600秒)

## 🧪 测试

### 快速测试

```python
# 运行测试示例
python sora2_plugin/test_examples.py
```

### 完整测试流程

1. **基础功能测试**
   - 提示词: "阳光明媚的公园"
   - 预期: 返回视频播放链接

2. **进度显示测试**
   - 检查是否显示进度百分比
   - 预期: 显示 0%, 36%, 50%, 90% 等进度

3. **URL 提取测试**
   - 检查是否正确提取视频 URL
   - 预期: URL 包含 `src.mp4`

4. **错误处理测试**
   - 使用无效 API Key
   - 预期: 显示友好的错误提示

## ⚠️ 常见问题

### Q1: API Key 验证失败
**原因**: API Key 格式不正确或已过期
**解决**:
- 检查格式是否为 `sk-` 开头
- 确认账户额度是否充足
- 重新获取 API Key

### Q2: 视频生成超时
**原因**: 网络问题或服务器繁忙
**解决**:
- 检查网络连接
- 稍后重试
- 增加超时时间设置

### Q3: 无法获取视频 URL
**原因**: 响应解析失败
**解决**:
- 检查 API 响应格式是否变化
- 查看日志获取详细错误信息
- 联系技术支持

### Q4: 提示词被拒绝
**原因**: 包含敏感内容
**解决**:
- 修改提示词,避免敏感词汇
- 使用更通用的描述

## 🔒 安全建议

1. **API Key 保护**
   - 不要在代码中硬编码 API Key
   - 使用环境变量或配置文件
   - 定期更换 API Key

2. **访问控制**
   - 限制插件使用权限
   - 记录 API 调用日志
   - 监控异常使用

3. **内容审核**
   - 实施提示词过滤
   - 记录生成内容
   - 遵守使用条款

## 📊 性能优化

### 1. 网络优化
- 使用稳定的网络环境
- 考虑配置代理或 CDN
- 启用 HTTP/2 或 HTTP/3

### 2. 超时设置
- 根据网络环境调整超时时间
- 为不同场景设置不同超时值

### 3. 缓存机制 (可选扩展)
- 缓存相似提示词的结果
- 使用 Redis 存储视频 URL
- 设置合理的过期时间

## 🔄 更新维护

### 更新插件

```bash
# 备份当前版本
cp -r sora2_plugin sora2_plugin_backup

# 更新到新版本
cp -r new_sora2_plugin sora2_plugin

# 重启 Dify 服务
systemctl restart dify
```

### 版本兼容性

- v0.0.1: 初始版本,支持基础文生视频
- 后续版本将在 README 中说明变更

## 📝 日志调试

### 启用调试日志

在 `text2video.py` 中添加日志:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# 在关键位置添加日志
logger.debug(f"API Response: {response_data}")
logger.info(f"Video URL extracted: {video_url}")
```

### 查看日志

```bash
# Dify 日志位置 (根据实际安装调整)
tail -f /var/log/dify/plugins.log
```

## 🎯 下一步

安装成功后,您可以:

1. 📖 阅读 [使用指南.md](./使用指南.md) 了解详细用法
2. 🧪 运行 [test_examples.py](./test_examples.py) 查看示例
3. 🚀 在生产环境中使用插件
4. 💡 根据需求定制和扩展功能

## 📞 获取帮助

如遇到问题:
1. 查看 [README.md](./README.md) 故障排查部分
2. 检查 Dify 插件文档
3. 查看 302.AI API 文档
4. 联系技术支持

---

**祝您部署顺利! 🎉**
