"""
Sora2 文生视频插件测试脚本

使用说明:
1. 确保已配置 302.AI API Key
2. 运行此脚本测试插件功能
"""

# 示例 1: 基本文生视频
example_1 = {
    "prompt": "一只金毛犬在阳光明媚的公园里玩耍,周围有孩子们在奔跑,镜头采用缓慢的推进和环绕拍摄",
    "orientation": "landscape"
}

# 示例 2: 自然风景视频
example_2 = {
    "prompt": "壮观的瀑布从高处倾泻而下,水雾弥漫,彩虹在阳光下若隐若现,镜头从远处逐渐拉近",
    "orientation": "landscape"
}

# 示例 3: 竖屏视频
example_3 = {
    "prompt": "一个年轻女孩在樱花树下跳舞,粉色的花瓣随风飘落,阳光透过树枝洒下斑驳的光影",
    "orientation": "portrait"
}

# 示例 4: 动物特写
example_4 = {
    "prompt": "一只小猫在追逐毛线球,毛线球在地板上滚动,小猫跳跃扑抓,背景是温馨的家居环境,光线柔和",
    "orientation": "landscape"
}

# 使用提示:
# 1. 在 Dify 工作流中添加 Sora2 文生视频工具
# 2. 配置您的 302.AI API Key
# 3. 使用上述示例参数进行测试
# 4. 视频生成通常需要 30-120 秒

print("Sora2 文生视频插件测试示例")
print("=" * 50)
print("\n示例 1 - 基本场景:")
print(f"提示词: {example_1['prompt']}")
print(f"方向: {example_1['orientation']}")
print("\n示例 2 - 自然风景:")
print(f"提示词: {example_2['prompt']}")
print(f"方向: {example_2['orientation']}")
print("\n示例 3 - 竖屏视频:")
print(f"提示词: {example_3['prompt']}")
print(f"方向: {example_3['orientation']}")
print("\n示例 4 - 动物特写:")
print(f"提示词: {example_4['prompt']}")
print(f"方向: {example_4['orientation']}")
