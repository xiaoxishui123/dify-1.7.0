#!/bin/bash

# Dify项目恢复脚本
# 作者: AI助手
# 创建时间: 2025年7月25日
# 用途: 从备份恢复Dify项目的数据库、应用数据和配置文件

set -e  # 遇到错误立即退出

# 配置变量
PROJECT_ROOT="/home/dify"
BACKUP_ROOT="/home/dify/backups"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 显示使用说明
show_usage() {
    echo "Dify项目恢复脚本"
    echo "=================="
    echo ""
    echo "用法: $0 <备份目录名>"
    echo ""
    echo "参数:"
    echo "  备份目录名    要恢复的备份目录名称（例如: dify_backup_20250725_143000）"
    echo ""
    echo "示例:"
    echo "  $0 dify_backup_20250725_143000"
    echo ""
    echo "注意:"
    echo "  - 恢复前请确保Dify服务已停止"
    echo "  - 恢复会覆盖当前的数据，请谨慎操作"
    echo "  - 建议在恢复前先创建当前数据的备份"
}

# 检查参数
check_arguments() {
    if [ $# -eq 0 ]; then
        log_error "请提供备份目录名"
        show_usage
        exit 1
    fi
    
    BACKUP_NAME="$1"
    BACKUP_DIR="${BACKUP_ROOT}/${BACKUP_NAME}"
    
    if [ ! -d "${BACKUP_DIR}" ]; then
        log_error "备份目录不存在: ${BACKUP_DIR}"
        echo ""
        echo "可用的备份目录:"
        ls -1 "${BACKUP_ROOT}" | grep "dify_backup_" | head -10
        exit 1
    fi
}

# 显示备份信息
show_backup_info() {
    log_info "恢复备份: ${BACKUP_NAME}"
    log_info "备份目录: ${BACKUP_DIR}"
    
    if [ -f "${BACKUP_DIR}/backup_info.txt" ]; then
        echo ""
        log_info "备份信息:"
        cat "${BACKUP_DIR}/backup_info.txt"
        echo ""
    fi
}

# 确认恢复操作
confirm_restore() {
    log_warn "⚠️  警告: 此操作将覆盖当前的数据！"
    echo ""
    echo "将要恢复的内容:"
    echo "- 数据库: ${BACKUP_DIR}/database/dify_database.sql"
    echo "- 存储数据: ${BACKUP_DIR}/storage/app_storage.tar.gz"
    echo "- 配置文件: ${BACKUP_DIR}/config/"
    echo ""
    
    read -p "确认要恢复吗？(输入 'yes' 确认): " confirm
    
    if [ "$confirm" != "yes" ]; then
        log_info "恢复操作已取消"
        exit 0
    fi
}

# 停止Dify服务
stop_dify_services() {
    log_step "停止Dify服务..."
    
    cd "${PROJECT_ROOT}/docker"
    
    if docker compose ps | grep -q "Up"; then
        log_info "停止Docker服务..."
        docker compose down
        log_info "服务已停止"
    else
        log_info "服务已经停止"
    fi
}

# 恢复数据库
restore_database() {
    log_step "恢复数据库..."
    
    DATABASE_FILE="${BACKUP_DIR}/database/dify_database.sql"
    
    if [ ! -f "${DATABASE_FILE}" ]; then
        log_error "数据库备份文件不存在: ${DATABASE_FILE}"
        return 1
    fi
    
    cd "${PROJECT_ROOT}/docker"
    
    # 启动数据库服务
    log_info "启动数据库服务..."
    docker compose up -d db
    
    # 等待数据库启动
    log_info "等待数据库启动..."
    sleep 10
    
    # 检查数据库是否运行
    if ! docker compose ps db | grep -q "Up"; then
        log_error "数据库服务启动失败"
        return 1
    fi
    
    # 恢复数据库
    log_info "恢复数据库数据..."
    docker compose exec -T db psql -U postgres -d dify < "${DATABASE_FILE}"
    
    if [ $? -eq 0 ]; then
        log_info "数据库恢复完成"
    else
        log_error "数据库恢复失败"
        return 1
    fi
}

# 恢复存储数据
restore_storage() {
    log_step "恢复存储数据..."
    
    STORAGE_FILE="${BACKUP_DIR}/storage/app_storage.tar.gz"
    STORAGE_TARGET="${PROJECT_ROOT}/docker/volumes"
    
    if [ ! -f "${STORAGE_FILE}" ]; then
        log_warn "存储备份文件不存在，跳过存储恢复"
        return 0
    fi
    
    # 备份当前存储数据（如果存在）
    if [ -d "${STORAGE_TARGET}/app/storage" ]; then
        log_info "备份当前存储数据..."
        mv "${STORAGE_TARGET}/app/storage" "${STORAGE_TARGET}/app/storage.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # 恢复存储数据
    log_info "恢复存储数据..."
    tar -xzf "${STORAGE_FILE}" -C "${STORAGE_TARGET}"
    
    if [ $? -eq 0 ]; then
        log_info "存储数据恢复完成"
    else
        log_error "存储数据恢复失败"
        return 1
    fi
}

# 恢复配置文件
restore_config() {
    log_step "恢复配置文件..."
    
    CONFIG_DIR="${BACKUP_DIR}/config"
    
    if [ ! -d "${CONFIG_DIR}" ]; then
        log_warn "配置备份目录不存在，跳过配置恢复"
        return 0
    fi
    
    # 恢复.env文件
    if [ -f "${CONFIG_DIR}/.env" ]; then
        log_info "恢复环境配置文件..."
        cp "${CONFIG_DIR}/.env" "${PROJECT_ROOT}/docker/"
        log_info "环境配置文件恢复完成"
    fi
    
    # 恢复docker-compose.yaml（可选）
    if [ -f "${CONFIG_DIR}/docker-compose.yaml" ]; then
        log_info "恢复Docker配置文件..."
        cp "${CONFIG_DIR}/docker-compose.yaml" "${PROJECT_ROOT}/docker/"
        log_info "Docker配置文件恢复完成"
    fi
}

# 启动Dify服务
start_dify_services() {
    log_step "启动Dify服务..."
    
    cd "${PROJECT_ROOT}/docker"
    
    log_info "启动所有服务..."
    docker compose up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 15
    
    # 检查服务状态
    log_info "检查服务状态..."
    docker compose ps
    
    log_info "服务启动完成"
}

# 验证恢复结果
verify_restore() {
    log_step "验证恢复结果..."
    
    cd "${PROJECT_ROOT}/docker"
    
    # 检查服务状态
    if docker compose ps | grep -q "Up"; then
        log_info "✅ 服务运行正常"
    else
        log_error "❌ 服务运行异常"
        return 1
    fi
    
    # 检查数据库连接
    if docker compose exec -T db pg_isready -U postgres; then
        log_info "✅ 数据库连接正常"
    else
        log_error "❌ 数据库连接异常"
        return 1
    fi
    
    log_info "恢复验证完成"
}

# 显示恢复完成信息
show_completion_info() {
    log_info "🎉 恢复完成！"
    echo ""
    echo "恢复信息:"
    echo "- 备份名称: ${BACKUP_NAME}"
    echo "- 恢复时间: $(date)"
    echo "- 访问地址: http://8.148.70.18:8080/"
    echo ""
    echo "下一步操作:"
    echo "1. 访问 http://8.148.70.18:8080/ 验证服务"
    echo "2. 检查应用功能是否正常"
    echo "3. 如有问题，查看日志: cd /home/dify/docker && docker compose logs"
    echo ""
}

# 主函数
main() {
    log_info "开始Dify项目恢复..."
    
    # 检查参数
    check_arguments "$@"
    
    # 显示备份信息
    show_backup_info
    
    # 确认恢复操作
    confirm_restore
    
    # 执行恢复步骤
    stop_dify_services
    restore_database
    restore_storage
    restore_config
    start_dify_services
    verify_restore
    
    # 显示完成信息
    show_completion_info
}

# 执行主函数
main "$@" 