#!/bin/bash

# Dify项目备份管理脚本
# 作者: AI助手
# 创建时间: 2025年7月25日
# 用途: 管理Dify项目的备份文件

set -e

# 配置变量
BACKUP_ROOT="/home/dify/backups"

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

# 显示使用说明
show_usage() {
    echo "Dify项目备份管理脚本"
    echo "===================="
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "命令:"
    echo "  list              列出所有备份"
    echo "  info <备份名>      显示备份详细信息"
    echo "  delete <备份名>    删除指定备份"
    echo "  cleanup [数量]     清理旧备份，保留指定数量（默认10个）"
    echo "  size              显示备份总大小"
    echo "  help              显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 list"
    echo "  $0 info dify_backup_20250725_143000"
    echo "  $0 delete dify_backup_20250725_143000"
    echo "  $0 cleanup 5"
}

# 列出所有备份
list_backups() {
    log_step "列出所有备份..."
    
    if [ ! -d "${BACKUP_ROOT}" ]; then
        log_warn "备份目录不存在: ${BACKUP_ROOT}"
        return
    fi
    
    cd "${BACKUP_ROOT}"
    
    if [ -z "$(ls -1 | grep -E '(dify_backup_|quick_backup_)')" ]; then
        log_info "没有找到备份文件"
        return
    fi
    
    echo ""
    echo "备份列表:"
    echo "=========="
    echo ""
    
    # 按时间倒序排列
    ls -1t | grep -E "(dify_backup_|quick_backup_)" | while read backup; do
        if [ -d "$backup" ]; then
            size=$(du -sh "$backup" | cut -f1)
            date=$(stat -c %y "$backup" | cut -d' ' -f1,2)
            echo "📁 $backup"
            echo "   大小: $size"
            echo "   时间: $date"
            
            # 显示备份类型
            if [[ "$backup" == "dify_backup_"* ]]; then
                echo "   类型: 完整备份"
            elif [[ "$backup" == "quick_backup_"* ]]; then
                echo "   类型: 快速备份"
            fi
            echo ""
        fi
    done
}

# 显示备份详细信息
show_backup_info() {
    local backup_name="$1"
    local backup_dir="${BACKUP_ROOT}/${backup_name}"
    
    if [ ! -d "${backup_dir}" ]; then
        log_error "备份目录不存在: ${backup_dir}"
        return 1
    fi
    
    log_step "显示备份详细信息: ${backup_name}"
    
    echo ""
    echo "备份详细信息:"
    echo "=============="
    echo "名称: $backup_name"
    echo "路径: $backup_dir"
    echo "大小: $(du -sh "${backup_dir}" | cut -f1)"
    echo "创建时间: $(stat -c %y "${backup_dir}" | cut -d' ' -f1,2)"
    echo ""
    
    # 显示备份内容
    echo "备份内容:"
    echo "---------"
    find "${backup_dir}" -type f -name "*.sql" -o -name "*.tar.gz" -o -name "*.txt" -o -name ".env" | while read file; do
        rel_path=$(echo "$file" | sed "s|${backup_dir}/||")
        size=$(du -sh "$file" | cut -f1)
        echo "📄 $rel_path ($size)"
    done
    echo ""
    
    # 显示备份信息文件
    if [ -f "${backup_dir}/backup_info.txt" ]; then
        echo "备份信息:"
        echo "---------"
        cat "${backup_dir}/backup_info.txt"
        echo ""
    fi
}

# 删除备份
delete_backup() {
    local backup_name="$1"
    local backup_dir="${BACKUP_ROOT}/${backup_name}"
    
    if [ ! -d "${backup_dir}" ]; then
        log_error "备份目录不存在: ${backup_dir}"
        return 1
    fi
    
    log_warn "将要删除备份: ${backup_name}"
    echo "备份大小: $(du -sh "${backup_dir}" | cut -f1)"
    echo ""
    
    read -p "确认删除吗？(输入 'yes' 确认): " confirm
    
    if [ "$confirm" = "yes" ]; then
        rm -rf "${backup_dir}"
        log_info "备份已删除: ${backup_name}"
    else
        log_info "删除操作已取消"
    fi
}

# 清理旧备份
cleanup_old_backups() {
    local keep_count="${1:-10}"
    
    log_step "清理旧备份，保留最近 $keep_count 个..."
    
    if [ ! -d "${BACKUP_ROOT}" ]; then
        log_warn "备份目录不存在"
        return
    fi
    
    cd "${BACKUP_ROOT}"
    
    # 计算当前备份数量
    backup_count=$(ls -1 | grep -E "(dify_backup_|quick_backup_)" | wc -l)
    
    if [ ${backup_count} -le ${keep_count} ]; then
        log_info "当前备份数量: ${backup_count}，无需清理"
        return
    fi
    
    # 删除多余的备份
    delete_count=$((backup_count - keep_count))
    log_info "将删除 $delete_count 个旧备份..."
    
    ls -1t | grep -E "(dify_backup_|quick_backup_)" | tail -n +$((keep_count + 1)) | while read backup; do
        if [ -d "$backup" ]; then
            size=$(du -sh "$backup" | cut -f1)
            log_info "删除: $backup ($size)"
            rm -rf "$backup"
        fi
    done
    
    log_info "清理完成，保留了最近 $keep_count 个备份"
}

# 显示备份总大小
show_backup_size() {
    log_step "计算备份总大小..."
    
    if [ ! -d "${BACKUP_ROOT}" ]; then
        log_warn "备份目录不存在"
        return
    fi
    
    cd "${BACKUP_ROOT}"
    
    total_size=$(du -sh . | cut -f1)
    backup_count=$(ls -1 | grep -E "(dify_backup_|quick_backup_)" | wc -l)
    
    echo ""
    echo "备份统计信息:"
    echo "=============="
    echo "总大小: $total_size"
    echo "备份数量: $backup_count"
    echo ""
    
    # 显示磁盘使用情况
    echo "磁盘使用情况:"
    echo "=============="
    df -h /home/dify
    echo ""
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    case "$1" in
        "list")
            list_backups
            ;;
        "info")
            if [ -z "$2" ]; then
                log_error "请提供备份名称"
                exit 1
            fi
            show_backup_info "$2"
            ;;
        "delete")
            if [ -z "$2" ]; then
                log_error "请提供备份名称"
                exit 1
            fi
            delete_backup "$2"
            ;;
        "cleanup")
            cleanup_old_backups "$2"
            ;;
        "size")
            show_backup_size
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            log_error "未知命令: $1"
            show_usage
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 