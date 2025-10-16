中文 ｜ [English](./README.md)

# Sora2 文生视频 Dify 插件

## 📖 项目概述

这是一个基于 302.AI Sora-2 模型的综合性 Dify 插件,支持文本生成视频功能。通过文本描述生成高质量视频,并提供实时进度追踪。插件采用流式 SSE (Server-Sent Events) 处理,确保稳定可靠的视频生成。

## ✨ 核心功能

- 🎬 **高质量视频生成**: 基于先进的 302.AI Sora-2 AI 模型
- 📐 **多种视频方向**: 支持横屏 (16:9) 和竖屏 (9:16) 视频格式
- ⚡ **流式处理**: 实时 SSE 响应处理,带进度追踪
- 🔗 **直接播放**: 自动提取并返回在线可播放的视频链接
- 🔄 **实时进度**: 显示从 0% 到 100% 的生成进度
- 🛡️ **错误处理**: 完善的异常处理,提供友好的错误提示
- 🌐 **双语支持**: 支持中英文界面和提示信息

## 🏗️ 项目架构

```
sora2_plugin/
├── manifest.yaml              # 插件清单文件
├── main.py                   # 插件入口
├── requirements.txt          # Python 依赖
├── README.md                # 英文文档
├── README_CN.md             # 中文文档
├── PRIVACY.md               # 隐私政策
├── icon.svg                 # 插件图标
├── provider/                # 服务提供商配置
│   ├── sora2.yaml          # 302.AI provider 配置
│   └── sora2_provider.py   # Provider 实现
└── tools/                   # 工具实现
    ├── text2video.yaml     # 文生视频工具配置
    └── text2video.py       # 文生视频工具实现
```

## 🚀 快速开始

### 1. 获取 302.AI API Key

1. 访问 [302.AI 官方网站](https://302.ai)
2. 注册并登录账户
3. 获取您的 API Key (格式: `sk-xxxxxx`)

### 2. 安装依赖

```bash
pip install -r requirements.txt
```

### 3. 在 Dify 中安装插件

1. 将插件文件夹上传到 Dify 插件目录
2. 在 Dify 管理界面启用插件
3. 配置 302.AI API Key

## 🔧 使用方法

### 基本用法

1. 在 Dify 工作流中添加"Sora2 文生视频"工具

2. 在插件设置中配置 302.AI API Key

3. 输入视频描述提示词

4. 选择视频方向:
   - `landscape`: 横屏 (16:9) - 适合电脑/电视观看
   - `portrait`: 竖屏 (9:16) - 适合手机短视频

5. 运行工具生成视频

### 提示词建议

为获得最佳视频生成效果,我们建议:

- **详细描述**: 提供场景、动作、镜头运动、光线等具体信息
- **清晰表达**: 使用简洁明确的语言进行描述
- **镜头指导**: 可以指定镜头运动方式,如"缓慢推进"、"环绕拍摄"、"第一人称视角"

示例提示词:

**场景描述:**
```
一只金毛犬在阳光明媚的公园里玩耍,周围有孩子们在奔跑,
镜头缓慢推进并环绕拍摄,自然光线明亮
```

**动作描述:**
```
一位年轻女孩在樱花树下跳舞,粉色花瓣随风飘落,
阳光透过树枝洒下斑驳的光影
```

**自然风景:**
```
壮观的瀑布从高处倾泻而下,水雾弥漫,
彩虹在阳光下若隐若现,镜头从远处逐渐拉近
```

## ⚙️ 技术实现

### 核心工作流程

1. **请求提交**: 向 302.AI API 提交流式视频生成请求
2. **SSE 流式响应**: 接收实时的 Server-Sent Events 格式响应
3. **进度解析**: 提取任务 ID 和生成进度 (0-100%)
4. **URL 提取**: 自动从响应中提取视频播放 URL
5. **结果返回**: 返回在线可播放的视频链接

### API 调用模式

```python
# 1. 提交流式请求
POST /v1/chat/completions?async=false&callback=https://api.302.ai/async_callback
Headers:
  - Authorization: Bearer {api_key}
  - Content-Type: application/json
Body: {
  "model": "sora-2",
  "messages": [{"role": "user", "content": "提示词"}],
  "stream": true
}

# 2. 处理 SSE 流
data: {"choices":[{"delta":{"content":"..."}}]}
data: {"choices":[{"delta":{"content":"进度信息"}}]}
data: [DONE]

# 3. 提取视频 URL
模式: https://filesystem.site/.../src.mp4?...
```

### 关键实现细节

**流式响应处理:**
```python
buffer = ""
while True:
    chunk = response.read(1024)
    buffer += chunk.decode("utf-8")
    lines = buffer.split('\n')

    for line in lines[:-1]:
        if line.startswith("data: "):
            data = json.loads(line[6:])
            # 处理 delta 内容...
```

**进度提取:**
```python
progress_matches = re.findall(r'(\d+)\.\.', content)
for prog in progress_matches:
    yield f"⏳ 生成进度: {prog}%"
```

**视频 URL 提取:**
```python
url_match = re.search(
    r'https://filesystem\.site/[^\s\)]+src\.mp4[^\s\)]*',
    content
)
if url_match:
    video_url = url_match.group(0)
```

## 🔍 故障排查

### 常见问题

1. **API Key 无效**
   - 检查 API Key 格式是否以 `sk-` 开头
   - 确认 API Key 有效且有足够额度
   - 验证 302.AI 平台账户状态

2. **生成超时**
   - 检查网络连接稳定性
   - 视频生成通常需要 30-120 秒
   - 尝试简化提示词描述
   - 如服务器繁忙请稍后重试

3. **无法提取视频 URL**
   - 检查网络防火墙设置
   - 验证 302.AI 域名未被屏蔽
   - 查看日志获取详细错误信息

4. **提示词被拒绝**
   - 避免敏感或不当内容
   - 使用更通用的描述
   - 遵守内容政策指南

### 错误代码

- `401`: API Key 无效或未授权
- `429`: API 调用频率超限
- `500`: 服务器内部错误
- `Timeout`: 请求超时(网络或服务器问题)

## 📊 性能指标

- **请求超时**: 600 秒 (10 分钟)
- **平均生成时间**: 30-120 秒
- **视频时长**: 5-10 秒
- **支持格式**: MP4
- **分辨率**: 自动优化
- **视频方向**: 横屏 (16:9) / 竖屏 (9:16)

## 🔒 隐私与安全

请参阅 [PRIVACY.md](./PRIVACY.md) 了解数据处理和隐私政策的详细信息。

要点:
- 不在本地存储提示词或视频
- 仅在生成过程中临时处理
- API Key 安全存储在 Dify 环境中
- 数据由 302.AI 按其隐私政策处理

## 📋 开发规范

本插件遵循 Dify 插件开发最佳实践:

- ✅ 流式 SSE 响应处理
- ✅ 实时进度追踪
- ✅ 自动 URL 提取
- ✅ 完整的错误处理机制
- ✅ 双语支持 (中文/英文)
- ✅ 标准 302.AI API 集成

## 🤝 贡献

欢迎提交 Issues 和 Pull Requests 来改进本插件!

## 📄 许可证

本项目采用 MIT 许可证。

## 🔗 相关链接

- [302.AI 官方网站](https://302.ai)
- [Dify 官方文档](https://docs.dify.ai)
- [插件 GitHub 仓库](https://github.com/wwwzhouhui/sora2_text2video)

## 📦 版本说明

### 0.0.1 (2025-10-02)
- 首次发布,支持文生视频功能
- 支持横屏和竖屏视频格式
- 实时流式进度显示
- 自动视频 URL 提取
- 完善的错误处理
- 双语文档 (中文/英文)
