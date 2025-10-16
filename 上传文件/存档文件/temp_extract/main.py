from dify_plugin import Plugin, DifyPluginEnv

# 配置插件环境,设置超时时间为 600 秒 (10分钟) 以适应视频生成的时间需求
plugin = Plugin(DifyPluginEnv(MAX_REQUEST_TIMEOUT=600))

if __name__ == '__main__':
    plugin.run()
