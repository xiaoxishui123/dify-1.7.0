#!/bin/bash

# Dify项目备份脚本
# 作者: AI助手
# 创建时间: 2025年7月25日
# 用途: 备份Dify项目的数据库、应用数据和配置文件

set -e  # 遇到错误立即退出

# 配置变量
PROJECT_ROOT="/home/dify"
BACKUP_ROOT="/home/dify/backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="dify_backup_${DATE}"
BACKUP_DIR="${BACKUP_ROOT}/${BACKUP_NAME}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
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
create_backup_dir() {
    log_info "创建备份目录: ${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}/database"
    mkdir -p "${BACKUP_DIR}/storage"
    mkdir -p "${BACKUP_DIR}/config"
    mkdir -p "${BACKUP_DIR}/code"
}

# 备份数据库
backup_database() {
    log_info "开始备份数据库..."
    
    cd "${PROJECT_ROOT}/docker"
    
    # 检查数据库容器是否运行
    if ! docker compose ps db | grep -q "Up"; then
        log_error "数据库容器未运行，无法备份"
        return 1
    fi
    
    # 使用pg_dump备份数据库
    docker compose exec -T db pg_dump -U postgres dify > "${BACKUP_DIR}/database/dify_database.sql"
    
    if [ $? -eq 0 ]; then
        log_info "数据库备份完成: ${BACKUP_DIR}/database/dify_database.sql"
    else
        log_error "数据库备份失败"
        return 1
    fi
}

# 备份应用存储数据
backup_storage() {
    log_info "开始备份应用存储数据..."
    
    STORAGE_SOURCE="${PROJECT_ROOT}/docker/volumes/app/storage"
    
    if [ -d "${STORAGE_SOURCE}" ]; then
        # 使用tar压缩备份存储数据
        tar -czf "${BACKUP_DIR}/storage/app_storage.tar.gz" -C "${PROJECT_ROOT}/docker/volumes" app/storage
        
        if [ $? -eq 0 ]; then
            log_info "存储数据备份完成: ${BACKUP_DIR}/storage/app_storage.tar.gz"
        else
            log_error "存储数据备份失败"
            return 1
        fi
    else
        log_warn "存储目录不存在，跳过存储备份"
    fi
}

# 备份配置文件
backup_config() {
    log_info "开始备份配置文件..."
    
    # 备份.env文件
    if [ -f "${PROJECT_ROOT}/docker/.env" ]; then
        cp "${PROJECT_ROOT}/docker/.env" "${BACKUP_DIR}/config/"
        log_info "环境配置文件备份完成"
    else
        log_warn ".env文件不存在，跳过配置备份"
    fi
    
    # 备份docker-compose.yaml
    if [ -f "${PROJECT_ROOT}/docker/docker-compose.yaml" ]; then
        cp "${PROJECT_ROOT}/docker/docker-compose.yaml" "${BACKUP_DIR}/config/"
        log_info "Docker配置文件备份完成"
    fi
}

# 备份代码状态
backup_code() {
    log_info "开始备份代码状态..."
    
    cd "${PROJECT_ROOT}"
    
    # 备份Git状态
    git log --oneline -10 > "${BACKUP_DIR}/code/git_log.txt"
    git status > "${BACKUP_DIR}/code/git_status.txt"
    git diff > "${BACKUP_DIR}/code/git_diff.txt"
    
    # 备份当前分支信息
    git branch > "${BACKUP_DIR}/code/git_branch.txt"
    git remote -v > "${BACKUP_DIR}/code/git_remote.txt"
    
    log_info "代码状态备份完成"
}

# 创建备份信息文件
create_backup_info() {
    log_info "创建备份信息文件..."
    
    cat > "${BACKUP_DIR}/backup_info.txt" << EOF
Dify项目备份信息
================

备份时间: $(date)
备份名称: ${BACKUP_NAME}
备份目录: ${BACKUP_DIR}

备份内容:
- 数据库: dify_database.sql
- 存储数据: app_storage.tar.gz
- 配置文件: .env, docker-compose.yaml
- 代码状态: Git状态和差异

系统信息:
- 操作系统: $(uname -a)
- Docker版本: $(docker --version)
- 磁盘使用: $(df -h /home/dify | tail -1)

备份命令: $0
EOF

    log_info "备份信息文件创建完成"
}

# 清理旧备份
cleanup_old_backups() {
    log_info "清理旧备份文件..."
    
    # 保留最近10个备份
    cd "${BACKUP_ROOT}"
    BACKUP_COUNT=$(ls -1 | grep "dify_backup_" | wc -l)
    
    if [ ${BACKUP_COUNT} -gt 10 ]; then
        log_info "发现 ${BACKUP_COUNT} 个备份，保留最近10个"
        ls -1t | grep "dify_backup_" | tail -n +11 | xargs -r rm -rf
        log_info "旧备份清理完成"
    else
        log_info "当前备份数量: ${BACKUP_COUNT}，无需清理"
    fi
}

# 计算备份大小
calculate_backup_size() {
    BACKUP_SIZE=$(du -sh "${BACKUP_DIR}" | cut -f1)
    log_info "备份完成，总大小: ${BACKUP_SIZE}"
}

# 主函数
main() {
    log_info "开始Dify项目备份..."
    log_info "备份时间: $(date)"
    log_info "备份目录: ${BACKUP_DIR}"
    
    # 检查项目目录
    if [ ! -d "${PROJECT_ROOT}" ]; then
        log_error "项目目录不存在: ${PROJECT_ROOT}"
        exit 1
    fi
    
    # 创建备份根目录
    mkdir -p "${BACKUP_ROOT}"
    
    # 执行备份步骤
    create_backup_dir
    backup_database
    backup_storage
    backup_config
    backup_code
    create_backup_info
    cleanup_old_backups
    calculate_backup_size
    
    log_info "备份完成！"
    log_info "备份位置: ${BACKUP_DIR}"
    log_info "备份时间: $(date)"
}

# 执行主函数
main "$@" 