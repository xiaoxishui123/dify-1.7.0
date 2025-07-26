#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import json

# 你的API Key
API_KEY = "AlzaSyBzcsPShQbk2DFJWZ8a6gtbnli9-LbepFO"

# 尝试不同的代理配置
proxy_configs = [
    {
        'name': 'HTTP代理',
        'proxies': {
            'http': 'http://172.21.0.1:7890',
            'https': 'http://172.21.0.1:7890'
        }
    },
    {
        'name': 'HTTPS代理',
        'proxies': {
            'http': 'https://172.21.0.1:7890',
            'https': 'https://172.21.0.1:7890'
        }
    },
    {
        'name': 'SOCKS5代理',
        'proxies': {
            'http': 'socks5://172.21.0.1:7890',
            'https': 'socks5://172.21.0.1:7890'
        }
    }
]

# API端点
url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key={API_KEY}"

# 测试数据
data = {
    "contents": [{
        "parts": [{
            "text": "Hello, how are you?"
        }]
    }]
}

for config in proxy_configs:
    print(f"\n🔍 测试 {config['name']}...")
    print(f"📡 代理: {config['proxies']['https']}")
    
    try:
        response = requests.post(
            url,
            json=data,
            proxies=config['proxies'],
            timeout=30,
            headers={'Content-Type': 'application/json'},
            verify=False  # 禁用SSL验证
        )
        
        print(f"📊 状态码: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ 连接成功！")
            text = result.get('candidates', [{}])[0].get('content', {}).get('parts', [{}])[0].get('text', 'No text')
            print(f"📝 响应: {text}")
            break
        else:
            print(f"❌ 连接失败！")
            print(f"📄 错误: {response.text}")
            
    except Exception as e:
        print(f"❌ 错误: {e}")
        continue

print("\n💡 如果所有代理配置都失败，可能需要：")
print("1. 检查Clash配置")
print("2. 确认代理节点是否支持Google AI")
print("3. 尝试切换不同的代理节点") 