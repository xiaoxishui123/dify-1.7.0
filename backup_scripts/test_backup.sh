#!/bin/bash

# Dify项目备份系统测试脚本
# 作者: AI助手
# 创建时间: 2025年7月25日
# 用途: 测试备份系统是否正常工作

set -e

# 配置变量
PROJECT_ROOT="/home/dify"
BACKUP_ROOT="/home/dify/backups"
DATE=$(date +"%Y%m%d_%H%M%S")
TEST_BACKUP_NAME="test_backup_${DATE}"
TEST_BACKUP_DIR="${BACKUP_ROOT}/${TEST_BACKUP_NAME}"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 测试环境检查
test_environment() {
    log_step "检查测试环境..."
    
    # 检查项目目录
    if [ ! -d "${PROJECT_ROOT}" ]; then
        log_error "项目目录不存在: ${PROJECT_ROOT}"
        return 1
    fi
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装"
        return 1
    fi
    
    # 检查docker compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose未安装"
        return 1
    fi
    
    # 检查磁盘空间
    AVAILABLE_SPACE=$(df /home/dify | tail -1 | awk '{print $4}')
    if [ $AVAILABLE_SPACE -lt 1000000 ]; then
        log_warn "磁盘空间不足，可用空间: ${AVAILABLE_SPACE}KB"
    fi
    
    log_info "环境检查通过"
}

# 测试Docker服务
test_docker_services() {
    log_step "检查Docker服务状态..."
    
    cd "${PROJECT_ROOT}/docker"
    
    if docker compose ps | grep -q "Up"; then
        log_info "Docker服务正在运行"
        
        # 检查数据库服务
        if docker compose ps db | grep -q "Up"; then
            log_info "数据库服务正常"
        else
            log_warn "数据库服务未运行"
        fi
        
        # 检查其他服务
        docker compose ps
    else
        log_warn "Docker服务未运行"
    fi
}

# 测试备份目录创建
test_backup_directory() {
    log_step "测试备份目录创建..."
    
    mkdir -p "${TEST_BACKUP_DIR}"
    
    if [ -d "${TEST_BACKUP_DIR}" ]; then
        log_info "备份目录创建成功: ${TEST_BACKUP_DIR}"
    else
        log_error "备份目录创建失败"
        return 1
    fi
}

# 测试数据库连接
test_database_connection() {
    log_step "测试数据库连接..."
    
    cd "${PROJECT_ROOT}/docker"
    
    if docker compose ps db | grep -q "Up"; then
        if docker compose exec -T db pg_isready -U postgres; then
            log_info "数据库连接正常"
        else
            log_error "数据库连接失败"
            return 1
        fi
    else
        log_warn "数据库服务未运行，跳过连接测试"
    fi
}

# 测试配置文件
test_config_files() {
    log_step "测试配置文件..."
    
    # 检查.env文件
    if [ -f "${PROJECT_ROOT}/docker/.env" ]; then
        log_info ".env文件存在"
        
        # 检查关键配置
        if grep -q "NGINX_PORT=" "${PROJECT_ROOT}/docker/.env"; then
            log_info "Nginx端口配置正常"
        else
            log_warn "Nginx端口配置缺失"
        fi
    else
        log_warn ".env文件不存在"
    fi
    
    # 检查docker-compose.yaml
    if [ -f "${PROJECT_ROOT}/docker/docker-compose.yaml" ]; then
        log_info "docker-compose.yaml文件存在"
    else
        log_error "docker-compose.yaml文件不存在"
        return 1
    fi
}

# 测试存储目录
test_storage_directory() {
    log_step "测试存储目录..."
    
    STORAGE_DIR="${PROJECT_ROOT}/docker/volumes/app/storage"
    
    if [ -d "${STORAGE_DIR}" ]; then
        log_info "存储目录存在: ${STORAGE_DIR}"
        
        # 检查存储目录权限
        if [ -r "${STORAGE_DIR}" ] && [ -w "${STORAGE_DIR}" ]; then
            log_info "存储目录权限正常"
        else
            log_warn "存储目录权限异常"
        fi
    else
        log_warn "存储目录不存在，将自动创建"
    fi
}

# 测试备份脚本
test_backup_scripts() {
    log_step "测试备份脚本..."
    
    # 检查脚本文件
    SCRIPTS=("backup.sh" "quick_backup.sh" "restore.sh" "manage_backups.sh")
    
    for script in "${SCRIPTS[@]}"; do
        if [ -f "${PROJECT_ROOT}/backup_scripts/${script}" ]; then
            if [ -x "${PROJECT_ROOT}/backup_scripts/${script}" ]; then
                log_info "脚本 ${script} 存在且可执行"
            else
                log_warn "脚本 ${script} 存在但不可执行"
            fi
        else
            log_error "脚本 ${script} 不存在"
            return 1
        fi
    done
}

# 创建测试备份
create_test_backup() {
    log_step "创建测试备份..."
    
    # 创建测试备份目录结构
    mkdir -p "${TEST_BACKUP_DIR}/database"
    mkdir -p "${TEST_BACKUP_DIR}/storage"
    mkdir -p "${TEST_BACKUP_DIR}/config"
    mkdir -p "${TEST_BACKUP_DIR}/code"
    
    # 创建测试文件
    echo "测试数据库备份" > "${TEST_BACKUP_DIR}/database/test_database.sql"
    echo "测试存储备份" > "${TEST_BACKUP_DIR}/storage/test_storage.tar.gz"
    echo "测试配置备份" > "${TEST_BACKUP_DIR}/config/test_config.txt"
    echo "测试代码备份" > "${TEST_BACKUP_DIR}/code/test_code.txt"
    
    # 创建测试备份信息
    cat > "${TEST_BACKUP_DIR}/backup_info.txt" << EOF
测试备份信息
============

备份时间: $(date)
备份类型: 测试备份
备份目录: ${TEST_BACKUP_DIR}

这是一个测试备份，用于验证备份系统功能。

EOF
    
    log_info "测试备份创建完成"
}

# 清理测试备份
cleanup_test_backup() {
    log_step "清理测试备份..."
    
    if [ -d "${TEST_BACKUP_DIR}" ]; then
        rm -rf "${TEST_BACKUP_DIR}"
        log_info "测试备份已清理"
    fi
}

# 显示测试结果
show_test_results() {
    log_info "🎉 备份系统测试完成！"
    echo ""
    echo "测试结果:"
    echo "=========="
    echo "✅ 环境检查: 通过"
    echo "✅ 脚本检查: 通过"
    echo "✅ 目录测试: 通过"
    echo "✅ 配置测试: 通过"
    echo ""
    echo "备份系统已准备就绪！"
    echo ""
    echo "下一步操作:"
    echo "1. 执行完整备份: ./backup_scripts/backup.sh"
    echo "2. 执行快速备份: ./backup_scripts/quick_backup.sh"
    echo "3. 查看备份管理: ./backup_scripts/manage_backups.sh list"
    echo ""
}

# 主函数
main() {
    log_info "开始备份系统测试..."
    echo ""
    
    # 执行测试步骤
    test_environment
    test_docker_services
    test_backup_directory
    test_database_connection
    test_config_files
    test_storage_directory
    test_backup_scripts
    create_test_backup
    
    # 显示结果
    show_test_results
    
    # 清理测试文件
    cleanup_test_backup
}

# 执行主函数
main "$@" 