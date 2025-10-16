import re
import json
import time
from collections.abc import Generator
from typing import Optional
import http.client
from urllib.parse import urlparse
from dify_plugin.entities.tool import ToolInvokeMessage
from dify_plugin import Tool

class Text2VideoTool(Tool):
    def _invoke(
        self, tool_parameters: dict
    ) -> Generator[ToolInvokeMessage, None, None]:
        """
        基于 302.AI Sora-2 API 的文生视频工具

        Args:
            tool_parameters: 工具参数字典,包含 prompt 和 orientation

        Yields:
            ToolInvokeMessage: 工具调用消息,包括进度反馈和最终视频结果
        """
        # 1. 获取 API 配置
        api_key = self.runtime.credentials.get("api_key")

        # 2. 获取和验证参数
        prompt = tool_parameters.get("prompt", "")
        if not prompt:
            yield self.create_text_message("❌ 请输入视频描述提示词")
            return

        orientation = tool_parameters.get("orientation", "landscape")

        try:
            yield self.create_text_message("🚀 正在提交视频生成任务...")
            yield self.create_text_message(f"📝 提示词: {prompt[:100]}{'...' if len(prompt) > 100 else ''}")
            yield self.create_text_message(f"🎬 视频方向: {'横屏 (16:9)' if orientation == 'landscape' else '竖屏 (9:16)'}")

            # 3. 构建请求数据
            request_data = {
                "model": "sora-2",
                "messages": [
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                "stream": True
            }

            # 4. 发送 HTTPS 请求 (使用 http.client,与 sora2.py 保持一致)
            conn = http.client.HTTPSConnection("api.302.ai", timeout=600)

            headers = {
                'Accept': 'application/json',
                'Authorization': f'Bearer {api_key}',
                'Content-Type': 'application/json'
            }

            payload = json.dumps(request_data)

            # 发送请求 (使用异步回调模式)
            conn.request(
                "POST",
                "/v1/chat/completions?async=false&callback=https://api.302.ai/async_callback",
                payload,
                headers
            )

            response = conn.getresponse()

            # 检查响应状态
            if response.status != 200:
                error_body = response.read().decode("utf-8")
                yield self.create_text_message(f"❌ API 请求失败 (状态码: {response.status})")
                yield self.create_text_message(f"🔧 错误详情: {error_body[:300]}")
                return

            yield self.create_text_message("✅ 任务已提交,正在处理流式响应...")

            # 5. 解析流式响应 (SSE 格式)
            video_url = None
            task_id = None
            progress_shown = set()  # 记录已显示的进度,避免重复

            buffer = ""
            while True:
                # 逐块读取响应
                chunk = response.read(1024)
                if not chunk:
                    break

                buffer += chunk.decode("utf-8")

                # 按行处理 SSE 数据
                lines = buffer.split('\n')
                buffer = lines[-1]  # 保留不完整的行

                for line in lines[:-1]:
                    if not line.strip():
                        continue

                    # 解析 SSE 数据行
                    if line.startswith("data: "):
                        data_str = line[6:].strip()

                        # 跳过 [DONE] 标记
                        if data_str == "[DONE]":
                            continue

                        try:
                            data = json.loads(data_str)

                            # 提取 delta content
                            if "choices" in data and len(data["choices"]) > 0:
                                delta = data["choices"][0].get("delta", {})
                                content = delta.get("content", "")

                                # 提取任务 ID
                                if "ID:" in content and "`task_" in content:
                                    match = re.search(r'`(task_[a-z0-9]+)`', content)
                                    if match:
                                        task_id = match.group(1)
                                        yield self.create_text_message(f"📋 任务ID: {task_id}")

                                # 提取进度信息
                                if "进度" in content:
                                    # 提取所有数字进度
                                    progress_matches = re.findall(r'(\d+)\.\.', content)
                                    for prog in progress_matches:
                                        if prog not in progress_shown:
                                            progress_shown.add(prog)
                                            yield self.create_text_message(f"⏳ 生成进度: {prog}%")

                                # 状态提示
                                if "排队中" in content:
                                    yield self.create_text_message("⏱️ 任务排队中,请稍候...")
                                elif "生成中" in content and "生成完成" not in content:
                                    if not progress_shown:  # 只在第一次显示
                                        yield self.create_text_message("🎨 正在生成视频...")
                                elif "生成完成" in content:
                                    yield self.create_text_message("✅ 视频生成完成!")

                                # 提取视频 URL (在线播放地址)
                                if "[在线播放▶️]" in content or "src.mp4" in content:
                                    # 匹配视频播放 URL
                                    url_match = re.search(
                                        r'https://filesystem\.site/[^\s\)]+src\.mp4[^\s\)]*',
                                        content
                                    )
                                    if url_match:
                                        video_url = url_match.group(0)
                                        yield self.create_text_message(f"🎬 视频已就绪!")
                                        yield self.create_text_message(f"🔗 视频地址: {video_url}")

                        except json.JSONDecodeError:
                            # 忽略无法解析的 JSON 数据
                            continue

            conn.close()

            # 6. 返回视频结果
            if video_url:
                # 返回视频 URL 链接
                yield self.create_text_message("🎉 视频生成成功!")
                yield self.create_link_message(video_url)
                yield self.create_text_message("💡 提示: 点击上方链接在线观看视频")
            else:
                yield self.create_text_message("⚠️ 未能获取到视频播放地址,请稍后重试")

        except http.client.HTTPException as e:
            yield self.create_text_message(f"❌ HTTP 连接错误: {str(e)}")
        except TimeoutError:
            yield self.create_text_message("⏰ 请求超时,视频生成时间较长,请稍后重试")
        except json.JSONDecodeError as e:
            yield self.create_text_message(f"❌ 响应数据解析错误: {str(e)}")
        except Exception as e:
            yield self.create_text_message(f"❌ 生成视频时出现错误: {str(e)}")
            yield self.create_text_message("💡 可能的解决方案:")
            yield self.create_text_message("1. 检查 API Key 是否有效")
            yield self.create_text_message("2. 确认提示词描述清晰且符合规范")
            yield self.create_text_message("3. 稍后重试,可能是服务器繁忙")
