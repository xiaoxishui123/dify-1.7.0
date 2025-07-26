# Google AI API 配置指南

## 概述

本指南将帮助你获取和配置Google AI API Key，以便在Dify平台中使用Google的AI模型（如Gemini、Imagen、Veo等）。

## 支持的Google AI模型

根据[Google AI开发者平台](https://ai.google.dev/)，Dify支持以下Google AI模型：

### 1. Gemini 系列
- **Gemini 2.0**: 最新的多模态模型
- **Gemini 1.5**: 长上下文模型
- **Gemini Nano**: 轻量级模型，适合移动设备

### 2. 图像生成
- **Imagen**: 文本到图像生成
- **Veo**: 视频生成模型

### 3. 开源模型
- **Gemma**: 开源语言模型

## 获取API Key的详细步骤

### 第一步：准备Google账户
1. 确保你有一个Google账户
2. 如果还没有，请访问 https://accounts.google.com/ 创建账户

### 第二步：访问Google AI Studio
1. 打开浏览器，访问：https://aistudio.google.com/
2. 点击右上角的"Sign in"按钮
3. 使用你的Google账户登录

**⚠️ 重要提示**：如果访问时自动跳转到可用区域页面，说明你所在的地区不在Google AI Studio支持范围内。请参考"常见问题解决"部分的解决方案。

**快速解决方案**：
- 使用Clash、V2Ray等代理工具
- 切换到支持的地区节点（如美国、日本、新加坡等）
- 确保代理工具正常工作后再访问

### 第三步：创建API Key
1. 登录后，在页面右上角找到"Get API key"按钮
2. 点击"Get API key"
3. 在弹出的对话框中选择"Create API key"
4. 系统会自动生成一个API Key
5. 复制这个API Key（注意：这是唯一一次显示完整Key的机会）

### 第四步：管理API Key
1. 在Google AI Studio左侧菜单中找到"API keys"
2. 在这里你可以：
   - 查看所有API Key
   - 复制API Key
   - 删除不需要的API Key
   - 为API Key添加描述

## 在Dify中配置Google AI

### 第一步：登录Dify平台
1. 打开浏览器访问：http://8.148.70.18:8080/
2. 使用你的管理员账户登录

### 第二步：进入模型配置
1. 点击左侧菜单的"设置"
2. 选择"模型提供商"
3. 找到"Google AI"或"Gemini"选项

### 第三步：配置API Key
1. 点击"添加"或"配置"按钮
2. 在API Key输入框中粘贴你刚才获取的Google AI API Key
3. 点击"保存"或"测试连接"

### 第四步：测试连接
1. 配置完成后，点击"测试连接"按钮
2. 如果显示"连接成功"，说明配置正确
3. 如果显示错误，请检查API Key是否正确

### 第五步：网络代理配置（重要）
如果你的服务器无法直接访问Google AI，需要配置代理：

**代理配置说明**：
- **代理地址**：`http://172.21.0.1:7890`
- **172.21.0.1**：Docker网络网关地址（宿主机在Docker网络中的IP）
- **7890**：Clash代理服务端口
- **作用**：让Dify容器通过代理访问Google AI API

**配置位置**：`/home/dify/docker/.env`文件
```
HTTP_PROXY=http://172.21.0.1:7890
HTTPS_PROXY=http://172.21.0.1:7890
NO_PROXY=localhost,172.21.0.1,::1
```

**重启服务**：配置修改后需要重启Dify服务
```bash
cd /home/dify/docker
docker compose restart api worker
```

## 使用限制和注意事项

### 免费额度
- Google AI提供一定的免费使用额度
- 具体额度请查看Google AI Studio中的配额页面
- 超出免费额度后需要付费使用

### 使用限制
- **请求频率限制**：每分钟和每小时的请求数量有限制
- **模型可用性**：某些模型可能在某些地区不可用
- **内容政策**：需要遵守Google的内容政策

### 安全建议
1. **保护API Key**：不要将API Key分享给他人
2. **定期轮换**：建议定期更换API Key
3. **监控使用**：定期检查API使用情况
4. **设置限制**：在Google AI Studio中设置使用限制

## 常见问题解决

### 问题1：无法访问Google AI Studio（地区限制）
**现象**：访问 https://aistudio.google.com/ 时自动跳转到可用区域页面

**解决方案**：
1. **使用VPN或代理**：
   - 使用Clash、V2Ray等代理工具
   - 切换到支持Google AI Studio的地区节点（如美国、日本、新加坡等）
   - 确保代理工具正常工作

2. **使用Google Cloud Platform**：
   - 如果无法使用代理，可以尝试使用Vertex AI中的Gemini API
   - 访问：https://cloud.google.com/vertex-ai

3. **检查网络设置**：
   - 确保DNS设置正确
   - 清除浏览器缓存和Cookie
   - 尝试使用不同的浏览器

**验证方法**：
- 成功访问后，应该能看到Google AI Studio的主界面
- 可以正常登录Google账户
- 能够看到"Get API key"按钮

### 问题2：无法访问Google AI Studio
**解决方案**：
- 检查网络连接
- 确认所在地区是否支持Google AI服务
- 尝试使用VPN（如果允许）

### 问题3：API Key无效
**解决方案**：
- 检查API Key是否完整复制
- 确认API Key是否已激活
- 检查账户是否有足够的配额

### 问题4：请求被拒绝
**解决方案**：
- 检查内容是否符合Google的政策
- 确认请求频率是否超限
- 查看错误信息中的具体原因

### 问题5：模型不可用
**解决方案**：
- 检查模型是否在你的地区可用
- 确认账户是否有权限使用该模型
- 查看Google AI Studio中的模型状态

## 高级配置

### 自定义模型参数
在Dify中，你可以为Google AI模型配置以下参数：
- **温度**：控制输出的随机性（0-1）
- **最大令牌数**：限制输出的长度
- **Top P**：控制词汇选择的多样性
- **频率惩罚**：减少重复内容

### 多模型配置
你可以配置多个Google AI模型：
1. 为不同用途创建不同的API Key
2. 在Dify中配置多个模型提供商
3. 根据需求选择合适的模型

## 监控和优化

### 使用监控
1. 在Google AI Studio中查看使用统计
2. 监控API调用次数和成本
3. 分析模型性能和使用模式

### 成本优化
1. 选择合适的模型（Gemini Nano成本较低）
2. 优化提示词以减少令牌使用
3. 使用缓存减少重复请求

## 技术支持

### 官方资源
- [Google AI开发者文档](https://ai.google.dev/docs)
- [Google AI Studio帮助](https://aistudio.google.com/help)
- [Gemini API参考](https://ai.google.dev/api/gemini-api)

### 社区支持
- [Google AI论坛](https://ai.google.dev/community)
- [Dify社区](https://discord.gg/dify)

---

**最后更新**：2025年1月27日  
**版本**：1.0  
**适用平台**：Dify AI工作流开发平台 