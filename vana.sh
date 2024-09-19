#!/bin/bash

# 检查并安装 Git
check_git() {
  if ! git --version &> /dev/null; then
    echo "Git 未安装。正在安装 Git..."
    sudo apt update && sudo apt install -y git
  else
    echo "Git 已安装：$(git --version)"
  fi
}

# 检查并安装 Python 3.11
check_python() {
  if ! python3.11 --version &> /dev/null; then
    echo "Python 3.11 未安装。正在安装 Python 3.11..."
    sudo apt update && sudo apt install -y software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt update && sudo apt install -y python3.11 python3.11-venv python3.11-dev
  else
    echo "Python 3.11 已安装：$(python3.11 --version)"
  fi
}

# 检查并安装 Poetry
check_poetry() {
  if ! poetry --version &> /dev/null; then
    echo "Poetry 未安装。正在安装 Poetry..."
    curl -sSL https://install.python-poetry.org | python3.11 -
    echo "Poetry 已安装：$(poetry --version)"
  else
    echo "Poetry 已安装：$(poetry --version)"
  fi
}

# 检查并安装 Node.js 和 npm
check_node_npm() {
  if ! node --version &> /dev/null; then
    echo "Node.js 未安装。正在安装 Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
  else
    echo "Node.js 已安装：$(node --version)"
  fi

  if ! npm --version &> /dev/null; then
    echo "npm 未安装。正在安装 npm..."
    sudo apt install -y npm
  else
    echo "npm 已安装：$(npm --version)"
  fi
}

# 克隆 Git 仓库并进入目录
clone_and_enter_repo() {
  echo "克隆仓库 vana-dlp-chatgpt..."
  git clone https://github.com/vana-com/vana-dlp-chatgpt.git
  cd vana-dlp-chatgpt || { echo "无法进入目录，脚本终止"; exit 1; }
}

# 安装项目依赖
install_dependencies() {
  echo "使用 pip 安装 vana..."
  pip install vana || { echo "依赖安装失败，脚本终止"; exit 1; }
}

# 创建钱包
create_wallet() {
  echo "创建默认钱包..."
  vanacli wallet create --wallet.name default --wallet.hotkey default
  echo "请根据提示设置钱包安全密码..."
}

# 提示为两个地址提供资金
fund_testnet_addresses() {
  echo "提示：请使用测试网 VANA 为以下两个地址提供资金："
  echo "https://faucet.vana.org/"
  echo "请访问测试网水龙头获取测试 VANA 代币，并将资金发送到上述地址。"
}

# 执行检查并安装
check_git
check_python
check_poetry
check_node_npm

# 克隆仓库并安装依赖
clone_and_enter_repo
install_dependencies

# 创建钱包
create_wallet

# 提示为两个地址提供资金
fund_testnet_addresses

echo "所有依赖项已成功安装、仓库已克隆并创建钱包！"
