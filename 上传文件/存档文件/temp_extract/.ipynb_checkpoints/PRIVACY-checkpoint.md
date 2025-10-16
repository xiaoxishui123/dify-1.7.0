# Privacy Policy

This plugin processes your text prompts to generate videos using the 302.AI Sora-2 AI model. Here's how your data is handled:

## Data Processing

- **Text Prompts**: Your video description text is sent to 302.AI's Sora-2 API to generate corresponding videos
- **API Communication**: The plugin communicates with 302.AI servers (https://api.302.ai) to process video generation requests
- **Generated Videos**: Video URLs are extracted from streaming responses and returned to your Dify workflow
- **Processing Mode**: Uses Server-Sent Events (SSE) streaming with real-time progress tracking to ensure reliable video generation

## Data Storage

- **No Local Storage**: The plugin does not permanently store your text prompts or generated video URLs locally
- **Temporary Processing**: All data processing is temporary and happens only during the video generation process
- **API Key Security**: Your 302.AI API key is stored securely within your Dify environment and is not logged or transmitted elsewhere
- **Stream Processing**: SSE response data is processed in real-time and not persisted after extraction

## Third-Party Services

- **302.AI API**: Your text prompts are sent to 302.AI's Sora-2 video generation service to create videos
- **Network Communication**: The plugin requires internet connectivity to communicate with 302.AI's servers via HTTPS
- **Service Provider**: 302.AI processes your requests according to their privacy policy
- **Video Hosting**: Generated videos are hosted on filesystem.site servers as provided by the 302.AI service

## Data Retention

- The plugin does not retain any user data after task completion
- Generated video URLs are temporarily extracted and immediately returned to your workflow
- No persistent storage of prompts, video URLs, or user information within the plugin
- SSE streaming data is discarded after processing

## Network Security

- **HTTPS Communication**: All API requests use secure HTTPS protocol
- **Streaming Security**: SSE connections are established over secure channels
- **No Data Logging**: The plugin does not log request/response data to files
- **Minimal Data Exposure**: Only essential data (prompts and video URLs) are processed

## User Control

- **Data Deletion**: Since no data is stored locally, there is nothing to delete from the plugin
- **API Key Management**: Users can update or revoke API keys at any time through Dify settings
- **Request Control**: Users have full control over when and what prompts are sent to the API

## Compliance

- This plugin follows Dify's plugin development guidelines
- Data handling complies with 302.AI's terms of service
- No personally identifiable information (PII) is collected or stored by the plugin
- Users are responsible for ensuring their prompts comply with applicable laws and regulations
