#!/bin/bash
# Debian 12 一键系统更新脚本（精简优化版）
# 作者: ChatGPT GPT-5

echo "========================================"
echo "🚀 Debian 12 一键更新开始 $(date)"
echo "========================================"

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
  echo "❌ 请使用 root 权限运行此脚本！"
  echo "👉 例如：sudo bash debian_update.sh"
  exit 1
fi

# 更新源索引
echo "🔄 正在更新软件包索引..."
apt update -y

# 执行完整升级
echo "⬆️ 正在执行完整系统升级..."
apt full-upgrade -y

# 清理无用包与缓存
echo "🧹 清理旧包与缓存..."
apt autoremove -y
apt autoclean

# 显示系统版本信息
echo "✅ 当前系统版本："
lsb_release -a 2>/dev/null || cat /etc/debian_version

# 检查是否需要重启
if [ -f /var/run/reboot-required ]; then
  echo "🔁 系统更新完成，需要重启。"
  echo "👉 执行命令：sudo reboot"
else
  echo "✅ 系统已是最新版本，无需重启。"
fi

echo "========================================"
echo "🎉 系统更新完成 $(date)"
echo "========================================"