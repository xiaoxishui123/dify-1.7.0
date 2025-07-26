#!/bin/bash

# Dify项目快速备份脚本
# 作者: AI助手
# 创建时间: 2025年7月25日
# 用途: 快速备份Dify项目的核心数据

set -e

# 配置变量
PROJECT_ROOT="/home/dify"
BACKUP_ROOT="/home/dify/backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="quick_backup_${DATE}"
BACKUP_DIR="${BACKUP_ROOT}/${BACKUP_NAME}"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 创建备份目录
mkdir -p "${BACKUP_DIR}"

log_info "开始快速备份..."

# 备份数据库
log_info "备份数据库..."
cd "${PROJECT_ROOT}/docker"
if docker compose ps db | grep -q "Up"; then
    docker compose exec -T db pg_dump -U postgres dify > "${BACKUP_DIR}/database.sql"
    log_info "数据库备份完成"
else
    log_warn "数据库未运行，跳过数据库备份"
fi

# 备份.env文件
log_info "备份配置文件..."
if [ -f "${PROJECT_ROOT}/docker/.env" ]; then
    cp "${PROJECT_ROOT}/docker/.env" "${BACKUP_DIR}/"
    log_info "配置文件备份完成"
fi

# 备份存储数据（如果存在）
log_info "备份存储数据..."
if [ -d "${PROJECT_ROOT}/docker/volumes/app/storage" ]; then
    tar -czf "${BACKUP_DIR}/storage.tar.gz" -C "${PROJECT_ROOT}/docker/volumes" app/storage
    log_info "存储数据备份完成"
else
    log_warn "存储目录不存在，跳过存储备份"
fi

# 创建备份信息
cat > "${BACKUP_DIR}/backup_info.txt" << EOF
快速备份信息
=============

备份时间: $(date)
备份类型: 快速备份
备份目录: ${BACKUP_DIR}

备份内容:
- 数据库: database.sql
- 配置文件: .env
- 存储数据: storage.tar.gz

EOF

BACKUP_SIZE=$(du -sh "${BACKUP_DIR}" | cut -f1)
log_info "快速备份完成！备份大小: ${BACKUP_SIZE}"
log_info "备份位置: ${BACKUP_DIR}" 