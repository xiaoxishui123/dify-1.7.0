from typing import Any
from dify_plugin.errors.tool import ToolProviderCredentialValidationError
from dify_plugin import ToolProvider

class Sora2Provider(ToolProvider):
    def _validate_credentials(self, credentials: dict[str, Any]) -> None:
        """
        验证 302.AI API 凭据有效性

        Args:
            credentials: 包含 302.AI API key 的字典

        Raises:
            ToolProviderCredentialValidationError: 当凭据验证失败时
        """
        try:
            # 检查 API key 格式
            api_key = credentials.get("api_key")
            if not api_key:
                raise ToolProviderCredentialValidationError(
                    "302.AI API key 不能为空"
                )

            if not api_key.startswith("sk-"):
                raise ToolProviderCredentialValidationError(
                    "无效的 302.AI API key 格式。应该以 'sk-' 开头"
                )

            # 检查 API key 长度
            if len(api_key) < 20:
                raise ToolProviderCredentialValidationError(
                    "302.AI API key 长度不正确"
                )

        except ToolProviderCredentialValidationError:
            # 重新抛出已知的验证错误
            raise
        except Exception as e:
            raise ToolProviderCredentialValidationError(
                f"302.AI API 凭据验证失败: {str(e)}"
            )
