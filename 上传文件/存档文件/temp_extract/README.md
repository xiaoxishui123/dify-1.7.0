[中文](./README_CN.md) ｜ English

# Sora2 Text-to-Video Dify Plugin

## 📖 Project Overview

This is a comprehensive Dify plugin based on 302.AI Sora-2 model that supports text-to-video generation. Generate high-quality videos from text descriptions with real-time progress tracking. The plugin uses streaming SSE (Server-Sent Events) processing to ensure stable and reliable video generation.

## ✨ Key Features

- 🎬 **High-Quality Video Generation**: Powered by advanced 302.AI Sora-2 AI model
- 📐 **Multiple Orientations**: Support landscape (16:9) and portrait (9:16) video formats
- ⚡ **Streaming Processing**: Real-time SSE response handling with progress tracking
- 🔗 **Direct Playback**: Automatically extract and return online playable video URLs
- 🔄 **Real-time Progress**: Display generation progress from 0% to 100%
- 🛡️ **Error Handling**: Comprehensive exception handling with user-friendly error messages
- 🌐 **Bilingual Support**: Supports both English and Chinese interface and messages

## 🏗️ Project Architecture

```
sora2_plugin/
├── manifest.yaml              # Plugin manifest file
├── main.py                   # Plugin entry point
├── requirements.txt          # Python dependencies
├── README.md                # English documentation
├── README_CN.md             # Chinese documentation
├── PRIVACY.md               # Privacy policy
├── icon.svg                 # Plugin icon
├── provider/                # Service provider configuration
│   ├── sora2.yaml          # 302.AI provider config
│   └── sora2_provider.py   # Provider implementation
└── tools/                   # Tool implementation
    ├── text2video.yaml     # Text-to-video tool config
    └── text2video.py       # Text-to-video tool implementation
```

## 🚀 Quick Start

### 1. Get 302.AI API Key

1. Visit [302.AI Official Website](https://302.ai)
2. Register and login to your account
3. Get your API Key (format: `sk-xxxxxx`)

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Install Plugin in Dify

1. Upload the plugin folder to Dify plugin directory
2. Enable the plugin in Dify management interface
3. Configure 302.AI API Key

## 🔧 Usage

### Basic Usage

1. Add "Sora2 Text to Video" tool in Dify workflow

2. Configure 302.AI API Key in plugin settings

3. Input video description prompt

4. Select video orientation:
   - `landscape`: Landscape (16:9) - suitable for computer/TV viewing
   - `portrait`: Portrait (9:16) - suitable for mobile short videos

5. Run the tool to generate video

### Prompt Suggestions

For best video generation results, we recommend:

- **Detailed Description**: Provide specific information about scenes, actions, camera movements, lighting
- **Clear Expression**: Use concise and clear language for description
- **Camera Direction**: You can specify camera movements like "slow push-in", "orbit shot", "first-person view"

Example prompts:

**Scene Description:**
```
A golden retriever playing in a sunny park with children running around,
camera slowly pushing in and orbiting, bright natural lighting
```

**Action Description:**
```
A young girl dancing under cherry blossom trees, pink petals falling in the wind,
sunlight filtering through branches creating dappled shadows
```

**Natural Landscape:**
```
A magnificent waterfall cascading down from heights, mist rising,
rainbow appearing in the sunlight, camera gradually zooming in from distance
```

## ⚙️ Technical Implementation

### Core Workflow

1. **Request Submission**: Submit streaming video generation request to 302.AI API
2. **SSE Streaming**: Receive real-time Server-Sent Events formatted response
3. **Progress Parsing**: Extract task ID and generation progress (0-100%)
4. **URL Extraction**: Automatically extract video playback URL from response
5. **Result Return**: Return online playable video link

### API Call Pattern

```python
# 1. Submit streaming request
POST /v1/chat/completions?async=false&callback=https://api.302.ai/async_callback
Headers:
  - Authorization: Bearer {api_key}
  - Content-Type: application/json
Body: {
  "model": "sora-2",
  "messages": [{"role": "user", "content": "prompt"}],
  "stream": true
}

# 2. Process SSE stream
data: {"choices":[{"delta":{"content":"..."}}]}
data: {"choices":[{"delta":{"content":"progress info"}}]}
data: [DONE]

# 3. Extract video URL
Pattern: https://filesystem.site/.../src.mp4?...
```

### Key Implementation Details

**Streaming Response Processing:**
```python
buffer = ""
while True:
    chunk = response.read(1024)
    buffer += chunk.decode("utf-8")
    lines = buffer.split('\n')

    for line in lines[:-1]:
        if line.startswith("data: "):
            data = json.loads(line[6:])
            # Process delta content...
```

**Progress Extraction:**
```python
progress_matches = re.findall(r'(\d+)\.\.', content)
for prog in progress_matches:
    yield f"⏳ Generation Progress: {prog}%"
```

**Video URL Extraction:**
```python
url_match = re.search(
    r'https://filesystem\.site/[^\s\)]+src\.mp4[^\s\)]*',
    content
)
if url_match:
    video_url = url_match.group(0)
```

## 🔍 Troubleshooting

### Common Issues

1. **Invalid API Key**
   - Check if API Key format starts with `sk-`
   - Confirm API Key is valid and has sufficient quota
   - Verify account status on 302.AI platform

2. **Generation Timeout**
   - Check network connection stability
   - Video generation typically takes 30-120 seconds
   - Try simplifying prompt description
   - Retry later if server is busy

3. **Unable to Extract Video URL**
   - Check network firewall settings
   - Verify 302.AI domain is not blocked
   - Review logs for detailed error information

4. **Prompt Rejected**
   - Avoid sensitive or inappropriate content
   - Use more general descriptions
   - Follow content policy guidelines

### Error Codes

- `401`: Invalid or unauthorized API Key
- `429`: API call rate limit exceeded
- `500`: Internal server error
- `Timeout`: Request timeout (network or server issue)

## 📊 Performance Metrics

- **Request Timeout**: 600 seconds (10 minutes)
- **Average Generation Time**: 30-120 seconds
- **Video Duration**: 5-10 seconds
- **Supported Format**: MP4
- **Resolution**: Automatically optimized
- **Orientations**: Landscape (16:9) / Portrait (9:16)

## 🔒 Privacy & Security

Please refer to [PRIVACY.md](./PRIVACY.md) for detailed information about data handling and privacy policy.

Key points:
- No local storage of prompts or videos
- Temporary processing only during generation
- API Key stored securely in Dify environment
- Data processed by 302.AI according to their privacy policy

## 📋 Development Standards

This plugin follows Dify plugin development best practices:

- ✅ Streaming SSE response processing
- ✅ Real-time progress tracking
- ✅ Automatic URL extraction
- ✅ Complete error handling mechanism
- ✅ Bilingual support (English/Chinese)
- ✅ Standard 302.AI API integration

## 🤝 Contributing

Welcome to submit Issues and Pull Requests to improve this plugin!

## 📄 License

This project is licensed under the MIT License.

## 🔗 Related Links

- [302.AI Official Website](https://302.ai)
- [Dify Official Documentation](https://docs.dify.ai)
- [Plugin GitHub Repository](https://github.com/wwwzhouhui/sora2_text2video)

## 📦 Release Notes

### 0.0.1 (2025-10-02)
- Initial release with Text-to-Video generation
- Support for landscape and portrait video formats
- Real-time streaming progress display
- Automatic video URL extraction
- Comprehensive error handling
- Bilingual documentation (EN/CN)
