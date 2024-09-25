#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/vana.sh"

# 安装 Git 函数
function install_git() {
    if ! git --version &> /dev/null; then
        echo "Git 未安装。正在安装 Git..."
        sudo apt update && sudo apt install -y git
    else
        echo "Git 已安装：$(git --version)"
    fi
}

# 安装 Python 函数
function install_python() {
    if ! python3 --version &> /dev/null; then
        echo "Python 未安装。正在安装 Python..."
        sudo apt update && sudo apt install -y python3 python3-pip
    fi
}

# 安装 Node.js 和 npm 函数
function install_node() {
    if ! node --version &> /dev/null; then
        echo "Node.js 未安装。正在安装 Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt install -y nodejs
    fi

    if ! npm --version &> /dev/null; then
        echo "npm 未安装。正在安装 npm..."
        sudo apt install -y npm
    fi
}

# 安装 nvm 函数
function install_nvm() {
    if ! command -v nvm &> /dev/null; then
        echo "nvm 未安装。正在安装 nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
}

# 使用 Node.js 18 函数
function use_node_18() {
    nvm install 18
    nvm use 18
}

# 克隆 Git 仓库并进入目录函数
function clone_and_enter_repo() {
    echo "克隆仓库 vana-dlp-chatgpt..."
    git clone https://github.com/vana-com/vana-dlp-chatgpt.git
    cd vana-dlp-chatgpt || { echo "无法进入目录，脚本终止"; exit 1; }
}

# 安装项目依赖函数
function install_dependencies() {
    cp .env.example .env
    echo "使用 pip 安装 vana..."
    apt install python3-pip
    pip3 install vana || { echo "依赖安装失败，脚本终止"; exit 1; }
}

# 运行密钥生成函数
function run_keygen() {
    echo "创建默认钱包..."
    vanacli wallet create --wallet.name default --wallet.hotkey default

    echo "运行密钥生成..."
    ./keygen.sh
    echo "请输入您的姓名、电子邮件和密钥时长。"
}

# 部署 DLP 智能合约函数
function deploy_dlp_contract() {
    cd .. || { echo "无法返回上级目录，脚本终止"; exit 1; }
    echo "克隆 DLP 智能合约仓库..."
    git clone https://github.com/vana-com/vana-dlp-smart-contracts.git
    cd vana-dlp-smart-contracts || { echo "无法进入目录，脚本终止"; exit 1; }

    echo "安装依赖项..."
    sudo apt install -y cmdtest
    npm install --global yarn
}

# 初始化 npm 和安装 Hardhat 函数
function setup_hardhat() {
    npm init -y
    npm install --save-dev hardhat
    nvm install 18
    nvm use 18
    npm install --save-dev hardhat
    npx hardhat

    # 提示用户输入冷键私钥
    read -p "请输入您的冷键私钥以配置 accounts: [\"0x你的冷键私钥\"]: " cold_key

    # 更新 hardhat.config.js 文件
    echo "module.exports = {
        solidity: \"^0.8.0\",
        networks: {
            hardhat: {
                accounts: [\"$cold_key\"]
            }
        }
    };" > hardhat.config.js

    echo "Hardhat 配置完成。"
}

# 部署合约并提示用户保存地址函数
function deploy_and_save_addresses() {
    echo "部署合约..."
    npx hardhat deploy --network satori --tags DLPDeploy

    echo "请保存 DataLiquidityPool 和 DataLiquidityPoolToken 的部署地址。"
    echo "按任意键返回主菜单..."
    read -n 1 -s
}

# 启动验证者节点函数
function start_validator_node() {
    cd ~/vana-dlp-chatgpt || { echo "无法进入目录，脚本终止"; exit 1; }

    read -rp "请输入 DataLiquidityPool 地址 (DLP_SATORI_CONTRACT=0x...)：" dlp_satori_contract
    read -rp "请输入 DataLiquidityPoolToken 地址 (DLP_TOKEN_SATORI_CONTRACT=0x...)：" dlp_token_satori_contract
    read -rp "请输入 钱包公钥 (PRIVATE_FILE_ENCRYPTION_PUBLIC_KEY_BASE64)：" public_key

    # 导入到 .env 文件中
    echo "DLP_SATORI_CONTRACT=${dlp_satori_contract}" >> .env
    echo "DLP_TOKEN_SATORI_CONTRACT=${dlp_token_satori_contract}" >> .env
    echo "PRIVATE_FILE_ENCRYPTION_PUBLIC_KEY_BASE64=${public_key}" >> .env

    echo "安装 Poetry..."
    sudo apt install -y python3-poetry

    echo "注册验证者节点..."
    ./vanacli dlp register_validator --stake_amount 10

    echo "启动验证者节点..."
    poetry run python -m chatgpt.nodes.validator

    echo "验证者节点启动配置已完成。"
    echo "按任意键返回主菜单..."
    read -n 1 -s
}

# 部署环境函数
function deploy_environment() {
    install_git
    install_python
    install_node
    install_nvm
    use_node_18
    clone_and_enter_repo
    install_dependencies
    run_keygen
    deploy_dlp_contract
    setup_hardhat
    deploy_and_save_addresses
}

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由推特 @ferdie_jhovie 提供，免费开源，请勿相信收费"
        echo "================================================================"
        echo "节点社区 Telegram 群组: https://t.me/niuwuriji"
        echo "节点社区 Telegram 频道: https://t.me/niuwuriji"
        echo "节点社区 Discord 社群: https://discord.gg/GbMV5EcNWF"
        echo "退出脚本，请按键盘 ctrl+c 退出"
        echo "请选择要执行的操作:"
        echo "1) 部署环境"
        echo "2) 启动验证者节点"
        echo "0) 退出"
        echo "================================================================"
        read -rp "输入您的选择: " choice

        case $choice in
            1)
                deploy_environment
                ;;
            2)
                start_validator_node
                ;;
            0)
                echo "退出脚本"
                exit 0
                ;;
            *)
                echo "无效的选择，请重新输入"
                ;;
        esac
    done
}

# 启动主菜单
main_menu
