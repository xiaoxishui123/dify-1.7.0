# 🎙️ TTS语音合成最终配置指南

## 🎯 **配置完成状态**

✅ **豆包语音合成服务已完全配置并运行正常！**

## 📋 **服务状态**

### 🔧 **TTS网关服务**
- **状态**: ✅ 运行中
- **地址**: http://localhost:3006
- **API文档**: http://localhost:3006/docs
- **豆包Token**: ✅ 已配置
- **OSS服务**: ✅ 已配置（CapCutAPI）

### 🎵 **支持的音色**
- **东方浩然(男声)**: `zh_male_dongfanghaoran_moon_bigtts`
- **天美(女声)**: `zh_female_tianmei_moon_bigtts`
- **志刚(男声)**: `zh_male_zhigang_moon_bigtts`
- **思悦(女声)**: `zh_female_siyue_moon_bigtts`
- **凯凯(男声)**: `zh_male_kaikai_moon_bigtts`
- **小雨(女声)**: `zh_female_xiaoyu_moon_bigtts`
- **正气(男声)**: `zh_male_zhengqi_moon_bigtts`
- **小沫(女声)**: `zh_female_xiaomo_moon_bigtts`
- **志豪(男声)**: `zh_male_zhihao_moon_bigtts`
- **小馨(女声)**: `zh_female_xiaoxin_moon_bigtts`

## 🚀 **使用方法**

### 1. **API调用示例**
```bash
curl -X POST http://localhost:3006/api/v1/tts \
  -H "Content-Type: application/json" \
  -d '{
    "text": "欢迎使用豆包语音合成服务",
    "voice_type": "zh_female_tianmei_moon_bigtts",
    "speed_ratio": 1.0,
    "audio_format": "mp3",
    "sample_rate": 24000
  }'
```

### 2. **返回结果示例**
```json
{
  "audio_url": "https://zdaigfpt.oss-cn-wuhan-lr.aliyuncs.com/capcut/audios/...",
  "voice_type": "zh_female_tianmei_moon_bigtts",
  "audio_format": "mp3",
  "sample_rate": 24000,
  "speed_ratio": 1.0,
  "processing_time": 1.07,
  "file_size": 126223,
  "status": "success",
  "message": "豆包语音合成成功"
}
```

## 🔧 **服务管理**

### **启动服务**
```bash
cd /home/dify/tts_gateway
./start.sh
```

### **停止服务**
```bash
pkill -f "tts_gateway:app"
```

### **查看状态**
```bash
curl http://localhost:3006/
```

### **查看日志**
```bash
tail -f /home/dify/tts_gateway/tts_gateway.log
```

## 🚀 **部署和安装**

### **完整部署脚本**
```bash
cd /home/dify/tts_gateway
./deploy.sh
```

这个脚本会：
- ✅ 检查Python环境
- ✅ 安装依赖
- ✅ 创建配置文件（如果不存在）
- ✅ 配置环境变量
- ✅ 安装系统服务（可选）
- ✅ 启动服务
- ✅ 测试服务功能

### **系统服务管理**
如果选择了安装系统服务：
```bash
# 启动服务
systemctl start tts-gateway

# 停止服务
systemctl stop tts-gateway

# 重启服务
systemctl restart tts-gateway

# 查看状态
systemctl status tts-gateway

# 查看日志
journalctl -u tts-gateway -f
```

## 📱 **Dify集成**

### 1. **插件配置**
- **插件文件**: `上传文件/语音合成插件.yaml`
- **服务地址**: `http://8.148.70.18:3006`
- **API端点**: `/api/v1/tts`

### 2. **工作流配置**
- **主工作流**: `上传文件/一键生成短视频单个图片视频.yml`
- **优化版工作流**: `上传文件/一键生成短视频-豆包语音优化版.yml`

### 3. **测试步骤**
1. 在Dify中导入语音合成插件
2. 配置插件地址为 `http://8.148.70.18:3006`
3. 测试插件功能
4. 导入并测试工作流

## 🛠️ **故障排除**

### **常见问题**

#### 1. **服务无法启动**
```bash
# 检查端口占用
netstat -tlnp | grep 3006

# 检查环境变量
cat /home/dify/tts_gateway/config.env

# 重启服务
./start.sh
```

#### 2. **豆包API调用失败**
```bash
# 检查token配置
echo $OPENSPEECH_TOKEN

# 检查网络连接
curl -I https://api.volcengine.com/tts/v1/tts
```

#### 3. **OSS上传失败**
```bash
# 检查CapCutAPI服务
curl http://localhost:9000/

# 检查OSS配置
cat /home/CapCutAPI-1.1.0/config.json
```

## 📁 **文件结构**

```
/home/dify/tts_gateway/
├── tts_gateway.py          # 主服务文件
├── config.env              # 环境变量配置
├── start.sh                # 启动脚本
├── deploy.sh               # 完整部署脚本
├── tts-gateway.service     # 系统服务文件
├── requirements.txt        # Python依赖
└── README.md              # 说明文档
```

## 🎉 **配置完成！**

现在您可以：
1. ✅ 在Dify中使用豆包语音合成插件
2. ✅ 生成真实的语音文件并上传到OSS
3. ✅ 在一键生成短视频工作流中使用语音合成
4. ✅ 享受10种不同音色的高质量语音

**🚀 开始创作您的精彩短视频吧！** 