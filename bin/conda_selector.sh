#!/bin/bash

# Conda环境快速选择器 - 简化版
# 使用fzf进行交互式选择并激活conda环境

# 检查必要工具
check_dependencies() {
    if ! command -v fzf &> /dev/null; then
        echo "echo '错误: 未找到 fzf 命令。请先安装 fzf。'" >&2
        return 1
    fi
    
    if ! command -v conda &> /dev/null; then
        echo "echo '错误: 未找到 conda 命令。请确保已安装并初始化 conda。'" >&2
        return 1
    fi
    
    return 0
}

# 主函数
main() {
    # 检查依赖
    if ! check_dependencies; then
        return 1
    fi
    
    # 获取环境列表并使用fzf选择
    local selected_env=$(conda info --envs | \
        grep -v "^#" | \
        grep -v "^$" | \
        fzf --height=40% \
            --layout=reverse \
            --border \
            --prompt="选择conda环境: " \
            --header="↑↓ 选择，Enter 确认，Esc 取消" | \
        awk '{print $1}')
    
    # 检查是否选择了环境
    if [[ -n "$selected_env" ]]; then
        echo "conda activate $selected_env"
    fi
}

# 执行主函数
main
