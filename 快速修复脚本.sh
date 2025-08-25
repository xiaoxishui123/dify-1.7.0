#!/bin/bash

# 语音合成工作流快速修复脚本
# 版本: v1.0
# 日期: 2025-08-19

echo "🔧 语音合成工作流快速修复脚本"
echo "=================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印状态
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "success" ]; then
        echo -e "${GREEN}✅ $message${NC}"
    elif [ "$status" = "error" ]; then
        echo -e "${RED}❌ $message${NC}"
    elif [ "$status" = "warning" ]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
    else
        echo -e "${BLUE}ℹ️  $message${NC}"
    fi
}

# 函数：检查服务状态
check_service() {
    local service_name=$1
    local check_command=$2
    
    echo -n "检查 $service_name 状态... "
    if eval "$check_command" > /dev/null 2>&1; then
        print_status "success" "$service_name 正常运行"
        return 0
    else
        print_status "error" "$service_name 异常"
        return 1
    fi
}

# 函数：重启服务
restart_service() {
    local service_name=$1
    local restart_command=$2
    
    echo -n "重启 $service_name... "
    if eval "$restart_command" > /dev/null 2>&1; then
        print_status "success" "$service_name 重启成功"
        sleep 3
        return 0
    else
        print_status "error" "$service_name 重启失败"
        return 1
    fi
}

echo ""
echo "📋 开始系统检查..."

# 1. 检查TTS服务
echo ""
echo "🔍 检查TTS服务..."
if check_service "TTS服务" "curl -s http://localhost:3006/ | grep -q 'status.*running'"; then
    print_status "success" "TTS服务正常"
else
    print_status "warning" "TTS服务异常，尝试重启..."
    if restart_service "TTS服务" "cd /home/dify/tts_gateway && ./restart.sh"; then
        if check_service "TTS服务" "curl -s http://localhost:3006/ | grep -q 'status.*running'"; then
            print_status "success" "TTS服务重启成功"
        else
            print_status "error" "TTS服务重启失败"
        fi
    fi
fi

# 2. 检查CapCut API
echo ""
echo "🔍 检查CapCut API..."
if check_service "CapCut API" "curl -s http://8.148.70.18:9000/ | grep -q 'CapCutAPI'"; then
    print_status "success" "CapCut API正常"
else
    print_status "error" "CapCut API无法访问"
fi

# 3. 检查网络连接
echo ""
echo "🔍 检查网络连接..."
if check_service "网络连接" "ping -c 1 8.148.70.18 > /dev/null 2>&1"; then
    print_status "success" "网络连接正常"
else
    print_status "error" "网络连接异常"
fi

# 4. 检查端口占用
echo ""
echo "🔍 检查端口占用..."
if netstat -tlnp | grep ":3006 " > /dev/null 2>&1; then
    print_status "success" "端口3006正常占用"
else
    print_status "error" "端口3006未被占用"
fi

# 5. 检查配置文件
echo ""
echo "🔍 检查配置文件..."
if [ -f "/home/dify/tts_gateway/config.env" ]; then
    print_status "success" "TTS配置文件存在"
    
    # 检查关键配置项
    if grep -q "OPENSPEECH_TOKEN" /home/dify/tts_gateway/config.env; then
        print_status "success" "豆包API令牌已配置"
    else
        print_status "error" "豆包API令牌未配置"
    fi
    
    if grep -q "OSS_BASE_URL" /home/dify/tts_gateway/config.env; then
        print_status "success" "OSS配置已设置"
    else
        print_status "error" "OSS配置未设置"
    fi
else
    print_status "error" "TTS配置文件不存在"
fi

# 6. 检查工作流文件
echo ""
echo "🔍 检查工作流文件..."
if [ -f "/home/dify/上传文件/一键生成短视频-豆包语音优化版.yml" ]; then
    print_status "success" "工作流文件存在"
else
    print_status "error" "工作流文件不存在"
fi

# 7. 测试TTS API调用
echo ""
echo "🔍 测试TTS API调用..."
test_response=$(curl -s -X POST "http://localhost:3006/api/v1/tts" \
  -H "Content-Type: application/json" \
  -d '{"text":"测试文本","voice_type":"zh_male_dongfanghaoran_moon_bigtts"}' \
  --max-time 10 2>/dev/null)

if echo "$test_response" | grep -q "audio_url"; then
    print_status "success" "TTS API调用成功"
else
    print_status "error" "TTS API调用失败"
    echo "错误详情: $test_response"
fi

# 8. 清理临时文件
echo ""
echo "🧹 清理临时文件..."
if [ -d "/home/dify/tts_gateway/audio_files" ]; then
    find /home/dify/tts_gateway/audio_files -name "*.mp3" -mtime +1 -delete 2>/dev/null
    print_status "success" "临时音频文件清理完成"
else
    print_status "warning" "音频文件目录不存在"
fi

echo ""
echo "📊 修复总结:"
echo "=============="

# 统计检查结果
total_checks=8
passed_checks=0

# 重新检查关键服务
if curl -s http://localhost:3006/ | grep -q 'status.*running'; then
    ((passed_checks++))
fi

if curl -s http://8.148.70.18:9000/ | grep -q 'CapCutAPI'; then
    ((passed_checks++))
fi

if ping -c 1 8.148.70.18 > /dev/null 2>&1; then
    ((passed_checks++))
fi

if netstat -tlnp | grep ":3006 " > /dev/null 2>&1; then
    ((passed_checks++))
fi

if [ -f "/home/dify/tts_gateway/config.env" ]; then
    ((passed_checks++))
fi

if [ -f "/home/dify/上传文件/一键生成短视频-豆包语音优化版.yml" ]; then
    ((passed_checks++))
fi

if curl -s -X POST "http://localhost:3006/api/v1/tts" -H "Content-Type: application/json" -d '{"text":"test","voice_type":"zh_male_dongfanghaoran_moon_bigtts"}' | grep -q "audio_url"; then
    ((passed_checks++))
fi

if [ -d "/home/dify/tts_gateway/audio_files" ]; then
    ((passed_checks++))
fi

echo "检查项目: $total_checks"
echo "通过检查: $passed_checks"
echo "失败检查: $((total_checks - passed_checks))"

if [ $passed_checks -eq $total_checks ]; then
    print_status "success" "所有检查通过！系统运行正常"
    echo ""
    echo "🎉 修复完成！现在可以重新运行工作流了。"
else
    print_status "warning" "部分检查失败，请查看上述错误信息"
    echo ""
    echo "💡 建议操作:"
    echo "1. 检查TTS服务日志: tail -f /home/dify/tts_gateway/logs/tts_gateway_*.log"
    echo "2. 检查网络连接: ping 8.148.70.18"
    echo "3. 重新配置TTS服务: cd /home/dify/tts_gateway && nano config.env"
    echo "4. 重启TTS服务: cd /home/dify/tts_gateway && ./restart.sh"
fi

echo ""
echo "📚 更多帮助信息请查看: 语音合成工作流故障排除指南.md"
echo "==================================" 