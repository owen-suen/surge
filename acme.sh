#!/bin/bash

set -e

# ========= 基本检查 =========
if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 用户运行此脚本"
  exit 1
fi

# ========= 安装 acme.sh =========
if [ ! -f "$HOME/.acme.sh/acme.sh" ]; then
  echo "未检测到 acme.sh，开始安装..."
  curl https://get.acme.sh | sh -s email=5315cd@ssina0.com
else
  echo "已检测到 acme.sh，跳过安装"
fi

# 确保 acme.sh 在 PATH 中
export PATH="$HOME/.acme.sh:$PATH"

# ========= 输入域名 =========
read -rp "请输入要申请证书的域名（例如 example.com）: " DOMAIN

if [ -z "$DOMAIN" ]; then
  echo "域名不能为空"
  exit 1
fi

# ========= 创建 /etc/acme 目录 =========
ACME_DIR="/etc/acme"

if [ ! -d "$ACME_DIR" ]; then
  mkdir -p "$ACME_DIR"
  echo "已创建目录 $ACME_DIR"
fi

# 权限设置（仅 root 可读写）
chmod 700 "$ACME_DIR"

# ========= 申请证书 =========
echo "开始申请证书：$DOMAIN"

acme.sh --issue \
  --standalone \
  -d "$DOMAIN"

# ========= 安装证书 =========
echo "安装证书到 $ACME_DIR"

acme.sh --install-cert \
  -d "$DOMAIN" \
  --key-file       "$ACME_DIR/private.key" \
  --fullchain-file "$ACME_DIR/cert.pem" \
  --reloadcmd     "systemctl restart sing-box"

# 权限再次收紧
chmod 600 "$ACME_DIR/private.key"
chmod 644 "$ACME_DIR/cert.pem"

echo "===================================="
echo "证书申请并安装完成"
echo "域名: $DOMAIN"
echo "私钥: $ACME_DIR/private.key"
echo "证书: $ACME_DIR/cert.pem"
echo "sing-box 已自动重启"
echo "===================================="
