# Dify项目备份系统

## 概述

这是一个完整的Dify项目备份和恢复系统，用于保护您的Dify项目数据，防止在升级或修改代码时出现数据丢失。

## 备份内容

### 完整备份 (backup.sh)
- **数据库**: PostgreSQL数据库的完整备份
- **存储数据**: 应用上传的文件、图片等
- **配置文件**: .env、docker-compose.yaml等
- **代码状态**: Git状态、分支信息、修改记录
- **系统信息**: 操作系统、Docker版本等

### 快速备份 (quick_backup.sh)
- **数据库**: 核心数据备份
- **配置文件**: .env文件
- **存储数据**: 应用存储文件

## 脚本说明

### 1. 完整备份脚本 (backup.sh)
```bash
# 执行完整备份
./backup_scripts/backup.sh
```

**功能特点:**
- 自动创建带时间戳的备份目录
- 备份所有重要数据
- 自动清理旧备份（保留最近10个）
- 详细的日志输出
- 错误处理和回滚

### 2. 快速备份脚本 (quick_backup.sh)
```bash
# 执行快速备份
./backup_scripts/quick_backup.sh
```

**功能特点:**
- 快速备份核心数据
- 适合日常备份
- 占用空间较小
- 备份时间短

### 3. 恢复脚本 (restore.sh)
```bash
# 从备份恢复
./backup_scripts/restore.sh <备份目录名>
```

**示例:**
```bash
./backup_scripts/restore.sh dify_backup_20250725_143000
```

**功能特点:**
- 安全确认机制
- 自动停止和启动服务
- 完整的恢复流程
- 恢复后验证

### 4. 备份管理脚本 (manage_backups.sh)
```bash
# 查看所有备份
./backup_scripts/manage_backups.sh list

# 查看备份详细信息
./backup_scripts/manage_backups.sh info <备份名>

# 删除指定备份
./backup_scripts/manage_backups.sh delete <备份名>

# 清理旧备份（保留最近5个）
./backup_scripts/manage_backups.sh cleanup 5

# 查看备份总大小
./backup_scripts/manage_backups.sh size
```

## 使用场景

### 1. 升级前备份
```bash
# 在升级Dify前，先创建完整备份
./backup_scripts/backup.sh
```

### 2. 修改代码前备份
```bash
# 在修改代码前，创建快速备份
./backup_scripts/quick_backup.sh
```

### 3. 定期备份
```bash
# 可以设置定时任务，每天自动备份
# 编辑crontab: crontab -e
# 添加: 0 2 * * * /home/dify/backup_scripts/backup.sh
```

### 4. 数据恢复
```bash
# 如果出现问题，从备份恢复
./backup_scripts/restore.sh dify_backup_20250725_143000
```

## 备份策略建议

### 1. 备份频率
- **完整备份**: 每周一次，或重大变更前
- **快速备份**: 每天一次，或代码修改前
- **升级前**: 必须进行完整备份

### 2. 备份保留
- **完整备份**: 保留最近10个
- **快速备份**: 保留最近30个
- **重要备份**: 手动保留，不自动删除

### 3. 备份位置
- **本地备份**: `/home/dify/backups/`
- **建议**: 定期将重要备份复制到其他服务器或云存储

## 安全注意事项

### 1. 权限设置
```bash
# 设置脚本执行权限
chmod +x backup_scripts/*.sh

# 保护备份目录
chmod 700 /home/dify/backups
```

### 2. 敏感数据
- 备份包含数据库密码等敏感信息
- 确保备份目录安全，不要暴露在公网
- 定期检查备份文件权限

### 3. 磁盘空间
- 监控备份目录大小
- 定期清理旧备份
- 确保有足够磁盘空间

## 故障排除

### 1. 备份失败
```bash
# 检查Docker服务状态
cd /home/dify/docker
docker compose ps

# 检查磁盘空间
df -h /home/dify

# 查看备份日志
tail -f /home/dify/backups/backup_info.txt
```

### 2. 恢复失败
```bash
# 检查备份文件完整性
./backup_scripts/manage_backups.sh info <备份名>

# 检查Docker服务
docker compose ps

# 查看恢复日志
docker compose logs
```

### 3. 常见问题

**问题**: 数据库备份失败
**解决**: 确保数据库容器正在运行

**问题**: 存储备份失败
**解决**: 检查存储目录是否存在

**问题**: 恢复后服务无法启动
**解决**: 检查配置文件是否正确，查看Docker日志

## 自动化备份

### 1. 设置定时备份
```bash
# 编辑crontab
crontab -e

# 添加以下内容
# 每天凌晨2点进行完整备份
0 2 * * * /home/dify/backup_scripts/backup.sh

# 每天中午12点进行快速备份
0 12 * * * /home/dify/backup_scripts/quick_backup.sh

# 每周日凌晨3点清理旧备份
0 3 * * 0 /home/dify/backup_scripts/manage_backups.sh cleanup 5
```

### 2. 备份监控
```bash
# 创建备份监控脚本
cat > /home/dify/backup_scripts/monitor_backup.sh << 'EOF'
#!/bin/bash
BACKUP_COUNT=$(ls -1 /home/dify/backups/ | grep -E "(dify_backup_|quick_backup_)" | wc -l)
if [ $BACKUP_COUNT -lt 3 ]; then
    echo "警告: 备份数量不足，当前只有 $BACKUP_COUNT 个备份"
fi
EOF

chmod +x /home/dify/backup_scripts/monitor_backup.sh
```

## 最佳实践

### 1. 备份前检查
- 确保Dify服务正常运行
- 检查磁盘空间充足
- 验证数据库连接正常

### 2. 备份后验证
- 检查备份文件大小合理
- 验证备份信息文件完整
- 测试备份文件可读性

### 3. 恢复前准备
- 停止Dify服务
- 备份当前数据（如果需要）
- 确认恢复目标正确

### 4. 定期维护
- 清理过期备份
- 检查备份脚本权限
- 更新备份策略

## 联系支持

如果在使用过程中遇到问题，请：

1. 查看备份日志文件
2. 检查Docker服务状态
3. 验证备份文件完整性
4. 参考故障排除部分

---

**创建时间**: 2025年7月25日  
**版本**: 1.0  
**维护者**: AI助手 