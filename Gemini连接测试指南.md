# Gemini连接测试指南

## 当前状态分析

根据你的截图，你已经完成了以下步骤：
✅ 成功获取Google AI API Key  
✅ 在Dify中配置Gemini模型  
❓ 连接状态需要验证

## 连接测试步骤

### 第一步：验证API Key格式
你的API Key：`AlzaSyBzcsPShQbk2DFJWZ8a6gtbnli9-LbepFO`

**检查要点**：
- API Key长度是否正确（通常为39-40个字符）
- 是否包含特殊字符
- 是否完整复制（没有遗漏字符）

### 第二步：在Dify中测试连接
1. 在Dify的模型供应商页面
2. 找到Gemini配置
3. 点击"测试连接"或"验证"按钮
4. 查看测试结果

### 第三步：检查错误信息
如果连接失败，请记录具体的错误信息：
- 网络连接错误
- API Key无效
- 权限不足
- 地区限制
- 配额超限

## 常见问题及解决方案

### 问题1：API Key无效
**错误信息**：`Invalid API key` 或 `API key not found`

**解决方案**：
1. 重新复制API Key，确保没有多余的空格
2. 检查API Key是否在Google AI Studio中仍然有效
3. 确认API Key没有过期或被删除

### 问题2：网络连接问题
**错误信息**：`Connection timeout` 或 `Network error`

**解决方案**：
1. 检查网络连接是否稳定
2. 确认代理工具（Clash）是否正常工作
3. 尝试切换不同的代理节点
4. 清除浏览器缓存

### 问题3：权限不足
**错误信息**：`Insufficient permissions` 或 `Access denied`

**解决方案**：
1. 确认Google账户已登录
2. 检查Google AI Studio中的API Key权限设置
3. 确认账户没有被限制

### 问题4：地区限制
**错误信息**：`Region not supported` 或 `Service unavailable`

**解决方案**：
1. 确保使用支持地区的代理节点
2. 检查Google AI Studio是否正常访问
3. 尝试使用不同的代理服务器

### 问题5：配额超限
**错误信息**：`Quota exceeded` 或 `Rate limit exceeded`

**解决方案**：
1. 检查Google AI Studio中的使用配额
2. 等待配额重置（通常是每小时或每天）
3. 考虑升级到付费计划

## 详细测试流程

### 测试1：基础连接测试
```bash
# 使用curl测试API连接（需要替换YOUR_API_KEY）
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Hello, how are you?"
      }]
    }]
  }' \
  https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent
```

### 测试2：在Dify中创建测试应用
1. 创建一个简单的对话应用
2. 选择Gemini模型
3. 发送测试消息
4. 查看响应情况

### 测试3：检查日志
1. 在Dify中查看应用日志
2. 检查API调用记录
3. 查看错误详情

## 配置检查清单

### Google AI Studio配置
- [ ] API Key已生成且有效
- [ ] 账户已登录且未被限制
- [ ] 所在地区支持Google AI服务
- [ ] 有足够的使用配额

### Dify配置
- [ ] API Key正确粘贴
- [ ] 模型选择正确（Gemini Pro或Gemini Pro Vision）
- [ ] 网络连接正常
- [ ] 代理工具正常工作

### 网络配置
- [ ] 代理工具正常运行
- [ ] 可以正常访问Google AI Studio
- [ ] DNS设置正确
- [ ] 防火墙未阻止连接

## 替代方案

如果Gemini连接持续失败，可以考虑：

### 1. 使用其他Google AI模型
- 尝试Gemini Pro Vision
- 使用Gemini 1.5
- 考虑Gemini Nano

### 2. 使用其他AI提供商
- OpenAI GPT模型
- Anthropic Claude模型
- 本地部署的模型

### 3. 使用Google Cloud Platform
- 通过Vertex AI使用Gemini API
- 可能需要额外的配置和费用

## 获取帮助

### 1. 查看详细日志
在Dify中查看完整的错误日志，这将提供更具体的错误信息。

### 2. 联系技术支持
- Dify社区：https://discord.gg/dify
- Google AI支持：https://ai.google.dev/community

### 3. 检查官方文档
- [Google AI API文档](https://ai.google.dev/docs)
- [Dify文档](https://docs.dify.ai/)

---

**测试时间**：请记录测试的具体时间和结果  
**错误信息**：请提供完整的错误信息以便进一步诊断  
**网络环境**：请说明当前使用的网络环境（代理、地区等） 